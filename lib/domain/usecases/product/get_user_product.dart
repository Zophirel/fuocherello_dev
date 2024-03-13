import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:fuocherello/domain/repositories/product_repository.dart';

class GetUserProducts {
  ProductRepository repo;
  StreamController? controller;
  GetUserProducts(this.repo, {this.controller});

  Widget get(List<Product> prodotti) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(childCount: prodotti.length,
          (context, index) {
        return InkWell(
          child: prodotti[index].getProductCard(controller),
        );
      }),
    );
  }
}
