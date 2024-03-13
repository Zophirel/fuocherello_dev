import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fuocherello/helper/compress_file.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

//images uploading modal that appear when user click on the chat page + icon for uploading images
class ChatPageImagePopup extends StatelessWidget {
  ChatPageImagePopup({
    super.key,
  });

  final _picker = ImagePicker();
  final List<XFile> imageFileList = [];
  final List<File> compressedFiles = [];
  final StreamController imagesController = StreamController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 125,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            width: 120,
            height: 120,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 64,
                  onPressed: () {
                    _picker.pickMultiImage().then((value) async {
                      compressedFiles.clear();
                      imageFileList.clear();
                      imageFileList.addAll(value);
                      for (var image in imageFileList) {
                        compressedFiles.add(await compressFile(image));
                      }
                      imagesController.add(compressedFiles);
                      imageFileList.clear();
                    });
                    context.pop();
                  },
                  icon: const Icon(Icons.photo),
                ),
                const Text(
                  "Carica immagine",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            width: 120,
            height: 120,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 64,
                  onPressed: () {
                    context.pop();
                    compressedFiles.clear();
                    _picker
                        .pickImage(source: ImageSource.camera)
                        .then((value) async {
                      if (value != null) {
                        compressedFiles.add(await compressFile(value));
                        imagesController.add(compressedFiles);
                      }
                    });
                    imageFileList.clear();
                  },
                  icon: const Icon(Icons.photo_camera),
                ),
                const Text(
                  "Fai una foto",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
