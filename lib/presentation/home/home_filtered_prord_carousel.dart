import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fuocherello/data/datasources/product_datasource.dart';
import 'package:fuocherello/data/mappers/product_mapper.dart';
import 'package:fuocherello/data/repositories/product_repository.dart';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:fuocherello/domain/repositories/product_repository.dart';
import 'package:fuocherello/domain/usecases/product/get_biomasse.dart';
import 'package:fuocherello/domain/usecases/product/get_legname.dart';
import 'package:fuocherello/domain/usecases/product/get_pellet.dart';

//list in the Home screen used to show products based on their type
class FilteredProdCarousel extends StatefulWidget {
  FilteredProdCarousel({
    super.key,
    required this.tipo,
  });

  final String tipo;
  final ProductRepository repo =
      DbProductRepository(ProductDataSource(), ProductMapper());
  @override
  State<FilteredProdCarousel> createState() => _FilteredProdCarouselState();
}

class _FilteredProdCarouselState extends State<FilteredProdCarousel> {
  String tipoCorrente = "legname";
  StreamController saveIconRefreshController = StreamController.broadcast();

  @override
  void initState() {
    super.initState();
    saveIconRefreshController.stream.listen((event) {
      if (event is Product) {
        mounted ? setState(() {}) : null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.tipo);
    if (widget.tipo == "legname") {
      return GetLegname(widget.repo).get();
    } else if (widget.tipo == "biomasse") {
      return GetBiomasse(widget.repo).get();
    } else {
      return GetPellet(widget.repo).get();
    }
  }
}
