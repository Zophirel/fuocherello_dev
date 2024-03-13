import 'dart:ui';
import 'package:fuocherello/domain/models/chat/message.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';

void copy(
    int index,
    bool isUserChatOwner,
    List<Message> messages,
    List<Message> selectedMessages,
    List<Color?> messagesColors,
    Color myMessageColor,
    Color otherMessageColor,
    Color hoverMyMessageColor,
    Color hoverOtherMessageColor) {
  if (selectedMessages.isNotEmpty) {
    if (messagesColors[index] == hoverMyMessageColor ||
        messagesColors[index] == hoverOtherMessageColor) {
      // remove message from being copied
      selectedMessages.remove(messages[index]);
      if (isUserChatOwner) {
        messagesColors[index] = myMessageColor;
      } else {
        messagesColors[index] = otherMessageColor;
      }
    } else {
      // add message to copy
      selectedMessages.add(messages[index]);
      messages[index].from == LoginManager.instance.userId
          ? messagesColors[index] = hoverMyMessageColor
          : messagesColors[index] = hoverOtherMessageColor;
    }
  }
}
