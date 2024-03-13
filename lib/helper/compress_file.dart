import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<File> compressFile(XFile file) async {
  try {
    var filePath = file.path.split('/');
    filePath.last = "compressed_${file.name.split('.').first}.jpg";
    var filePathString = filePath.join('/');

    var result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      filePathString,
      quality: 30,
    );
    return File(result!.path);
  } on CompressError catch (e) {
    print("COMPRESS ERROR ------ ${e.message} ");
    return File("");
  }
}
