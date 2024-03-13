import 'package:uuid_type/uuid_type.dart';

/// Class to rapresent the data needed to build tile for the [ChatList]
class ChatTileData {
  Uuid? chatId;
  Uuid? prodId;
  String? prodName;
  String? contactId;
  String? contactName;
  String? message;
  int? notReadMessage;
  int? sentAt;
  String? thumbnail;

  ChatTileData(
      this.chatId,
      this.prodId,
      this.prodName,
      this.contactId,
      this.contactName,
      this.message,
      this.notReadMessage,
      this.sentAt,
      this.thumbnail);

  ChatTileData.fromMap(Map<String, Object?> data) {
    print(data);
    chatId = Uuid.parse((data["chat_id"] ?? data["id"]) as String);
    prodId =
        data["prod_id"] == "" ? null : Uuid.parse(data["prod_id"] as String);
    prodName = data["prod_name"] as String;
    contactId = data["contact_id"] as String;
    contactName = data["contact_name"] as String;
    message = data["message"] as String;
    notReadMessage = data["not_read_message"] as int;
    sentAt = data["sent_at"] as int;
    thumbnail = data["thumbnail"] as String;
  }
}
