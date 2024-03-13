import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fuocherello/data/datasources/product_datasource.dart';
import 'package:fuocherello/data/mappers/product_mapper.dart';
import 'package:fuocherello/data/repositories/product_repository.dart';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:fuocherello/domain/repositories/product_repository.dart';
import 'package:fuocherello/domain/usecases/product/get_user_product.dart';

//list of products published by `author_id`
class UserProductCarousel extends StatefulWidget {
  const UserProductCarousel({
    super.key,
    required this.authorId,
  });

  final String authorId;

  @override
  State<UserProductCarousel> createState() => _UserProductCarouselState();
}

class _UserProductCarouselState extends State<UserProductCarousel> {
  ProductRepository productRepository =
      DbProductRepository(ProductDataSource(), ProductMapper());
  StreamController saveIconRefreshController = StreamController.broadcast();
  Widget? currentList;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      currentList = GetUserProducts(productRepository)
          .get(await productRepository.getAuthorProducts(widget.authorId));
      mounted ? setState(() {}) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    saveIconRefreshController.stream.listen((event) {
      if (event is Product) {
        mounted ? setState(() {}) : null;
      }
    });
    if (currentList != null) {
      return currentList!;
    } else {
      return SliverToBoxAdapter(
        child: Container(
          height: MediaQuery.of(context).size.width,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        ),
      );
    }
  }
}
