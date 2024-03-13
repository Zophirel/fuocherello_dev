import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fuocherello/presentation/saved/save_product_button.dart';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:go_router/go_router.dart';

//Card widget to display the preview of bookmarked products
class SavedCard extends StatefulWidget {
  const SavedCard({
    super.key,
    required this.prodotto,
    this.controller,
    this.isSavedCard,
  });

  final Product prodotto;
  final StreamController? controller;
  final bool? isSavedCard;

  @override
  State<SavedCard> createState() => _SavedCardState();
}

class _SavedCardState extends State<SavedCard> {
  SaveProductButton? saveIcon;

  @override
  void initState() {
    super.initState();
    saveIcon = SaveProductButton(
      prodotto: widget.prodotto,
      streamController: widget.controller,
      inBookmarkList: widget.isSavedCard,
    );
  }

  @override
  Widget build(BuildContext context) {
    String fileName = "error";
    if (widget.prodotto.fileNames.isNotEmpty) {
      fileName = widget.prodotto.fileNames[0];
    }
    String placeAndDate =
        "${widget.prodotto.place} - ${widget.prodotto.getShortDate()}";

    if (placeAndDate.length > 28) {
      placeAndDate =
          "${widget.prodotto.place}\n${widget.prodotto.getShortDate()}";
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: () => context.goNamed('product', extra: widget.prodotto),
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(15),
                    ),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl:
                          "https://fuocherello-bucket.s3.cubbit.eu/products/${widget.prodotto.author}/${widget.prodotto.id}/$fileName",
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(top: 10),
                  height: widget.prodotto.title.length < 16 ? 20 : 45,
                  width: 180,
                  child: Text(
                    widget.prodotto.title,
                    style: TextStyle(
                      height: widget.prodotto.title.length < 16 ? 0.2 : 1,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  alignment: Alignment.centerLeft,
                  height: 45,
                  width: 170,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      placeAndDate,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  padding: widget.prodotto.title.length < 16
                      ? const EdgeInsets.only(top: 10)
                      : const EdgeInsets.only(bottom: 10),
                  width: 182,
                  child: Text(
                    widget.prodotto.getRightPrice(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 120,
              alignment: Alignment.centerRight,
              child: saveIcon,
            )
          ],
        ),
      ),
    );
  }
}
