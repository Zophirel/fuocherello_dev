import 'dart:async';
import 'package:fuocherello/data/entities/chat/chat_data.dart';
import 'package:fuocherello/domain/enums/chat_enums.dart';
import 'package:fuocherello/domain/models/chat/chat.dart';
import 'package:fuocherello/domain/models/chat/chat_tile.dart';
import 'package:fuocherello/domain/models/chat/contact.dart';
import 'package:fuocherello/domain/models/chat/message.dart';
import 'package:uuid_type/uuid_type.dart';

//functions used to manage the data used by [ChatList] screen
abstract class ChatListRepository {
  Stream get chatListStream;
  List<ChatTile> get tiles;
  Future<Map<String, dynamic>> fetchContactByIdFromLocalDb(String contact_id);
  Future<void> initChatTiles();
  void addChatTile(ChatTile tile);
  void removeChatTile(Uuid chatId);
  Future<void> updateChatTile(Uuid chatId, String message);
  Future<void> resetChatTile(Uuid? chatId, {String? message});
  Future<ChatTile> getChatTileFromLocalDb(Uuid chatId);
  Future<List<Contact>> fetchRemoteContacts();
  Future<List<Chat>> fetchRemoteChats();
  Future<List<Message>> fetchRemoteMessages();
  Future<void> addNewChatInLocalDb(ChatData chat);
  FileLocation isMediaMessage(String message);
}
