import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fuocherello/domain/usecases/chat/copy_message.dart';
import 'package:fuocherello/presentation/chat/chat_page_image_popup.dart';
import 'package:fuocherello/helper/singletons/chat_page_logic.dart';
import 'package:fuocherello/data/entities/chat/message_data.dart';
import 'package:fuocherello/data/mappers/chat_mapper.dart';
import 'package:fuocherello/domain/enums/chat_enums.dart';
import 'package:fuocherello/domain/models/chat/chat_page_info.dart';
import 'package:fuocherello/domain/models/chat/message.dart';
import 'package:fuocherello/domain/repositories/chat_list_repository.dart';
import 'package:fuocherello/domain/repositories/chat_repository.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';
import 'package:fuocherello/helper/singletons/path_checker.dart';
import 'package:go_router/go_router.dart';
import 'package:signalr_netcore/signalr_client.dart' hide ConnectionState;
import 'package:uuid_type/uuid_type.dart';
import 'package:fuocherello/domain/models/chat/chat_page_controller.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    this.chatId,
    required this.prodId,
    required this.from,
    required this.to,
    required this.initData,
    required this.chatRepository,
    required this.chatListRepository,
  });

  final Uuid? chatId;
  final String prodId;
  final String from;
  final String to;
  final List<Message> initData;
  final ChatRepository chatRepository;
  final ChatListRepository chatListRepository;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  //init state variables
  late final bool isUserChatOwner;
  late final from = widget.from;
  late final to = widget.to;
  late final initData = widget.initData;
  final ScrollController chatController = ScrollController();
  final TextEditingController messageCtrl = TextEditingController();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  StreamSubscription? messageStreamSub, imageStreamSub, signalrStreamSub;
  late final ChatPageImagePopup imagePopup = ChatPageImagePopup();
  late final Stream imageStream = imagePopup.imagesController.stream;
  late final Stream messageStream = widget.chatRepository.messageStream;

  //chat repository data
  List<Message> get messages => widget.chatRepository.getMessages;
  Map<int, CachedNetworkImage> get cachedImages =>
      widget.chatRepository.getChachedImages;
  Map<int, Image> get localImages => widget.chatRepository.getLocalImages;
  List<Color?> get messagesColors => widget.chatRepository.getMessagesColors;
  HashSet<String> get blurredImages => widget.chatRepository.getBlurredImages;

  //normal
  final Color myMessageColor = Colors.grey[200]!;
  final Color otherMessageColor = Colors.blue[200]!;
  //hoevr
  final Color? hoverMyMessageColor = Colors.grey[400];
  final Color? hoverOtherMessageColor = Colors.blue[400];

  late ChatPageInfo info = ChatPageInfo(
      chatRepository: widget.chatRepository,
      chatId: widget.chatId,
      prodId: Uuid.parse(widget.prodId),
      from: widget.from,
      to: widget.to);

  //chat id can be null if the chat has just been created
  //it will be set by the signarStreamSub when
  //the user will successfuly send the first message
  Uuid? chatId;

  //signleton
  final ChatLogic chatLogic = ChatLogic.instance;
  final LoginManager manager = LoginManager.instance;

  bool isUserCopyingMessage = false;

  //list used for containing the currently selected messages that need to be copied by the user
  final List<Message> selectedMessages = [];

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print("chat resumed");
      PathChecker.isChatOpen = true;

      if (chatLogic.hubConnection.state == HubConnectionState.Reconnecting) {
        await chatLogic.start();
      }
      setState(() {});
      print(chatLogic.hubConnection.state);
    } else if (state == AppLifecycleState.paused) {
      print("chat closed");
      PathChecker.isChatOpen = false;
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.chatId != null) {
      chatId = widget.chatId;
      setState(() {});
    }

    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!(chatLogic.hubConnection.state == HubConnectionState.Connected)) {
        await chatLogic.start();
      }
    });

    isUserChatOwner = LoginManager.instance.userId == from ? true : false;

    PathChecker.isChatOpen = true;
    PathChecker.setLocation = "/chatlist/${chatId}";

    //init the chat repository with the current chat chached images
    widget.chatRepository
        .getImageFromMessage(myMessageColor, otherMessageColor);

    setState(() {});

    //stream to receive messages and check if it's an image message or a text message
    messageStreamSub = messageStream.listen((event) async {
      if (event is MessageData) {
        Message message = ChatMapper.fromMessageData(event);

        if (message.prodId == widget.prodId && message.from == widget.to) {
          print(manager.userId! == from);
          Color? selectedColor = Colors.blue[200];
          messagesColors.add(selectedColor);

          if (widget.chatRepository.isMediaMessage(message.message) ==
              FileLocation.url) {
            cachedImages.addAll({
              messages.length: CachedNetworkImage(
                imageUrl: message.message,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            });
          }
          messages.add(message);
          mounted ? setState(() {}) : null;
        }
      }
    });

    //StreamSubScription to send image files
    imageStreamSub = imageStream.listen(
      (event) async {
        if (event is List<File>) {
          for (var img in event) {
            await widget.chatRepository.insertImageMessageInList(
                myMessageColor, otherMessageColor, img, info);
          }
          setState(() {});
          await widget.chatRepository
              .InsertImageMessageInLocalDb(event, widget.chatId.toString());
          setState(() {});

          Message chatListMsg = messages.last;
          String path = chatListMsg.message;

          //update chat list tile
          if (chatListMsg.from == manager.userId) {
            await widget.chatListRepository
                .resetChatTile(chatId!, message: chatListMsg.message);
          } else {
            await widget.chatListRepository
                .updateChatTile(chatId!, chatListMsg.message);
          }

          chatListMsg.message = path;
        }
      },
      onError: (error) => print(error),
    );

    //the signlar server will trigger the client signlarStreamSub assigning the newly geneared (by the server) chat id
    signalrStreamSub = chatLogic.signalrStream.listen((event) {
      print("chat id received from signalr event");
      chatId = Uuid.parse(event as String);
      setState(() {});
    });
  }

  @override
  void dispose() {
    print("dispose");
    selectedMessages.clear();
    messageStreamSub?.cancel();
    imageStreamSub?.cancel();
    signalrStreamSub?.cancel();
    PathChecker.setLocation = "/chatlist";
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //get the correct widget accordign to the current message type
  Widget selectMessageType(int index) {
    FileLocation isMedia =
        widget.chatRepository.isMediaMessage(messages[index].message);

    Text simpleMessage = Text(
      messages[index].message,
      style: const TextStyle(fontSize: 15),
    );
    if (isMedia == FileLocation.empty) {
      return simpleMessage;
    } else if (isMedia == FileLocation.local) {
      //blur the images until the images has not been sent to the server
      if (blurredImages.contains(messages[index].message)) {
        return SizedBox(
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SizedBox(
                height: 200,
                width: 300,
                child: localImages[index],
              ),
              ClipRRect(
                // Clip it cleanly.
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.grey.withOpacity(0.1),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return InkWell(
          onTap: () => context.pushNamed('image', extra: localImages[index]),
          child: SizedBox(
            width: 200,
            child: localImages[index],
          ),
        );
      }
    } else if (isMedia == FileLocation.url) {
      //blur the images until the images has not been sent to the server
      if (blurredImages.contains(messages[index].message)) {
        return SizedBox(
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SizedBox(height: 200, width: 300, child: cachedImages[index]),
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.grey.withOpacity(0.1),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return InkWell(
          onTap: () => context.pushNamed('image', extra: cachedImages[index]),
          child: SizedBox(
            width: 200,
            child: cachedImages[index],
          ),
        );
      }
    }
    return simpleMessage;
  }

  @override
  Widget build(BuildContext context) {
    print("MESSAGGI: ${messages.length}");
    return PopScope(
      canPop: false,
      onPopInvoked: (value) async {
        await ChatPageController.handleBackPressed(
          context,
          chatId,
          messages,
          messagesColors,
          widget.chatListRepository,
          () {
            setState(() {}); // Update UI
          },
        );
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          scrolledUnderElevation: 0.0,
          centerTitle: true,
          actions: [
            isUserCopyingMessage
                ? IconButton(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(
                          text:
                              selectedMessages.map((e) => e.message).join('\n'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy))
                : const SizedBox(),
            SizedBox(),
          ],
          leading: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: IconButton(
              onPressed: () => ChatPageController.handleBackPressed(
                context,
                chatId,
                messages,
                messagesColors,
                widget.chatListRepository,
                () {
                  setState(() {}); // Update UI
                },
              ),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              "Messaggi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              controller: chatController,
              reverse: true,
              child: Container(
                margin: const EdgeInsets.only(bottom: 50),
                child: ListView.builder(
                  itemCount: messages.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    print(
                        "${ChatMapper.toMessageData(messages[index]).toJson()}");
                    return InkWell(
                      onLongPress: (() {
                        selectedMessages.add(messages[index]);
                        messages[index].from == manager.userId
                            ? messagesColors[index] = hoverMyMessageColor
                            : messagesColors[index] = hoverOtherMessageColor;
                        setState(() {
                          isUserCopyingMessage = true;
                        });
                      }),
                      // copy messages functionality
                      onTap: ((() {
                        copy(
                          index,
                          isUserChatOwner,
                          messages,
                          selectedMessages,
                          messagesColors,
                          myMessageColor,
                          otherMessageColor,
                          hoverMyMessageColor!,
                          hoverOtherMessageColor!,
                        );

                        if (selectedMessages.isEmpty) {
                          isUserCopyingMessage = false;
                        }

                        setState(() {});
                      })),
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 14, right: 14, top: 5, bottom: 5),
                        child: Align(
                          alignment: (messages[index].from == from
                              ? Alignment.topRight
                              : Alignment.topLeft),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: messagesColors[index],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: selectMessageType(index),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.only(
                  left: 10,
                  top: 5,
                  bottom: 5,
                  right: 10,
                ),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: widget.prodId == "null"
                      ? <Widget>[
                          Expanded(
                            child: TextField(
                              textAlign: TextAlign.center,
                              controller: messageCtrl,
                              decoration: const InputDecoration(
                                hintText: "Il prodotto e' stato eliminato",
                                hintStyle: TextStyle(color: Colors.black54),
                                border: InputBorder.none,
                              ),
                            ),
                          )
                        ]
                      : <Widget>[
                          GestureDetector(
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                                color: Colors.lightBlue,
                              ),
                              child: IconButton(
                                onPressed: () => showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: const SizedBox(),
                                    content: imagePopup,
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => context.pop(),
                                        child: const Text('Annulla'),
                                      ),
                                    ],
                                  ),
                                ),
                                icon: const Icon(Icons.add),
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: TextField(
                              controller: messageCtrl,
                              decoration: const InputDecoration(
                                hintText: "Scrivi un messaggio ...",
                                hintStyle: TextStyle(color: Colors.black54),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.all(
                                Radius.circular(40),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: IconButton(
                              onPressed: () async {
                                await ChatPageController.sendMessage(
                                    messageCtrl: messageCtrl,
                                    chatId: chatId,
                                    prodId: widget.prodId,
                                    from: from,
                                    to: to,
                                    chatLogic: chatLogic,
                                    chatRepository: widget.chatRepository,
                                    chatListRepository:
                                        widget.chatListRepository,
                                    secureStorage: secureStorage,
                                    messages: messages,
                                    messagesColors: messagesColors,
                                    manager: manager,
                                    info: info,
                                    setStateCallback: () {
                                      setState(() {});
                                    });
                              },
                              icon: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
