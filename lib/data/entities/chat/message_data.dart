import 'dart:convert';
import 'package:fuocherello/domain/enums/chat_enums.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';
import 'package:uuid_type/uuid_type.dart';

///Class to rapresent the data needed to parse to create [Message] objects

class MessageData {
  String? id;
  String? chatId;
  String? prodId;
  late String from;
  late String to;
  late String message;
  late int sentAt;
  FileLocation location = FileLocation.empty;

  MessageData({
    this.id,
    this.chatId,
    this.prodId,
    required this.from,
    required this.to,
    required this.message,
    required this.sentAt,
  });

  bool isMessageEmpty() {
    if (message.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  MessageData.fromJson(String data) {
    try {
      print("JSON DATA $data");
      Map<String, dynamic> decodedData =
          Map<String, dynamic>.from(jsonDecode(data));
      print("DECODED DATA ");
      print(
          "${decodedData["chat_id"]} - ${decodedData["prod_id"]} - ${decodedData["from"]} - ${decodedData["to"]} - ${decodedData["message"]} - ${decodedData["sent_at"]}");
      for (var key in decodedData.keys) {
        print(key);
      }
      chatId = decodedData["chat_id"];
      prodId = decodedData["prod_id"];
      from = decodedData["from"];
      to = decodedData["to"] ?? LoginManager.instance.userId;
      message = decodedData["message"].toString();
      sentAt = int.parse(decodedData["sent_at"]);
    } catch (e) {
      print(e);
    }
  }

  MessageData.fromLocalDbMap(Map<String, dynamic> data) {
    //id TEXT PRIMARY KEY, chat_id TEXT NOT NULL, message TEXT NOT NULL, sender TEXT NOT NULL, receiver TEXT NOT NULL, sent_at INTEGER
    id = data["id"].toString();
    chatId = data["chat_id"].toString();
    prodId = data["prod_id"].toString();
    from = data["sender_id"].toString();
    to = data["receiver_id"].toString();
    message = data["message"].toString();
    sentAt = int.parse(data["sent_at"].toString());
  }

  MessageData.fromMap(Map<String, dynamic> data) {
    //id TEXT PRIMARY KEY, chat_id TEXT NOT NULL, message TEXT NOT NULL, sender TEXT NOT NULL, receiver TEXT NOT NULL, sent_at INTEGER

    id = RandomUuidGenerator().toString();
    chatId = data["chat_id"] ?? data["id"].toString();
    prodId = data["prod_id"].toString();
    from = (data["sender_id"] ?? data["sender"]).toString();
    to = (data["receiver_id"] ?? data["receiver"]).toString();
    message = data["message"].toString();
    sentAt = int.parse((data["sent_at"] ?? data["sent_at"]).toString());
  }

  String toJson() {
    chatId = chatId ?? "";
    return '{"chat_id": "$chatId", "prod_id" : "$prodId", "from": "$from", "to" : "$to", "message": "$message", "sent_at": "$sentAt"}';
  }
}
