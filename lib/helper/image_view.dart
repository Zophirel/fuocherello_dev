import 'package:flutter/material.dart';

//widget needed to display images in full screen when clicked
class ImageView extends StatelessWidget {
  const ImageView({
    super.key,
    required this.image,
  });
  final Widget image;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: InteractiveViewer(
        constrained: true,
        panEnabled: true, // Set it to false
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.5,
        maxScale: 2,
        child: image,
      ),
    );
  }
}
