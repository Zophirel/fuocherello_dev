import 'package:fuocherello/domain/enums/chat_enums.dart';

class Message {
  String? id;
  String? chatId;
  String? prodId;
  late String from;
  late String to;
  late String message;
  late int sentAt;
  FileLocation location = FileLocation.empty;

  Message({
    this.id,
    this.chatId,
    this.prodId,
    required this.from,
    required this.to,
    required this.message,
    required this.sentAt,
  });
}
