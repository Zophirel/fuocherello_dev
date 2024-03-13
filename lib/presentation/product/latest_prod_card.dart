import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:fuocherello/presentation/saved/save_product_button.dart';
import 'package:go_router/go_router.dart';

class LatestProdCard extends StatelessWidget {
  const LatestProdCard(
      {super.key, required this.prodotto, required this.width});

  final Product prodotto;
  final double width;

  @override
  Widget build(BuildContext context) {
    double ctnWidth = width;
    String? titoloIntero = prodotto.title;
    String? titoloTroncato = "";
    Color cardColor = Theme.of(context).colorScheme.primaryContainer;

    titoloTroncato = titoloIntero;
    String fileName = "error";
    if (prodotto.fileNames.isNotEmpty) {
      fileName = prodotto.fileNames[0];
    }
    return Card(
      surfaceTintColor: cardColor,
      color: cardColor,
      elevation: 1,
      child: InkWell(
        onTap: () => context.goNamed('product', extra: prodotto),
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(16),
                  ),
                  child: Container(
                    height: 150,
                    width: ctnWidth - 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl:
                          "https://fuocherello-bucket.s3.cubbit.eu/products/${prodotto.author}/${prodotto.id}/$fileName",
                      placeholder: (context, url) => const SizedBox(
                        height: 100,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                )),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 12, right: 10),
                  alignment: Alignment.centerLeft,
                  height: 25,
                  width: ctnWidth,
                  color: cardColor,
                  child: Text(
                    titoloTroncato,
                    maxLines: 2,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  alignment: Alignment.centerLeft,
                  height: 20,
                  width: ctnWidth,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: FittedBox(
                    child: Text(
                      "${prodotto.place} - ${prodotto.getShortDate()}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.only(left: 2, right: 6),
              height: 50,
              width: ctnWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      height: 50,
                      width: ctnWidth * 0.70,
                      color: cardColor,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        prodotto.getRightPrice(),
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 10),
                    height: 50,
                    width: ctnWidth * 0.2,
                    color: cardColor,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 30.0,
                      child: SaveProductButton(prodotto: prodotto),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
