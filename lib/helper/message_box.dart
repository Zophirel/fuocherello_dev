import 'dart:async';
import 'package:flutter/material.dart';

//classes used to provide on screen status messages to the user

class GenericMessage {
  GenericMessage(this.message, this.color);
  final String message;
  Color color;

  late Container messageWidget = Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: color,
    ),
    padding: const EdgeInsets.all(10),
    child: Text(
      message,
    ),
  );
}

class ErrorMessage extends GenericMessage {
  ErrorMessage(super.message, super.color);

  get widget {
    return super.messageWidget;
  }
}

class SuccessMessage extends GenericMessage {
  SuccessMessage(super.message, super.color);

  get widget {
    return super.messageWidget;
  }
}

class MessageBox extends StatefulWidget {
  MessageBox({super.key, this.message});
  final String? message;
  final StreamController controller = StreamController();

  get getController {
    return controller;
  }

  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  Widget currentMessage = const SizedBox(height: 0);
  double messageOpct = 0;
  @override
  void initState() {
    super.initState();

    widget.controller.stream.listen((event) {
      if (event is SuccessMessage || event is ErrorMessage) {
        currentMessage = event.messageWidget;
        mounted
            ? setState(() {
                Future.delayed(const Duration(seconds: 4), () {
                  mounted
                      ? setState(() {
                          currentMessage = const SizedBox(height: 0);
                        })
                      : null;
                });
              })
            : null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return currentMessage;
  }
}
