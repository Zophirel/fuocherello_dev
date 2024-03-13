import 'package:flutter/material.dart';
import 'package:fuocherello/domain/models/chat/chat_page_info.dart';
import 'package:fuocherello/domain/models/chat/chat_tile.dart';
import 'package:fuocherello/domain/repositories/chat_list_repository.dart';
import 'package:fuocherello/domain/repositories/chat_repository.dart';
import 'package:go_router/go_router.dart';

class ChatTileOnPressed {
  ChatRepository chatRepository;
  ChatListRepository chatListRepository;
  ChatTileOnPressed(this.chatRepository, this.chatListRepository);

  void execute(BuildContext context, ChatTile tile) async {
    print("PRESSIN EXISTING TILE");
    ChatPageInfo info =
        ChatPageInfo(chatId: tile.chatId, chatRepository: chatRepository);
    if (tile.notReadMessage > 0) {
      await chatListRepository.resetChatTile(tile.chatId);
    }

    info.getInfo().then((completeInfo) {
      print("ALL INFO COMPLETE ${completeInfo.allInfoPresent}");
      context.pushNamed("chat", extra: completeInfo);
    });
  }
}
