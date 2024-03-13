import 'package:flutter/material.dart';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:fuocherello/domain/repositories/chat_repository.dart';
import 'package:fuocherello/domain/repositories/product_repository.dart';
import 'package:fuocherello/domain/usecases/product/get_latest_product_card.dart';
import 'package:go_router/go_router.dart';

class GetLatestProducts {
  final ProductRepository productRepo;
  final ChatRepository chatRepository;
  GetLatestProducts(this.productRepo, this.chatRepository);

  FutureBuilder get() {
    return FutureBuilder(
      future: productRepo.getLatestProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            height: 270,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(left: 20),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          List<Product> products = snapshot.data as List<Product>;
          return ListView.builder(
            addAutomaticKeepAlives: true,
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Container(
                margin: index == 0 ? const EdgeInsets.only(left: 20) : null,
                child: InkWell(
                  onTap: () {
                    context.pushNamed("product", extra: products[index]);
                  },
                  child: GetLatestProductCard(products[index]).get(),
                ),
              );
            },
          );
        }
      },
    );
  }
}
