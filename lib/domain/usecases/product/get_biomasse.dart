import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:fuocherello/domain/repositories/product_repository.dart';
import 'package:fuocherello/domain/usecases/product/get_product_card.dart';

class GetBiomasse {
  ProductRepository repo;
  StreamController? controller;
  GetBiomasse(this.repo, {this.controller});

  FutureBuilder get() {
    return FutureBuilder(
      future: repo.getBiomasse(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasData) {
          return const SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: Text(
                "Non ci sono prodotti",
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          List<Product> productList = snapshot.data;
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return GetProductCard(productList[index],
                        controller: controller)
                    .get();
              },
              childCount: productList.length,
            ),
          );
        }
        print("SANPSHOT RETURN");
        return const SliverToBoxAdapter(
          child: SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }
}
