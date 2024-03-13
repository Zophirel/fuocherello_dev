import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuocherello/domain/repositories/saved_product_repository.dart';
import 'package:fuocherello/helper/singletons/db_singleton.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';
import 'package:http/http.dart';
import 'package:sqflite/sqflite.dart';

class DbSavedProducts implements SavedProductRepository {
  final _secureStorage = const FlutterSecureStorage();
  final LoginManager _manager = LoginManager.instance;
  Database? _db;

  @override
  Future<void> initLocalDb() async => _db = await DbSingleton.instance.database;

  @override
  Future<void> insertInLocalDb(String prodId) async {
    await _db!.insert('preferito', {"prod_id": prodId}).whenComplete(
      () => print('preferito aggiunto!'),
    );
  }

  @override
  Future<void> deleteFromLocalDb(String prodId) async {
    await _db!.delete('preferito',
        where: "prod_id=?", whereArgs: [prodId]).whenComplete(
      () => print('preferito Rimosso!'),
    );
  }

  @override
  Future<bool> isSaved(String prodId) async {
    print(prodId);

    var isPresent =
        await _db!.query("preferito", where: 'prod_id=?', whereArgs: [prodId]);
    return isPresent.isNotEmpty;
  }

  @override
  Future<void> removeSavedProduct(String prodId) async {
    print("deleting");
    String? token = await _secureStorage.read(key: "access_token");

    var request = await delete(
      Uri.https("www.zophirel.it:8443", '/api/product/saved/$prodId'),
      headers: <String, String>{
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Authentication': token ?? '',
      },
    );

    var response = request;
    print(response.statusCode);

    print("SAVE ${response.statusCode}");
    if (response.statusCode == 200) {
      await deleteFromLocalDb(prodId);
    } else {
      Fluttertoast.showToast(
        msg: "Errore di connessione al db locale",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Future<bool> saveProduct(String prodId) async {
    print("adding");
    String? token = await _secureStorage.read(key: "access_token");
    if (token == null) {
      Fluttertoast.showToast(
        msg: "Accedi per poter salvare i prodotti",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false;
    }

    Future<Response> request = post(
      Uri.https('www.zophirel.it:8443', '/api/product/saved'),
      headers: <String, String>{
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Authentication': token,
        'ProdID': prodId,
      },
    );

    var response = await request;

    if (response.statusCode == 200) {
      await insertInLocalDb(prodId);
      return true;
    } else {
      await _manager.isLoggedin();
      return false;
    }
  }
}
