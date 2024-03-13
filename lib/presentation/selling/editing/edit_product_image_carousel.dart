import 'dart:async';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:fuocherello/helper/compress_file.dart';
import 'package:image_picker/image_picker.dart';

class EditFormImageUploader extends StatefulWidget {
  EditFormImageUploader(
      {super.key, required this.submittingController, required this.prodotto});

  final StreamController submittingController;
  final Product prodotto;
  final List<String> fileNames = [];
  @override
  State<EditFormImageUploader> createState() => _EditFormImageUploaderState();
}

class _EditFormImageUploaderState extends State<EditFormImageUploader> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  final _picker = ImagePicker();
  List<XFile> pickedFile = [];

  final List<File> imageFileList = [];
  bool areImagesLoading = true;

  @override
  void initState() {
    super.initState();
    final cache = DefaultCacheManager(); // Gives a Singleton instance
    print("MOSTRANDO IMMAGINI DEL PRODOTTO ${widget.prodotto.id}");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (int i = 0; i < widget.prodotto.fileNames.length; i++) {
        print("FILENAME: ${widget.prodotto.fileNames[i]}");
        imageFileList.add(
          await cache.getSingleFile(
              "https://fuocherello-bucket.s3.cubbit.eu/products/${widget.prodotto.author}/${widget.prodotto.id}/${widget.prodotto.fileNames[i]}"),
        );
        widget.fileNames.add(widget.prodotto.fileNames[i]);
      }
      setState(() {
        areImagesLoading = false;
      });
    });

    widget.submittingController.stream.listen((event) async {
      if (event is Product) {
        print("SUBMITTING IMAGES");
        print(imageFileList);
        widget.submittingController.add(imageFileList);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Stack noImageState = Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              areImagesLoading
                  ? const SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(100),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          pickedFile = await _picker.pickMultiImage();
                          for (var image in pickedFile) {
                            imageFileList.add(await compressFile(image));
                            widget.fileNames.add(image.name);
                          }
                          print(
                              "IMMAGINI NELLA SLIDER: ${widget.fileNames.length}");
                          setState(() {});
                        },
                        icon: const Icon(Icons.photo_camera_back),
                      ),
                    ),
              areImagesLoading ? const SizedBox() : const SizedBox(height: 10),
              areImagesLoading
                  ? const SizedBox()
                  : const Text("Selziona una o piu immagini"),
            ],
          ),
        ),
      ],
    );

    SizedBox withImageState = SizedBox(
      child: Column(
        children: [
          Container(
            height: 230,
            color: Colors.black,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: CarouselSlider(
                items: List.generate(imageFileList.length, (index) => index)
                    .map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 50,
                            child: Container(
                              margin: const EdgeInsets.only(left: 50),
                              child: Image.file(File(imageFileList[i].path)),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 10, top: 10),
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: IconButton(
                              onPressed: () {
                                imageFileList.removeAt(i);
                                widget.fileNames.removeAt(i);
                                _current--;
                                setState(() {});
                              },
                              icon: Icon(
                                Icons.delete_rounded,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: imageFileList.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _controller.animateToPage(entry.key),
                      child: Container(
                        width: 12.0,
                        height: 12.0,
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 4.0,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              (Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black)
                                  .withOpacity(
                            _current == entry.key ? 0.9 : 0.4,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 14.0,
                      horizontal: 4.0,
                    ),
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: IconButton(
                      onPressed: () async {
                        pickedFile = await _picker.pickMultiImage();
                        print("CURRENT  $_current");
                        for (var image in pickedFile) {
                          if (_current + 1 == pickedFile.length - 1) {
                            imageFileList.add(await compressFile(image));
                            widget.fileNames.add(image.path);
                          } else {
                            imageFileList.insert(
                                _current + 1, await compressFile(image));
                            widget.fileNames.insert(_current + 1, image.path);
                          }
                        }
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return imageFileList.isEmpty ? noImageState : withImageState;
  }
}
