import 'dart:async';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fuocherello/helper/compress_file.dart';
import 'package:image_picker/image_picker.dart';

//Ui for the selling form screen image slider
class ImageUploader extends StatefulWidget {
  ImageUploader({super.key, required this.submittingController});

  final StreamController uploadImageStreamCtrl = StreamController.broadcast();
  final StreamController submittingController;

  @override
  State<ImageUploader> createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  int _current = 0;
  final CarouselController _controller = CarouselController();
  late final Stream uploadImageStream = widget.uploadImageStreamCtrl.stream;
  final _picker = ImagePicker();
  List<XFile> pickedFile = [];
  final List<XFile> imageFileList = [];
  final List<File> compressedFiles = [];

  @override
  void initState() {
    super.initState();
    uploadImageStream.listen((event) async {
      if (event is bool && event) {
        widget.submittingController.add(compressedFiles);
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
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(100),
                  ),
                ),
                child: IconButton(
                  //icon button to let the user input the images he wants to upload
                  onPressed: () async {
                    pickedFile = await _picker.pickMultiImage();
                    setState(() {});
                    imageFileList.addAll(await pickedFile);
                    File compressedFile;
                    for (var element in imageFileList) {
                      compressedFile = await compressFile(element);
                      compressedFiles.add(compressedFile);
                    }
                    setState(() {});
                  },
                  icon: const Icon(Icons.photo_camera_back),
                ),
              ),
              const SizedBox(height: 10),
              const Text("Selziona una o piu immagini"),
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
                items: List.generate(compressedFiles.length, (index) => index)
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
                              child: Image.file(File(compressedFiles[i].path)),
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
                                compressedFiles.removeAt(i);
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
                        pickedFile = await _picker
                            .pickMultiImage()
                            .whenComplete(() => setState(() {}));
                        File compressedFile;
                        for (var element in pickedFile) {
                          compressedFile = await compressFile(element);
                          compressedFiles.add(compressedFile);
                        }
                        imageFileList.addAll(pickedFile);
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
