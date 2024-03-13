import 'package:equatable/equatable.dart';
import 'package:uuid_type/uuid_type.dart';

class ChatTile extends Equatable {
  final Uuid chatId;
  final Uuid? prodId;
  final String? prodName;
  final String? contactId;
  final String? contactName;
  final String message;
  final int notReadMessage;
  final int sentAt;
  final String thumbnail;

  const ChatTile(
      this.chatId,
      this.prodId,
      this.prodName,
      this.contactId,
      this.contactName,
      this.message,
      this.notReadMessage,
      this.sentAt,
      this.thumbnail);
  @override
  List<Object?> get props => [chatId, sentAt];
}
