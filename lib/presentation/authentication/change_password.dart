import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fuocherello/helper/loading_button.dart';
import 'package:fuocherello/presentation/authentication/form_ui/password_input_field.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import '../../helper/message_box.dart';

//let the user input the new password after clicking on an email send by the server containing a token
class ChangePassScreen extends StatefulWidget {
  const ChangePassScreen({
    super.key,
    required this.token,
  });
  final String token;
  @override
  State<ChangePassScreen> createState() => _ChangePassScreenState();
}

StreamController userLoggingStatus = StreamController.broadcast();
Stream userLoggingStream = userLoggingStatus.stream;

class _ChangePassScreenState extends State<ChangePassScreen> {
  bool isSignInin = true;
  bool forgotPass = false;
  bool passwordVisibility = true;
  double formCtnHeight = 410;

  late PasswordInputField passwordField1 = PasswordInputField();
  late PasswordInputField passwordField2 = PasswordInputField(repeat: true);
  bool isLoading = false;
  MessageBox messagebox = MessageBox();

  @override
  Widget build(BuildContext context) {
    print("CAMBIANDO PASSWORD");
    Color successColor = Theme.of(context).colorScheme.tertiaryContainer;
    Color errorColor = Theme.of(context).colorScheme.errorContainer;
    return Scaffold(
      appBar: AppBar(title: const Text("Modifica password")),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            messagebox,
            const SizedBox(height: 20),
            passwordField1,
            const SizedBox(height: 10),
            passwordField2,
            const SizedBox(height: 20),
            //action button
            LoadingButton(
              isLoading: isLoading,
              text: "Cambia password",
              onPressed: () async {
                if (passwordField1.getInputText() ==
                    passwordField2.getInputText()) {
                  isLoading = true;
                  setState(() {});
                  var response = await put(
                    Uri.https(
                      "www.zophirel.it:8443",
                      "/changepass/${widget.token}",
                    ),
                    headers: {"password": passwordField1.txtCtrl.text},
                  );
                  isLoading = false;
                  print("${response.statusCode} ${response.body}");
                  setState(() {});
                  if (response.statusCode == 200) {
                    SuccessMessage message = SuccessMessage(
                      "Password modificata, verrai reindizzato alla pagina di accesso",
                      successColor,
                    );
                    messagebox.controller.add(message);
                    Future.delayed(const Duration(seconds: 3), () {
                      context.go("/login");
                    });
                  } else {
                    ErrorMessage message = ErrorMessage(
                      "Si prega di tentare di nuovo la procedura per il cambio dela password",
                      errorColor,
                    );
                    messagebox.controller.add(message);
                    Future.delayed(const Duration(seconds: 3), () {
                      context.go("/login");
                    });
                  }
                } else {
                  ErrorMessage message = ErrorMessage(
                      "Le password non sono identiche", errorColor);
                  messagebox.controller.add(message);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
