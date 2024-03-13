import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:fuocherello/helper/singletons/db_singleton.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';
import 'package:http/http.dart';
import 'package:sqflite/sqflite.dart';

class SaveProductButton extends StatefulWidget {
  const SaveProductButton({
    super.key,
    required this.prodotto,
    this.streamController,
    this.inBookmarkList,
  });
  final Product prodotto;
  final StreamController? streamController;
  final bool? inBookmarkList;

  @override
  State<SaveProductButton> createState() => _BookmarkProductButtonState();
}

class _BookmarkProductButtonState extends State<SaveProductButton> {
  final _secureStorage = const FlutterSecureStorage();
  Icon addProduct = const Icon(Icons.bookmark_outline);
  Icon removeProduct = const Icon(Icons.bookmark);
  late Icon currentIcon = addProduct;
  final LoginManager _manager = LoginManager.instance;
  Database? _db;

  Future<void> initLocalDb() async => _db = await DbSingleton.instance.database;

  Future<void> insertInLocalDb() async {
    await _db!.insert(
        'preferito', {"prod_id": widget.prodotto.id.toString()}).whenComplete(
      () => print('preferito aggiunto!'),
    );
  }

  Future<void> deleteFromLocalDb() async {
    await _db!.delete('preferito',
        where: "prod_id=?",
        whereArgs: [widget.prodotto.id.toString()]).whenComplete(
      () => print('preferito Rimosso!'),
    );
  }

  Future<bool> isSaved() async {
    print(widget.prodotto.id.toString());

    var isPresent = await _db!.query("preferito",
        where: 'prod_id=?', whereArgs: [widget.prodotto.id.toString()]);
    return isPresent.isNotEmpty;
  }

  Future<void> removeSavedProduct() async {
    print("deleting");
    String? token = await _secureStorage.read(key: "access_token");

    var request = await delete(
      Uri.https(
          "www.zophirel.it:8443", '/api/product/saved/${widget.prodotto.id}'),
      headers: <String, String>{
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json',
        'Accept': '*/*',
        'Authentication': token ?? '',
      },
    );

    var response = request;
    print(widget.prodotto.id);
    print(response.statusCode);

    print("SAVE ${response.statusCode}");
    if (response.statusCode == 200) {
      await deleteFromLocalDb();
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

  Future<bool> saveProduct() async {
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
        'ProdID': widget.prodotto.id.toString(),
      },
    );

    var response = await request;

    if (response.statusCode == 200) {
      await insertInLocalDb();
      mounted ? setState(() {}) : null;
      return true;
    } else {
      await _manager.isLoggedin();
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _db == null ? await initLocalDb() : null;
      var flag = await isSaved();
      flag == true ? currentIcon = removeProduct : currentIcon = addProduct;
      mounted ? setState(() {}) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        print(widget.inBookmarkList);
        if (widget.inBookmarkList == null) {
          currentIcon = currentIcon == addProduct ? removeProduct : addProduct;
        } else {
          currentIcon = addProduct;
        }
        setState(() {});
        if (currentIcon == addProduct) {
          widget.streamController?.add(widget.prodotto);
          print(widget.prodotto.title);
          await removeSavedProduct();
        } else if (widget.inBookmarkList == null) {
          widget.streamController?.add(widget.prodotto);
          await saveProduct();
        }
      },
      icon: currentIcon,
    );
  }
}
