import 'package:flutter/material.dart';
import 'package:fuocherello/data/datasources/product_datasource.dart';
import 'package:fuocherello/data/mappers/product_mapper.dart';
import 'package:fuocherello/data/repositories/product_repository.dart';
import 'package:fuocherello/domain/repositories/chat_repository.dart';
import 'package:fuocherello/domain/repositories/product_repository.dart';
import 'package:fuocherello/domain/usecases/product/get_latest_products.dart';

//list in the Home screen used to show products based on their publish date
class LatestArticlesCarousel extends StatefulWidget {
  const LatestArticlesCarousel({
    super.key,
    required this.productRepository,
    required this.chatRepository,
  });

  final ProductRepository productRepository;
  final ChatRepository chatRepository;
  @override
  State<LatestArticlesCarousel> createState() => _LatestArticlesCarouselState();
}

class _LatestArticlesCarouselState extends State<LatestArticlesCarousel> {
  ProductRepository productRepository =
      DbProductRepository(ProductDataSource(), ProductMapper());
  @override
  Widget build(BuildContext context) {
    return GetLatestProducts(
      widget.productRepository,
      widget.chatRepository,
    ).get();
  }
}
