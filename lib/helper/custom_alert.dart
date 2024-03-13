import 'package:flutter/material.dart';

//wiget used to let the user import or take a picture that will be sent in the chat screen
class CustomAlert extends StatelessWidget {
  const CustomAlert({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.blueAccent,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(10),
        child: Container(
          height: 300,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
