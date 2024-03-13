import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:fuocherello/domain/models/user/user.dart';
import 'package:fuocherello/domain/repositories/product_repository.dart';
import 'package:go_router/go_router.dart';

//list of saved_card that rapresent all of the products saved by the logged user
class UserSavedProductCarousel extends StatefulWidget {
  const UserSavedProductCarousel(
      {super.key,
      required this.user,
      required this.onRemoveController,
      required this.repo});

  final User user;
  final StreamController onRemoveController;
  final ProductRepository repo;
  @override
  State<UserSavedProductCarousel> createState() =>
      _UserSavedProductCarouselState();
}

class _UserSavedProductCarouselState extends State<UserSavedProductCarousel> {
  StreamController removeCardController = StreamController.broadcast();
  late Stream removeCardStream = removeCardController.stream;
  bool listLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      prodotti = await widget.repo.getUserProducts();
      listLoaded = true;
      setState(() {});
    });

    removeCardStream.listen(
      (event) {
        if (event is Product && prodotti.contains(event)) {
          prodotti.remove(event);
          widget.onRemoveController.add(true);
        }
      },
    );
  }

  List<Product> prodotti = [];
  late SliverList currentList;

  @override
  Widget build(BuildContext context) {
    if (prodotti.isNotEmpty) {
      print(prodotti.length);
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          childCount: prodotti.length,
          (context, index) {
            return InkWell(
              onTap: () => context.go("product", extra: prodotti[index].id),
              child: prodotti[index].getSavedCard(removeCardController),
            );
          },
        ),
      );
    } else if (prodotti.isEmpty && listLoaded) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: const Center(
            child: Text("non ci sono prodotti salvati"),
          ),
        ),
      );
    } else {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
  }
}
