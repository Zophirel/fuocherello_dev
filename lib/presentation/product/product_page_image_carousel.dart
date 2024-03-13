import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:go_router/go_router.dart';

//image slider for product page
class ProductPageCarousel extends StatefulWidget {
  const ProductPageCarousel({super.key, required this.prodotto});
  final Product prodotto;

  @override
  State<ProductPageCarousel> createState() => _ProductPageCarouselState();
}

class _ProductPageCarouselState extends State<ProductPageCarousel> {
  double imgCtnSize = 130;
  double outerCtnSize = 160;
  List<CachedNetworkImage> cachedImages = [];
  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          Container(
            height: 230,
            color: Colors.black,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: CarouselSlider(
                items: widget.prodotto.fileNames.isNotEmpty
                    ? List.generate(
                            widget.prodotto.fileNames.length, (index) => index)
                        .map((i) {
                        return AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            color: Colors.black,
                            height: 200,
                            child: widget.prodotto.id != null
                                ? InkWell(
                                    //let the user see the image in full screen
                                    onTap: () => context.pushNamed('image',
                                        extra: CachedNetworkImage(
                                          useOldImageOnUrlChange: true,
                                          imageUrl:
                                              "https://fuocherello-bucket.s3.cubbit.eu/products/${widget.prodotto.author}/${widget.prodotto.id}/${widget.prodotto.fileNames[i]}",
                                          fit: BoxFit.contain,
                                        )),
                                    child: SizedBox(
                                      width: 200,
                                      child: CachedNetworkImage(
                                        useOldImageOnUrlChange: true,
                                        imageUrl:
                                            "https://fuocherello-bucket.s3.cubbit.eu/products/${widget.prodotto.author}/${widget.prodotto.id}/${widget.prodotto.fileNames[i]}",
                                        fit: BoxFit.contain,
                                        errorWidget: ((context, url, error) =>
                                            Image(
                                              image: FileImage(
                                                File(
                                                  widget.prodotto.fileNames[i],
                                                ),
                                              ),
                                            )),
                                      ),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () => context.pushNamed(
                                      'image',
                                      extra: Image.file(
                                        File.fromUri(
                                          Uri.parse(
                                            widget.prodotto.fileNames[i],
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: Image.file(
                                      File.fromUri(
                                        Uri.parse(
                                          widget.prodotto.fileNames[i],
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        );
                      }).toList()
                    : List.generate(1, (index) => index).map((i) {
                        return AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                              color: Colors.black,
                              height: 200,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.photo),
                                  SizedBox(height: 10),
                                  Text(
                                    "Nessuna immagine disponibile",
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              )),
                        );
                      }).toList(),
                carouselController: _controller,
                options: CarouselOptions(
                    enableInfiniteScroll: false,
                    viewportFraction: 1,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    }),
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                widget.prodotto.fileNames.isNotEmpty
                    ? FittedBox(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          margin: const EdgeInsets.all(7),
                          alignment: Alignment.center,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(100),
                            ),
                          ),
                          child: Text(
                            "${_current + 1} / ${widget.prodotto.fileNames.length}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
