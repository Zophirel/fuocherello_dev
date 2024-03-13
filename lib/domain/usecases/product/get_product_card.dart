import 'dart:async';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:fuocherello/presentation/saved/saved_card.dart';

class GetProductCard {
  final Product product;
  StreamController<dynamic>? controller;
  bool? isSavedCard;

  GetProductCard(this.product, {this.controller, this.isSavedCard});

  SavedCard get() {
    return SavedCard(
      prodotto: product,
      controller: controller,
      isSavedCard: isSavedCard,
    );
  }
}
