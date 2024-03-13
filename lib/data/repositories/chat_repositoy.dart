import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fuocherello/helper/singletons/chat_page_logic.dart';
import 'package:fuocherello/data/datasources/chat_datasource.dart';
import 'package:fuocherello/data/datasources/product_datasource.dart';
import 'package:fuocherello/data/entities/chat/chat_data.dart';
import 'package:fuocherello/data/entities/chat/contact_data.dart';
import 'package:fuocherello/data/entities/chat/message_data.dart';
import 'package:fuocherello/data/mappers/chat_mapper.dart';
import 'package:fuocherello/domain/enums/chat_enums.dart';
import 'package:fuocherello/domain/models/app_repository.dart';
import 'package:fuocherello/domain/models/chat/chat_page_info.dart';
import 'package:fuocherello/domain/models/chat/contact.dart';
import 'package:fuocherello/domain/models/chat/init_chat_page.dart';
import 'package:fuocherello/domain/models/chat/message.dart';
import 'package:fuocherello/domain/models/chat/message_notification.dart';
import 'package:fuocherello/domain/repositories/chat_list_repository.dart';
import 'package:fuocherello/domain/repositories/chat_repository.dart';
import 'package:fuocherello/domain/repositories/user_repository.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';
import 'package:uuid_type/uuid_type.dart';

class DbChatRepository implements ChatRepository {
  //init variables
  final List<Message> messages = [];
  final List<Color> messagesColors = [];
  final Map<int, CachedNetworkImage> cachedImages = {};
  final Map<int, Image> localImages = {};
  final HashSet<String> blurredImages = HashSet<String>();

  //singleton
  final LoginManager manager = LoginManager.instance;

  final ChatDataSource datasource;

  //required repositories
  final ProductDataSource productDataSource = ProductDataSource();
  late final UserRepository publicUserRepository =
      AppRepository.instance.userRepository;
  late final ChatListRepository chatListRepository =
      AppRepository.instance.chatListRepository;
  late final ChatRepository chatRepository =
      AppRepository.instance.chatRepository;

  //controllers
  final StreamController _notificationStreamCtrl = StreamController.broadcast();
  late StreamController _newMessegeCtrl;

  @override
  Stream get notificationStream => _notificationStreamCtrl.stream;

  @override
  set messageController(StreamController s) {
    _newMessegeCtrl = s;
  }

  @override
  Stream get messageStream => _newMessegeCtrl.stream;

  ///[Chat] will use these lists to load all information about messages
  @override
  List<Color> get getMessagesColors => messagesColors;
  @override
  List<Message> get getMessages => messages;
  @override
  Map<int, CachedNetworkImage> get getChachedImages => cachedImages;
  @override
  Map<int, Image> get getLocalImages => localImages;
  @override
  HashSet<String> get getBlurredImages => blurredImages;

  DbChatRepository(this.datasource);

  @override
  Future<Contact?> fetchChatContactFromLocalDb(Uuid chatId) async {
    Map<String, Object?>? data =
        await datasource.fetchChatContactFromLocalDb(chatId);

    return ChatMapper.fromContactData(ContactData.fromMap(data));
  }

  /// [ChatPageLogic] use this function to receive messages
  /// that couldn't be received correctly due to
  /// network issues or user logout
  @override
  Future<void> getNotReceivedMessages() async {
    List<dynamic> response = await datasource.getNotReceivedMessages();
    if (response.isNotEmpty) {
      Set<String> setOfSavedChatId = response[1];
      Set<String> alreadyAddedUsers = response[2];
      List<String> messages = response[3];

      Set<String> chatIds = {};
      Map<String, List<Message>> notReceivedMessages = {};

      if (messages.isNotEmpty) {
        for (String m in messages) {
          Message messageToInsert =
              ChatMapper.fromMessageData(MessageData.fromJson(m));

          //if it's the first message with the current chat id
          if (!notReceivedMessages.containsKey(messageToInsert.chatId)) {
            //register it using the chatId as key and List<Message> as value
            notReceivedMessages.addAll({
              messageToInsert.chatId!: [messageToInsert]
            });

            //if the message is from a new chat
            if (!setOfSavedChatId.contains(messageToInsert.chatId)) {
              setOfSavedChatId.add(messageToInsert.chatId!);
              chatIds.add(messageToInsert.chatId!);
            }
          } else {
            //add message to already registered chat
            notReceivedMessages[messageToInsert.chatId]!.add(messageToInsert);
          }
        }

        //if the client received messages from new chats,
        //fetch the missing chat data from the server and
        //save it in the local db
        for (String chatId in chatIds) {
          List<Message>? chatNewMessages = notReceivedMessages[chatId];
          if (chatNewMessages != null) {
            if (!alreadyAddedUsers.contains(chatNewMessages.first.from)) {
              await fetchContactFromRemoteDbById(chatNewMessages.first.from);
            }
            var chatProduct = await productDataSource
                .getProductById(chatNewMessages.first.prodId!);

            await chatListRepository.addNewChatInLocalDb(
              ChatData(
                  id: chatId,
                  prodId: chatNewMessages.first.prodId!,
                  prodName: chatProduct["title"],
                  contactId: chatNewMessages.first.from,
                  notReadMessage: chatNewMessages.length,
                  thumbnail: ""),
            );

            //update the ui
            _newMessegeCtrl.add(chatId);
          }
        }
        _saveNotReceivedMessages(notReceivedMessages);
      }
    }
  }

  @override
  Future<void> fetchContactFromRemoteDbById(String author) async {
    await datasource.fetchContactFromRemoteDbById(author);
  }

  @override
  Future<void> addNewContactInLocalDb(ContactData data) async {
    await datasource.addNewContactInLocalDb(data);
  }

  @override
  Future<void> addNewMessageInLocalDb(MessageData message) async {
    print("ADD NEW MESSAGE IN LOCAL DB");
    await datasource.addNewMessageInLocalDb(message);
  }

  void _saveNotReceivedMessages(
      Map<String, List<Message>> notReceivedMessages) async {
    for (String chatId in notReceivedMessages.keys) {
      Message lastMessage = notReceivedMessages[chatId]!.last;
      for (Message currentMessage in notReceivedMessages[chatId]!) {
        await chatRepository
            .addNewMessageInLocalDb(ChatMapper.toMessageData(currentMessage));
      }
      await chatListRepository.updateChatTile(
          Uuid.parse(chatId), lastMessage.message);

      Contact? contact =
          await fetchChatContactFromLocalDb(Uuid.parse(lastMessage.chatId!));

      MessageNotification msgNot = MessageNotification(
        chatId: Uuid.parse(chatId),
        title: contact!.contactName,
        description: lastMessage.message,
        payload: """{"chat_id": "${lastMessage.chatId}"}""",
      );

      _notificationStreamCtrl.add(msgNot);
    }
  }

  bool isRemoteImageUrl(String input) {
    final urlPattern = RegExp(r'^https?://.*\.(jpeg|jpg|png|gif|bmp|webp)$');
    return urlPattern.hasMatch(input);
  }

  bool isLocalImagePath(String input) {
    final pathPattern = RegExp(r'^[\\\/].*\.(jpeg|jpg|png|gif|bmp|webp)$');
    return pathPattern.hasMatch(input);
  }

  // Check whether a message contains an url or a local path pointng to an image
  @override
  FileLocation isMediaMessage(String message) {
    if (isRemoteImageUrl(message)) {
      // The input is a remote URL pointing to an image.
      return FileLocation.url;
    } else if (isLocalImagePath(message)) {
      // The input is a local path pointing to an image.
      return FileLocation.local;
    } else {
      // The input is neither a remote URL nor a local path to an image.
      return FileLocation.empty;
    }
  }

  // Handle the incoming chat message
  @override
  Future<void> handleNewMessage(List<Object?>? args) async {
    // When user send / recieve the first message from a new chat the
    // [ChatLogic] instance takes some time to register the new Chat locally
    while (ChatLogic.isLoadingNewChatInfo);
    var data =
        List<Map<String, dynamic>>.from(jsonDecode(args![0]!.toString()));

    MessageData messageData = MessageData.fromMap(data.first);
    await addNewMessageInLocalDb(messageData);

    await chatListRepository.updateChatTile(
        Uuid.parse(messageData.chatId!), messageData.message);

    var contact =
        await fetchChatContactFromLocalDb(Uuid.parse(messageData.chatId!));

    MessageNotification msgNot = MessageNotification(
      chatId: Uuid.parse(messageData.chatId!),
      title: contact!.contactName,
      description: isMediaMessage(messageData.message) != FileLocation.empty
          ? '📷 Immagine'
          : messageData.message,
      payload: """{"chat_id": "${messageData.chatId}"}""",
    );

    _newMessegeCtrl.add(messageData);
    _notificationStreamCtrl.add(msgNot);
  }

  @override
  Future<List<Message>> initChatMessagesList(Uuid? chatId) async {
    messages.clear();
    List<Map<String, dynamic>> call =
        await datasource.initChatMessagesList(chatId.toString());
    messages.addAll(call
        .map((e) => ChatMapper.fromMessageData(MessageData.fromMap(e)))
        .toList());
    return messages;
  }

  @override
  void getImageFromMessage(Color myMessageColor, Color otherMessageColor) {
    for (Message m in messages) {
      if (m.from == manager.userId) {
        messagesColors.add(myMessageColor);
        if (isMediaMessage(m.message) == FileLocation.url) {
          cachedImages.addAll({
            messages.indexOf(m): CachedNetworkImage(
              imageUrl: m.message,
            )
          });
        } else if (isMediaMessage(m.message) == FileLocation.local) {
          localImages.addAll({
            messages.indexOf(m): Image.file(
              File.fromUri(Uri.parse(m.message)),
              fit: BoxFit.cover,
            )
          });
        }
      } else {
        messagesColors.add(otherMessageColor);
        if (isMediaMessage(m.message) == FileLocation.url) {
          cachedImages.addAll({
            messages.indexOf(m): CachedNetworkImage(
              imageUrl: m.message,
            )
          });
        } else if (isMediaMessage(m.message) == FileLocation.local) {
          localImages.addAll({
            messages.indexOf(m): Image.file(
              File.fromUri(Uri.parse(m.message)),
              fit: BoxFit.cover,
            )
          });
        }
      }
    }
  }

  Future<void> _sendImagesToChatServer(
      List<File> imageFiles, String chatId) async {
    try {
      print("sending image: $chatId");
      await datasource.sendImagesToChatServer(imageFiles, chatId);
      blurredImages.removeAll(imageFiles);
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  Future<ChatPageInfo?> getSavedChatInfo(Uuid chatId) async {
    Map<String, dynamic> info = await datasource.getSavedChatInfo(chatId);
    if (info.isNotEmpty) {
      print("GET CHAT INFO DATASOURCE: ${info.toString()}");

      Uuid? prodId =
          info["prod_id"] == "" ? null : Uuid.parse(info["prod_id"] as String);
      String from = manager.userId!;
      String to = info["contact_id"] as String;

      return ChatPageInfo(
        chatId: chatId,
        prodId: prodId,
        from: from,
        to: to,
        chatRepository: this,
        chatPageData: await InitChatPageData(this).initChatUi(chatId: chatId),
      );
    }
    return null;
  }

  ///image message will be put in the message list but
  ///in a loading state until its local path will be removed
  ///from the [blurredImages] List
  @override
  Future<void> insertImageMessageInList(Color myMessageColor,
      Color otherMessageColor, File file, ChatPageInfo info) async {
    String? imageReceiver = manager.userId! == info.from ? info.to : info.from;

    print(myMessageColor);
    messagesColors.add(myMessageColor);
    Message newMessage = Message(
      chatId: info.chatId.toString(),
      prodId: info.prodId.toString(),
      from: manager.userId!,
      to: imageReceiver!,
      message: file.path,
      sentAt: DateTime.now().toUtc().millisecondsSinceEpoch,
    );

    if (isMediaMessage(newMessage.message) == FileLocation.url) {
      cachedImages.addAll({
        messages.length: CachedNetworkImage(
          imageUrl: newMessage.message,
        )
      });
    } else if (isMediaMessage(newMessage.message) == FileLocation.local) {
      localImages.addAll({
        messages.length: Image.file(File.fromUri(Uri.parse(newMessage.message)))
      });
    }
    messages.add(newMessage);
    blurredImages.add(file.path);
  }

  @override
  Future<void> InsertImageMessageInLocalDb(
      List<File> files, String chatId) async {
    await _sendImagesToChatServer(files, chatId);
    var messagesToInsert =
        messages.sublist(messages.length - files.length, messages.length);
    for (var msg in messagesToInsert) {
      await addNewMessageInLocalDb(ChatMapper.toMessageData(msg));
    }
    blurredImages.clear();
  }

  @override
  Future<Uuid?> getChatId(Uuid productId, String userId) async =>
      await datasource.getChatId(productId, userId);
}
