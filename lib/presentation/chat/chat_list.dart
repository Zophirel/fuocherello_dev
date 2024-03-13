import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:fuocherello/domain/enums/chat_enums.dart';
import 'package:fuocherello/domain/models/chat/chat_tile.dart';
import 'package:fuocherello/domain/repositories/chat_list_repository.dart';
import 'package:fuocherello/domain/repositories/chat_repository.dart';
import 'package:fuocherello/domain/usecases/chat_list/chat_tile_on_pressed.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';
import 'package:fuocherello/helper/singletons/path_checker.dart';

//ui of the screen that contains all the started chat
class ChatList extends StatefulWidget {
  ChatList(
      {super.key,
      required this.chatListRepository,
      required this.chatRepository});
  final ChatListRepository chatListRepository;
  final ChatRepository chatRepository;
  late final ChatTileOnPressed onPressed =
      ChatTileOnPressed(chatRepository, chatListRepository);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  //init variables
  List<ChatTile> get chatTiles => widget.chatListRepository
      .tiles; //as for chat messages, chat tiles are stored in the repository list
  Stream get chatListStream => widget.chatListRepository
      .chatListStream; //stream to listen for new chats or edit the last message

  late ScrollController _scrollViewController;
  bool isScrollingDown = false;
  late StreamSubscription sub;

  //singleton
  LoginManager manager = LoginManager.instance;

  @override
  void initState() {
    super.initState();
    PathChecker.setLocation = "/chatlist";

    print("chat tiles length: ${chatTiles.length}");

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.chatListRepository.initChatTiles();
      print("CHAT TILES: ${chatTiles.length}");
      setState(() {});
    });

    sub = chatListStream.listen((event) async {
      if (event is bool && event) {
        print("MESSAGGIO INVIATO O RICEVUTO");
        mounted ? setState(() {}) : null;
      }
    });

    //when the user logout the tiles containing chats info are deleted
    manager.userLoggingStream.listen((event) async {
      widget.chatListRepository.tiles.clear();
      mounted ? setState(() {}) : null;
    });

    _scrollViewController = ScrollController();
    _scrollViewController.addListener(() {
      if (_scrollViewController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          showAppbar = false;
          mounted ? setState(() {}) : null;
        }
      }

      if (_scrollViewController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          showAppbar = true;
          mounted ? setState(() {}) : null;
        }
      }
    });
  }

  @override
  void dispose() {
    sub.cancel();
    _scrollViewController.dispose();
    _scrollViewController.removeListener(() {});
    super.dispose();
  }

  bool showAppbar = true;
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;
  @override
  Widget build(BuildContext context) {
    PathChecker.isChatOpen ? "" : PathChecker.setLocation = "/chatlist";
    print(PathChecker.getCurrentLocation);
    return Column(
      children: [
        AnimatedContainer(
          margin: showAppbar
              ? const EdgeInsets.only(top: 20)
              : const EdgeInsets.only(top: 0),
          height: showAppbar ? 50.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: AppBar(
            scrolledUnderElevation: 0.0,
            centerTitle: true,
            title: const Text(
              "Messaggi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.background,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: CustomScrollView(
              controller: _scrollViewController,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: chatTiles.length,
                    (context, index) {
                      bool isMedia = false;
                      FileLocation location = widget.chatRepository
                          .isMediaMessage(chatTiles[index].message);
                      if (location == FileLocation.url ||
                          location == FileLocation.local) {
                        isMedia = true;
                      }
                      return Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: ListTile(
                          onTap: () async {
                            widget.onPressed.execute(context, chatTiles[index]);
                          },
                          leading: SizedBox(
                            width: 50,
                            height: 50,
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(900)),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl:
                                    "https://fuocherello-bucket.s3.cubbit.eu/products/${chatTiles[index].contactId}/${chatTiles[index].prodId}/${chatTiles[index].thumbnail}",
                                errorWidget: (context, url, error) =>
                                    CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl:
                                            "https://fuocherello-bucket.s3.cubbit.eu/products/${manager.userId}/${chatTiles[index].prodId}/${chatTiles[index].thumbnail}"),
                              ),
                            ),
                          ),
                          title: Text(
                            chatTiles[index].contactName ?? "Account eliminato",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(chatTiles[index].prodName == ""
                                  ? "Prodotto eliminato"
                                  : chatTiles[index].prodName!),
                              Text(isMedia
                                  ? "📷 Immagine"
                                  : chatTiles[index].message)
                            ],
                          ),
                          trailing: chatTiles[index].notReadMessage > 0
                              ? Container(
                                  height: 25,
                                  width: 25,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(100),
                                    ),
                                  ),
                                  child: Text(
                                    chatTiles[index].notReadMessage.toString(),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
