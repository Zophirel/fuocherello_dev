import 'package:flutter/material.dart';

//generic button used after any cta that need to be awaited
class LoadingButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const LoadingButton(
      {super.key, required this.text, this.onPressed, this.isLoading = false});

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll<Color>(widget.isLoading
            ? Colors.grey
            : Theme.of(context).colorScheme.surfaceVariant),
        minimumSize: MaterialStateProperty.all(
          const Size(double.infinity, 50),
        ),
      ),
      onPressed: widget.isLoading ? null : widget.onPressed,
      child: widget.isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.inversePrimary),
              ),
            )
          : Text(
              widget.text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
    );
  }
}
