import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fuocherello/domain/enums/product_enums.dart';
import 'package:fuocherello/helper/singletons/db_singleton.dart';
import 'package:http/http.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid_type/uuid_type.dart';

class ProductDataSource {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  Database? db;
  //GET PRODOTTO
  Future<List<Map<String, dynamic>>> getProducts() async {
    var response = await get(
      Uri.https('www.zophirel.it:8443', '/api/product'),
      headers: <String, String>{
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
    );
    if (response.body.isEmpty) {
      return [];
    }

    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<List<Map<String, dynamic>>> getAuthorProducts(String userId) async {
    var response = await get(
      Uri.https('www.zophirel.it:8443', '/api/product/author', {'id': userId}),
      headers: <String, String>{
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
    );
    if (response.body.isEmpty) {
      return [];
    }
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<List<Map<String, dynamic>>> getUserSavedProducts() async {
    var response = await get(
      Uri.https('www.zophirel.it:8443', '/api/product/saved'),
      headers: <String, String>{
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Authentication': await _secureStorage.read(key: "access_token") ?? ""
      },
    );
    if (response.body.isEmpty) {
      return [];
    }
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<Map<String, dynamic>> getProductById(String prodId) async {
    var response = await get(
      Uri.https('www.zophirel.it:8443', '/api/product/$prodId'),
      headers: <String, String>{
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
    );

    return Map<String, dynamic>.from(json.decode(response.body)[0]);
  }

  Future<List<Map<String, dynamic>>> getProductByTipo(Category c) async {
    switch (c) {
      case Category.legname:
        return getLegname();
      case Category.biomasse:
        return getBiomasse();
      case Category.pellet:
        return getPellet();
    }
  }

  Future<List<Map<String, dynamic>>> getProductByTitolo(String input) async {
    String finalInput = input;
    var fullText = input.split(' ');
    if (fullText.length > 1) {
      finalInput = "";
      for (int i = 0; i < fullText.length; i++) {
        finalInput += i < fullText.length - 1 ? '${fullText[i]}+' : fullText[i];
      }
    }
    //full text search
    var response = await get(
      Uri.https(
          'www.zophirel.it:8443', '/api/product/title', {'q': finalInput}),
      headers: <String, String>{
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
    );

    if (response.body.isEmpty) {
      return [];
    }
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<void> saveProductInLocalDb(String id) async {
    if (db == null) {
      db = await DbSingleton.instance.database;
      await db!.insert("preferito", {"prod_id": id});
    } else {
      await db!.insert("preferito", {"prod_id": id});
    }
  }

  Future<List<Map<String, dynamic>>> getBiomasse() async {
    var response = await get(
      Uri.https('www.zophirel.it:8443', '/api/product/category',
          {'category': 'biomasse'}),
      headers: <String, String>{
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
    );

    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<List<Map<String, dynamic>>> getLegname() async {
    print("getting legname");
    var response = await get(
      Uri.https('www.zophirel.it:8443', '/api/product/category',
          {'category': 'legname'}),
      headers: <String, String>{
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
    );
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<List<Map<String, dynamic>>> getPellet() async {
    var response = await get(
      Uri.https('www.zophirel.it:8443', '/api/product/category',
          {'category': 'pellet'}),
      headers: <String, String>{
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
    );
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<List<Map<String, dynamic>>> getUserProducts() async {
    var token = await _secureStorage.read(key: "access_token");
    var response = await get(
      Uri.https(
        'www.zophirel.it:8443',
        '/api/product/saved',
      ),
      headers: <String, String>{
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Authentication': token ?? '',
      },
    );
    if (response.body.isEmpty) {
      return [];
    }
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<String> getProductThumbnailUrl(Uuid prodId) async {
    var response = await get(Uri.https(
        "www.zophirel.it:8443/api/Images/ProdottoThumbnail/${prodId.toString()}"));

    if (response.statusCode == 200) {
      return response.body;
    }

    return "";
  }
}
