import 'dart:async';
import 'package:fuocherello/data/datasources/chat_list_datasource.dart';
import 'package:fuocherello/data/entities/chat/chat_data.dart';
import 'package:fuocherello/data/entities/chat/chat_tile_data.dart';
import 'package:fuocherello/data/entities/chat/contact_data.dart';
import 'package:fuocherello/data/entities/chat/message_data.dart';
import 'package:fuocherello/data/mappers/chat_mapper.dart';
import 'package:fuocherello/domain/enums/chat_enums.dart';
import 'package:fuocherello/domain/models/chat/chat.dart';
import 'package:fuocherello/domain/models/chat/chat_tile.dart';
import 'package:fuocherello/domain/models/chat/contact.dart';
import 'package:fuocherello/domain/models/chat/message.dart';
import 'package:fuocherello/domain/repositories/chat_list_repository.dart';
import 'package:collection/collection.dart';
import 'package:uuid_type/uuid_type.dart';

class DbChatList implements ChatListRepository {
  ChatListDataSource datasource;
  final StreamController chatListStreamController =
      StreamController.broadcast();

  DbChatList(this.datasource);
  bool areChatTilesInitialized = false;
  @override
  List<ChatTile> tiles = [];

  @override
  Stream get chatListStream => chatListStreamController.stream;

  @override
  Future<List<Chat>> fetchRemoteChats() async {
    List<Map<String, dynamic>> call = await datasource.fetchRemoteChats();
    if (call.isEmpty) {
      return [];
    }
    return call
        .map((e) => ChatMapper.fromChatData(ChatData.fromMap(e)))
        .toList();
  }

  @override
  Future<List<Contact>> fetchRemoteContacts() async {
    List<Map<String, dynamic>> call = await datasource.fetchRemoteContacts();
    if (call.isEmpty) {
      return [];
    }
    return call
        .map((e) => ChatMapper.fromContactData(ContactData.fromMap(e)))
        .toList();
  }

  @override
  Future<List<Message>> fetchRemoteMessages() async {
    List<Map<String, dynamic>?>? call = await datasource.fetchRemoteMessages();
    if (call.isEmpty) {
      return [];
    }
    return call
        .map((e) => ChatMapper.fromMessageData(MessageData.fromMap(e!)))
        .toList();
  }

  @override
  Future<void> initChatTiles() async {
    print("INIT CHAT TILES");
    if (tiles.isEmpty) {
      List<Map<String, Object?>> call = await datasource.getAllChatTiles();
      if (call.isEmpty) {
        return;
      }
      tiles.addAll(call
          .map((e) => ChatMapper.fromChatTileData(ChatTileData.fromMap(e)))
          .toList());
      tiles.sort(((a, b) => -a.sentAt.compareTo(b.sentAt)));
      areChatTilesInitialized = true;
    }
  }

  @override
  void addChatTile(ChatTile tile) async {
    if (areChatTilesInitialized) {
      tiles.add(tile);
      tiles.sort(((a, b) => -a.sentAt.compareTo(b.sentAt)));
    } else {
      await initChatTiles();
      if (!tiles.contains(tile)) {
        await updateChatTile(tile.chatId, tile.message);
      }
      areChatTilesInitialized = true;
    }
  }

  @override
  void removeChatTile(Uuid chatId) {
    ChatTile? tile =
        tiles.firstWhereOrNull((element) => element.chatId == chatId);
    if (tile != null) {
      print("FUNC removeChatTile ${tiles.remove(tile)}");
    }
  }

  @override
  Future<void> updateChatTile(Uuid chatId, String message,
      [ChatTile? tile = null]) async {
    ChatTile tileToUpdate = tile ?? await getChatTileFromLocalDb(chatId);

    await datasource.incrementChatMessageCounter(message, chatId);
    removeChatTile(chatId);
    ChatTile updatedTile = ChatTile(
        tileToUpdate.chatId,
        tileToUpdate.prodId,
        tileToUpdate.prodName,
        tileToUpdate.contactId,
        tileToUpdate.contactName,
        message,
        tileToUpdate.notReadMessage + 1,
        DateTime.now().toUtc().millisecondsSinceEpoch,
        tileToUpdate.thumbnail);
    addChatTile(updatedTile);
    chatListStreamController.add(true);
    print("HAS LISTENER: ${chatListStreamController.hasListener}");
  }

  @override
  Future<void> resetChatTile(Uuid? chatId, {String? message}) async {
    if (chatId != null) {
      ChatTile tile = await getChatTileFromLocalDb(chatId);

      await datasource.resetChatMessageCounter(chatId.toString(),
          message: message);
      removeChatTile(chatId);
      ChatTile updatedTile = ChatTile(
          tile.chatId,
          tile.prodId,
          tile.prodName,
          tile.contactId,
          tile.contactName,
          message ?? tile.message,
          0,
          DateTime.now().toUtc().millisecondsSinceEpoch,
          tile.thumbnail);
      addChatTile(updatedTile);
      print("TILES: ${tiles.length}");
      print(tiles.first.message);
      chatListStreamController.add(true);
      print("HAS LISTENER: ${chatListStreamController.hasListener}");
    }
  }

  @override
  Future<ChatTile> getChatTileFromLocalDb(Uuid chatId) async {
    ChatTileData data =
        ChatTileData.fromMap(await datasource.getChatTile(chatId.toString()));
    print("GET CHAT TILE DATA: ${data.message}");
    return ChatMapper.fromChatTileData(data);
  }

  @override
  Future<void> addNewChatInLocalDb(ChatData chat) async =>
      await datasource.addNewChatInLocalDb(chat);

  bool isRemoteImageUrl(String input) {
    final urlPattern = RegExp(r'^https?://.*\.(jpeg|jpg|png|gif|bmp|webp)$');
    return urlPattern.hasMatch(input);
  }

  bool isLocalImagePath(String input) {
    final pathPattern = RegExp(r'^[\\\/].*\.(jpeg|jpg|png|gif|bmp|webp)$');
    return pathPattern.hasMatch(input);
  }

  @override
  FileLocation isMediaMessage(String message) {
    if (isRemoteImageUrl(message)) {
      //print("The input is a remote URL pointing to an image.");
      return FileLocation.url;
    } else if (isLocalImagePath(message)) {
      //print("The input is a local path pointing to an image.");
      return FileLocation.local;
    } else {
      //print("The input is neither a remote URL nor a local path to an image.");
      return FileLocation.empty;
    }
  }

  @override
  Future<Map<String, dynamic>> fetchContactByIdFromLocalDb(
          String contact_id) async =>
      await datasource.fetchContactByIdFromLocalDb(contact_id);
}
