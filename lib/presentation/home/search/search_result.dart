import 'package:flutter/material.dart';
import 'package:fuocherello/data/datasources/product_datasource.dart';
import 'package:fuocherello/data/mappers/product_mapper.dart';
import 'package:fuocherello/data/repositories/product_repository.dart';
import 'package:fuocherello/domain/repositories/product_repository.dart';

//ui list for the products listed by the Home search widget
class ItemSearchList extends StatefulWidget {
  const ItemSearchList({
    super.key,
    required this.inputController,
  });

  final TextEditingController inputController;
  @override
  State<ItemSearchList> createState() => _ItemSearchListState();
}

class _ItemSearchListState extends State<ItemSearchList> {
  ProductRepository productRepository =
      DbProductRepository(ProductDataSource(), ProductMapper());

  @override
  void initState() {
    super.initState();
    widget.inputController.addListener(() {
      searchInput = widget.inputController.text;
      setState(() {});
    });
  }

  int currentPageIndex = 0;
  double carouselWidth = 0;
  String searchInput = "";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: productRepository.getSearchResutls(searchInput),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          print("CONNECTION DONE");
          print("HAS ERROR: ${snapshot.hasError}");
          print("ERROR: ${snapshot.error}");
          print("HAS DATA: ${snapshot.hasData}");
          if (!snapshot.hasError) {
            if (snapshot.hasData) {
              return Expanded(
                child: ListView.builder(
                  key: widget.key,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    print(index);
                    print(snapshot.data![index].title);
                    return Container(
                      margin: index == 0
                          ? const EdgeInsets.only(top: 20, bottom: 10)
                          : const EdgeInsets.only(bottom: 5),
                      child: InkWell(
                        key: UniqueKey(),
                        child: snapshot.data![index].getProductCard(),
                      ),
                    );
                  },
                ),
              );
            } else {
              return Container(
                alignment: Alignment.center,
                child: Text("Non ci sono prodotti corrispondenti"),
              );
            }
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
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
        }
        return SizedBox();
      },
    );
  }
}
