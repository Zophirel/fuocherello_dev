import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fuocherello/data/entities/chat/chat_data.dart';
import 'package:fuocherello/helper/singletons/db_singleton.dart';
import 'package:http/http.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid_type/uuid_type.dart';

class ChatListDataSource {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  Database? _db;

  Future<void> _initLocalDb() async {
    _db = await DbSingleton.instance.database;
  }

  Future<Map<String, dynamic>> fetchContactByIdFromLocalDb(
      String contact_id) async {
    _db == null ? await _initLocalDb() : null;

    var contatto = await _db!.query(
      "lista_contatto",
      where: "contact_id = ?",
      whereArgs: [contact_id],
    );
    if (contatto.isNotEmpty) {
      return contatto.first;
    } else {
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> fetchRemoteContacts() async {
    //[ contact_id TEXT ] [ contact_name TEXT ]
    var token = await _secureStorage.read(key: 'access_token');
    var response = await get(
        Uri.https("www.zophirel.it:8443", "/api/user/contacts"),
        headers: <String, String>{
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'Authentication': token!
        });
    print("RESPONSE BODY ${response.statusCode}");
    if (response.statusCode == 204) {
      return List.empty();
    }
    print(json.decode(response.body));

    print("RESPONSE BODY ${response.statusCode}");
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<List<Map<String, dynamic>>> fetchRemoteChats() async {
    var token = await _secureStorage.read(key: 'access_token');
    var response = await get(
        Uri.https("www.zophirel.it:8443", "/api/user/chat"),
        headers: <String, String>{
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'Authentication': token!
        });

    print("RESPONSE BODY ${response.statusCode}");
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<List<Map<String, dynamic>>> fetchRemoteMessages() async {
    var token = await _secureStorage.read(key: 'access_token');
    var response = await get(
        Uri.https("www.zophirel.it:8443", "/api/user/messages"),
        headers: <String, String>{
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'Authentication': token!
        });

    print("RESPONSE BODY ${response.body}");
    if (response.body.isEmpty) {
      return [];
    }
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<List<Map<String, Object?>>> getAllChatTiles() async {
    _db == null ? await _initLocalDb() : null;
    var q = await _db!.rawQuery(
      """
      SELECT
          lc.contact_name AS contact_name,
          lc.contact_id AS contact_id,
          lch.id AS chat_id,
          lch.prod_id AS prod_id,
          lch.prod_name AS prod_name,
          lch.not_read_message AS not_read_message,
          lch.thumbnail as thumbnail,
          cm.message,
          cm.sent_at
      FROM
          lista_contatto lc
      JOIN
          lista_chat lch ON lc.contact_id = lch.contact_id
      LEFT JOIN
          chat_message cm ON lch.id = cm.chat_id
      WHERE
          cm.sent_at = (
              SELECT MAX(sent_at)
              FROM chat_message
              WHERE chat_id = lch.id
          )
      ORDER BY
          sent_at DESC;
      """,
    );
    print("INIT ALL CHAT TILES ${q}");
    return q;
  }

  Future<Map<String, Object?>> getChatTile(String chatId) async {
    _db == null ? await _initLocalDb() : null;
    var q = await _db!.rawQuery(
      """
      SELECT 
          lc.id,
          lc.prod_id,
          lc.prod_name,
          lc.contact_id,
          lc_c.contact_name,
          lc.not_read_message,
          lc.thumbnail,
          cm.message,
          cm.sent_at
      FROM 
          lista_chat AS lc
      LEFT JOIN (
          SELECT chat_id, MAX(sent_at) AS max_sent_at
          FROM chat_message
          GROUP BY chat_id
      ) AS latest_msg
      ON lc.id = latest_msg.chat_id
      LEFT JOIN chat_message AS cm
      ON latest_msg.chat_id = cm.chat_id AND latest_msg.max_sent_at = cm.sent_at
      LEFT JOIN lista_contatto AS lc_c
      ON lc.contact_id = lc_c.contact_id
      WHERE 
          lc.id = '$chatId'
      ORDER BY cm.sent_at;

      """,
    );
    return q.last;
  }

  Future<void> incrementChatMessageCounter(String message, Uuid chatId,
      [int numberOfMessages = 1]) async {
    _db == null ? await _initLocalDb() : null;
    await _db!.rawUpdate(
        "UPDATE lista_chat SET not_read_message = not_read_message + $numberOfMessages WHERE id = ?;",
        [chatId.toString()]);
  }

  Future<void> resetChatMessageCounter(String chatId, {String? message}) async {
    _db == null ? await _initLocalDb() : null;

    await _db!.rawUpdate(
      message != null
          ? "UPDATE lista_chat SET not_read_message = 0 AND last_message = ? WHERE id = ?"
          : "UPDATE lista_chat SET not_read_message = 0 WHERE id = ?",
      message != null ? [message, chatId] : [chatId],
    );
  }

  Future<void> addNewChatInLocalDb(ChatData chat) async {
    _db == null ? await _initLocalDb() : null;

    try {
      await _db!.insert("lista_chat", {
        "id": chat.id,
        "prod_id": chat.prodId,
        "prod_name": chat.prodName,
        "contact_id": chat.contactId,
        "not_read_message": 0,
        "thumbnail": chat.thumbnail
      });
    } on DatabaseException {
      await _db!.delete('lista_chat', where: "id = ?", whereArgs: [chat.id]);
      await _db!.insert("lista_chat", {
        "id": chat.id,
        "prod_id": chat.prodId,
        "prod_name": chat.prodName,
        "contact_id": chat.contactId,
        "not_read_message": 0,
        "thumbnail": chat.thumbnail
      });
    }
  }
}
