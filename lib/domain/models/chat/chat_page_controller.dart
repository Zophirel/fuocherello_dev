// chat_page_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fuocherello/data/mappers/chat_mapper.dart';
import 'package:fuocherello/domain/models/chat/chat_page_info.dart';
import 'package:fuocherello/domain/models/chat/message.dart';
import 'package:fuocherello/domain/repositories/chat_list_repository.dart';
import 'package:fuocherello/domain/repositories/chat_repository.dart';
import 'package:fuocherello/helper/singletons/chat_page_logic.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';
import 'package:fuocherello/helper/singletons/path_checker.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid_type/uuid_type.dart';

class ChatPageController {
  static Future<void> handleBackPressed(
    BuildContext context,
    Uuid? chatId,
    List<Message> messages,
    List<Color?> messagesColors,
    ChatListRepository chatListRepository,
    VoidCallback setStateCallback, // Callback for updating UI
  ) async {
    PathChecker.isChatOpen = false;
    try {
      await chatListRepository.resetChatTile(chatId);
      messages.clear();
      messagesColors.clear();
      setStateCallback(); // Update UI
      while (context.canPop()) {
        context.pop();
      }
      context.replaceNamed("chatList");
    } on Exception {
      messages.clear();
      messagesColors.clear();
      setStateCallback(); // Update UI
      while (context.canPop()) {
        context.pop();
      }
      context.replaceNamed("chatList");
    }
  }

  static Future<void> sendMessage({
    required TextEditingController messageCtrl,
    required Uuid? chatId,
    required String prodId,
    required String from,
    required String to,
    required ChatLogic chatLogic,
    required ChatRepository chatRepository,
    required ChatListRepository chatListRepository,
    required FlutterSecureStorage secureStorage,
    required List<Message> messages,
    required List<Color?> messagesColors,
    required LoginManager manager,
    required ChatPageInfo info,
    required VoidCallback setStateCallback,
  }) async {
    if (messageCtrl.text.isNotEmpty) {
      var sub = chatLogic.signalrStream.listen((event) {
        print("chat id received from signalr event");
        chatId = Uuid.parse(event as String);
      });

      // Gather new message info
      Message clearMessage = Message(
        chatId: chatId.toString(),
        prodId: prodId,
        from: from,
        to: to,
        message: messageCtrl.text,
        sentAt: DateTime.now().toUtc().millisecondsSinceEpoch,
      );

      // Determine message color
      Color? selectedColor;
      messageCtrl.text = "";
      selectedColor =
          manager.userId! == from ? Colors.grey[200] : Colors.blue[200];

      // Add message to repository message list
      messagesColors.add(selectedColor);
      messages.add(clearMessage);

      // Update UI before ensuring message delivery
      // No setState here as it's outside the widget
      setStateCallback();

      // Invoke signalr method for message delivery
      await chatLogic.hubConnection.invoke(
        "SendMessage",
        args: [
          ChatMapper.toMessageData(clearMessage).toJson(),
          (await secureStorage.read(key: "access_token"))!,
        ],
      );

      // Set a delay used for the first message
      Future.delayed(const Duration(seconds: 1), () async {
        // Check for chat ID assignment
        for (int i = 0; i < 5; i++) {
          if (chatId == "") {
            await Future.delayed(const Duration(seconds: 1));
          } else {
            clearMessage.chatId = (chatId ?? info.chatId).toString();
            await chatRepository
                .addNewMessageInLocalDb(ChatMapper.toMessageData(clearMessage));
            await chatListRepository.resetChatTile(chatId,
                message: clearMessage.message);
            return;
          }
        }

        // Remove the message from the UI if the server did not receive it
        if (chatId == "") {
          print("chat id not assigned");
          // No setState here as it's outside the widget
          messages.remove(selectedColor);
          messages.remove(clearMessage);
          setStateCallback();
        }
      });

      sub.cancel();
    }
  }
}
