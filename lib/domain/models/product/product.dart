import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:fuocherello/domain/models/product/product_dto.dart';
import 'package:fuocherello/presentation/saved/saved_card.dart';
import 'package:uuid_type/uuid_type.dart';
import '../../../presentation/product/latest_prod_card.dart';

class Product {
  final Uuid? id;
  final String author;
  final String title;
  final String description;
  final double price;
  final List<String> fileNames;
  final String place;
  final String category;
  final DateTime createdAt;

  String get imgsJson {
    String content = "";
    for (int i = 0; i < fileNames.length; i++) {
      i < fileNames.length - 1
          ? content += '"${fileNames[i]}", \n'
          : content += '"${fileNames[i]}"';
    }
    print("[\n$content\n]");
    return json.encode("[\n$content\n]");
  }

  Product(
      {required this.id,
      required this.author,
      required this.place,
      required this.title,
      required this.description,
      required this.price,
      required this.category,
      required this.fileNames,
      required this.createdAt}) {
    try {
      if (category != "legname" &&
          category != "biomasse" &&
          category != "pellet") {
        throw Exception("Categoria errata");
      }
      if (price < 0) {
        throw Exception("Prezzo errato");
      }
    } catch (e) {
      print(e);
    }
  }

  ProductDto toDto() => ProductDto(
      author: author,
      place: place,
      title: title,
      description: description,
      price: price,
      category: category,
      fileNames: fileNames,
      createdAt: createdAt);

  String getShortDate() {
    List<String> monthArr = [
      "Gen",
      "Feb",
      "Mar",
      "Apr",
      "Mag",
      "Giu",
      "Lug",
      "Ago",
      "Set",
      "Ott",
      "Nov",
      "Dic"
    ];

    DateTime now = DateTime.now();
    if (now.day == createdAt.day) {
      return "oggi alle ${createdAt.hour}:${createdAt.minute < 10 ? "0" : ""}${createdAt.minute}";
    } else if (now.day - createdAt.day == 1) {
      return "ieri alle ${createdAt.hour}:${createdAt.minute < 10 ? "0" : ""}${createdAt.minute}";
    } else {
      return "${createdAt.day} ${monthArr[createdAt.month - 1]} alle ${createdAt.hour}:${createdAt.minute < 10 ? "0" : ""}${createdAt.minute}";
    }
  }

  String getRightPrice() {
    if (price == price.floor()) {
      return "€${price.floor()}";
    } else {
      return "€${price.toStringAsFixed(2)}";
    }
  }

  Widget getProductCard([StreamController? controller]) {
    return SavedCard(
      prodotto: this,
      controller: controller,
      isSavedCard: false,
    );
  }

  Widget getSavedCard(StreamController controller) {
    return SavedCard(
      prodotto: this,
      controller: controller,
      isSavedCard: true,
    );
  }

  Widget getLatestProductCard() {
    return LatestProdCard(
      prodotto: this,
      width: 200,
    );
  }
}
