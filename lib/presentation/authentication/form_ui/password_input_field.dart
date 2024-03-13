import 'package:flutter/material.dart';
import '../../../../helper/form_validators.dart';

class PasswordInputField extends StatefulWidget {
  PasswordInputField({super.key, this.repeat});
  final bool? repeat;
  final TextEditingController txtCtrl = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String getInputText() => txtCtrl.text;
  bool validate() => formKey.currentState!.validate();

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool passwordVisibility = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.txtCtrl,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: passwordVisibility ? null : TextInputType.visiblePassword,
      obscureText: passwordVisibility,
      validator: (value) {
        var validate = FormValidator().validatePassword(widget.txtCtrl.text);
        if (validate == "Password corretta") {
          return null;
        } else {
          return validate;
        }
      },
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelText: widget.repeat == true ? 'Ripeti password' : "Password",
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            passwordVisibility ? Icons.visibility : Icons.visibility_off,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          onPressed: () {
            setState(() {
              passwordVisibility = !passwordVisibility;
            });
          },
        ),
      ),
    );
  }
}
