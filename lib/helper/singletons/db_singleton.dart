import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//singleton to manage the local sqlite db
class DbSingleton {
  static final DbSingleton _db = DbSingleton._internal();
  DbSingleton._internal();
  static DbSingleton get instance => _db;
  static Database? _database;
  static const String databaseName = "fuocherello.db";
  static bool isDbOpen = false;

  Future<Database?> get database async {
    _database = await _init();
    isDbOpen = true;
    return _database;
  }

  static Future cleanDatabase() async {
    try {
      await _database?.transaction((txn) async {
        var batch = txn.batch();
        batch.delete("preferito");
        batch.delete("lista_contatto");
        batch.delete("lista_chat");
        batch.delete("chat_message");
        await batch.commit();
        print("BATCH COMMIT");
      });
    } catch (error) {
      throw Exception('DbBase.cleanDatabase: $error');
    }
  }

  Future<Database> _init() async {
    return await openDatabase(
      join(await getDatabasesPath(), databaseName),
      onCreate: (db, version) {
        db.execute(
            "CREATE TABLE IF NOT EXISTS preferito (prod_id TEXT PRIMARY KEY);");
        db.execute(
            "CREATE TABLE IF NOT EXISTS lista_contatto (contact_id TEXT PRIMARY KEY, contact_name TEXT NOT NULL);");
        db.execute(
            "CREATE TABLE IF NOT EXISTS lista_chat (id TEXT PRIMARY KEY, prod_id TEXT NOT NULL, prod_name TEXT NOT NULL, contact_id TEXT, not_read_message INTEGER NOT NULL DEFAULT 0, thumbnail TEXT, FOREIGN KEY(contact_id) REFERENCES lista_contatto(contact_id) ON DELETE CASCADE);");
        db.execute(
            "CREATE TABLE IF NOT EXISTS chat_message (id TEXT PRIMARY KEY, chat_id TEXT NOT NULL, message TEXT NOT NULL, sender TEXT NOT NULL, receiver TEXT NOT NULL, sent_at INTEGER NOT NULL);");
      },
      version: 1,
    );
  }
}
