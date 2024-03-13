import 'package:fuocherello/helper/notification_manager.dart';
import 'package:uuid_type/uuid_type.dart';

class MessageNotification {
  final Uuid? chatId;
  final String? title;
  final String? description;
  final String? payload;

  MessageNotification(
      {this.chatId, this.title, this.description, this.payload});

  void showNotification() {
    NotificationManager.showNotification(
        id: 0, title: title!, body: description!, payload: payload!);
  }
}
