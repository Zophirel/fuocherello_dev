import 'package:fuocherello/data/entities/chat/contact_data.dart';
import 'package:fuocherello/data/entities/chat/message_data.dart';
import 'package:fuocherello/data/entities/chat/chat_tile_data.dart';
import 'package:fuocherello/data/entities/chat/chat_data.dart';
import 'package:fuocherello/domain/models/chat/chat.dart';
import 'package:fuocherello/domain/models/chat/contact.dart';
import 'package:fuocherello/domain/models/chat/chat_tile.dart';
import '../../domain/models/chat/message.dart';

class ChatMapper {
  static Contact fromContactData(ContactData data) => Contact(
        contactId: data.contactId,
        contactName: data.contactName,
      );

  static ContactData toContactData(Contact contact) => ContactData(
        contactId: contact.contactId,
        contactName: contact.contactName,
      );

  static Chat fromChatData(ChatData data) => Chat(
      id: data.id,
      prodId: data.prodId,
      prodName: data.prodName,
      contactId: data.contactId,
      notReadMessage: data.notReadMessage,
      thumbnail: data.thumbnail);

  static ChatData toChatData(Chat chat) => ChatData(
      id: chat.id,
      prodId: chat.prodId,
      prodName: chat.prodName,
      contactId: chat.contactId,
      notReadMessage: chat.notReadMessage,
      thumbnail: chat.thumbnail);

  static Message fromMessageData(MessageData data) => Message(
      id: data.id,
      chatId: data.chatId,
      prodId: data.prodId,
      from: data.from,
      to: data.to,
      message: data.message,
      sentAt: data.sentAt);

  static MessageData toMessageData(Message message) => MessageData(
      id: message.id,
      chatId: message.chatId,
      prodId: message.prodId,
      from: message.from,
      to: message.to,
      message: message.message,
      sentAt: message.sentAt);

  static ChatTile fromChatTileData(ChatTileData data) => ChatTile(
        data.chatId!,
        data.prodId,
        data.prodName,
        data.contactId,
        data.contactName,
        data.message!,
        data.notReadMessage!,
        data.sentAt!,
        data.thumbnail ?? "",
      );

  static ChatTileData toData(ChatTile tile) => ChatTileData(
      tile.chatId,
      tile.prodId,
      tile.prodName,
      tile.contactId,
      tile.contactName,
      tile.message,
      tile.notReadMessage,
      tile.sentAt,
      tile.thumbnail);
}
