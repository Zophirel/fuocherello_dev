import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:fuocherello/domain/repositories/product_repository.dart';
import 'package:fuocherello/domain/usecases/product/get_product_card.dart';

class GetPellet {
  ProductRepository repo;
  StreamController? controller;
  GetPellet(this.repo, {this.controller});

  FutureBuilder get() {
    return FutureBuilder(
      future: repo.getPellet(),
      builder: (context, snapshot) {
        print(snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasData);
        print(snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData);
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasData) {
          print("non ci sono prodotti");
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
