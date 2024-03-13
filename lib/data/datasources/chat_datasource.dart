import 'dart:async';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fuocherello/data/entities/chat/chat_data.dart';
import 'package:fuocherello/data/entities/chat/contact_data.dart';
import 'package:fuocherello/data/entities/chat/message_data.dart';
import 'package:fuocherello/domain/models/app_repository.dart';
import 'package:fuocherello/domain/models/user/public_user.dart';
import 'package:fuocherello/helper/singletons/db_singleton.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid_type/uuid_type.dart';

class ChatDataSource {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Database? _db;

// Initialize the local database.
  Future<void> _initLocalDb() async {
    _db = await DbSingleton.instance.database;
  }

// Retrieve messages that have not been received by the user.
// This method communicates with the remote API to fetch messages.
  Future<List<dynamic>> getNotReceivedMessages() async {
    var token = await _secureStorage.read(key: "access_token");
    _db == null ? await _initLocalDb() : null;

    if (token != null) {
      var response = await get(
          Uri.https("www.zophirel.it:8443", "api/user/messages/latest"),
          headers: {
            "Authentication": token,
          });

      if (response.statusCode == 200) {
        List<Map<String, Object?>> savedChat =
            await _db!.query("lista_chat", columns: ["id", "contact_id"]);
        Set<String> setOfSavedChatId =
            savedChat.map((e) => e["id"].toString()).toSet();
        Set<String> alreadyAddedUsers =
            savedChat.map<String>((e) => e["contact_id"].toString()).toSet();

        List<String> responseData = [];
        String p = response.body;

        if (p != "[]" && p.isNotEmpty) {
          p = p.substring(1, p.length - 1).replaceAll("},", "} ");
          responseData = p.split(" ");
        }
        print([savedChat, setOfSavedChatId, alreadyAddedUsers, responseData]);
        return [savedChat, setOfSavedChatId, alreadyAddedUsers, responseData];
      }
    }

    return [];
  }

// Fetch chat contact information from the local database based on the provided chat ID.
  Future<Map<String, Object?>>? fetchChatContactFromLocalDb(Uuid chatId) async {
    _db == null ? await _initLocalDb() : null;
    var query = await _db!.rawQuery("""
    SELECT DISTINCT lista_chat.prod_id, lista_chat.prod_name, lista_chat.contact_id, 
    lista_contatto.contact_name, lista_chat.not_read_message, chat_message.sent_at, chat_message.message
    FROM lista_chat, lista_contatto, chat_message
    WHERE lista_chat.id = ?;
    """, [chatId.toString()]);
    return query[0];
  }

// Add a new message to the local database.
  Future<void> addNewMessageInLocalDb(MessageData message) async {
    _db == null ? await _initLocalDb() : null;
    var id = RandomUuidGenerator().generate();

    await _db!.insert(
      "chat_message",
      {
        "id": id.toString(),
        "chat_id": message.chatId,
        "message": message.message,
        "sender": message.from,
        "receiver": message.to,
        "sent_at": DateTime.now().toUtc().millisecondsSinceEpoch,
      },
    );
  }

// Add a new chat to the local database.
  Future<void> addNewChatInLocalDb(ChatData chat) async {
    await _db!.insert("lista_chat", {
      "id": chat.id,
      "prod_id": chat.prodId,
      "prod_name": chat.prodName,
      "contact_id": chat.contactId,
      "not_read_message": 0
    });
  }

// Fetch contact information from the remote database based on the provided user ID.
  Future<void> fetchContactFromRemoteDbById(String author) async {
    _db == null ? await _initLocalDb() : null;

    PublicUser data = await AppRepository.instance.publicUserRepository
        .getOtherUserPublicInfo(author);

    await _db!.insert("lista_contatto", {
      "contact_id": author,
      "contact_name": data.name,
    });
  }

// Add a new contact to the local database.
  Future<void> addNewContactInLocalDb(ContactData data) async {
    _db == null ? await _initLocalDb() : null;
    await _db!.insert("lista_contatto", {
      "contact_id": data.contactId,
      "contact_name": data.contactName,
    });
  }

// Initialize the chat messages list for a given chat ID.
  Future<List<Map<String, Object?>>> initChatMessagesList(String chatId) async {
    _db == null ? await _initLocalDb() : null;
    final List<Map<String, dynamic>> rows = await _db!.rawQuery('''
      SELECT chat_message.*, lista_chat.prod_id
      FROM chat_message
      JOIN lista_chat ON chat_message.chat_id = lista_chat.id
      WHERE chat_message.chat_id = ?
    ''', [chatId]);

    print("ROWS :${rows.toString()}");
    return rows;
  }

// Send images to the chat server.
  Future<void> sendImagesToChatServer(
      List<File> imageFiles, String chatId) async {
    var uri = Uri.parse("https://www.zophirel.it:8443/api/images/chat");
    var request = MultipartRequest("PUT", uri);
    List<MultipartFile> multipartFile = [];

    for (File imageFile in imageFiles) {
      var fileName = imageFile.path;
      var stream = ByteStream(Stream.castFrom(imageFile.openRead()));
      var length = await imageFile.length();
      multipartFile.add(
        MultipartFile(
          'files',
          stream,
          length,
          filename: basename(fileName),
          contentType: MediaType.parse('image/jpeg'),
        ),
      );
    }
    request.files.addAll(multipartFile);

    request.headers.addAll({
      "Content-Type": "multipart/form-data",
      "Accept": "application/json",
      "Authentication": await _secureStorage.read(key: "access_token") ?? "",
      "ChatId": chatId
    });

    var streamResponse = await request.send();
    var response = await Response.fromStream(streamResponse);

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception("${response.statusCode} ${response.body}");
    }
  }

// Retrieve information about a saved chat from the local database.
  Future<Map<String, dynamic>> getSavedChatInfo(Uuid chatId) async {
    _db == null ? await _initLocalDb() : null;
    var q = await _db!
        .query("lista_chat", where: "id = ?", whereArgs: [chatId.toString()]);
    return q.isNotEmpty ? q[0] : {};
  }

// Retrieve the chat ID for a given product ID and user ID from the local database.
  Future<Uuid?> getChatId(Uuid prodottoId, String userId) async {
    _db == null ? await _initLocalDb() : null;
    var q = await _db!.query("lista_chat",
        where: "prod_id = ? AND contact_id = ?",
        whereArgs: [prodottoId.toString(), userId]);

    return q.isEmpty ? null : Uuid.parse(q[0]["id"] as String);
  }
}
