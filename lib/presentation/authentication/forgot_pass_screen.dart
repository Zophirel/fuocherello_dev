import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fuocherello/helper/form_validators.dart';
import 'package:fuocherello/helper/message_box.dart';
import 'package:http/http.dart';
import '../../helper/loading_button.dart';
import 'login_screen.dart';

//screen that let the user ask for a password renewal token (sent by the server by email)
class ForgotPassScreen extends StatefulWidget {
  const ForgotPassScreen({
    super.key,
    required this.pageStreamController,
    required this.formKey,
  });
  final GlobalKey<FormState> formKey;
  final StreamController pageStreamController;

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  StreamController messageController = StreamController();
  late Stream messageStream = messageController.stream;
  TextEditingController email = TextEditingController();
  bool isLoading = false;
  MessageBox messagebox = MessageBox();
  GlobalKey<FormState> key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Color successColor = Theme.of(context).colorScheme.tertiaryContainer;
    Color errorColor = Theme.of(context).colorScheme.errorContainer;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height - 2,
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).colorScheme.background,
        child: Form(
          key: widget.formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              messagebox,
              const SizedBox(height: 20),
              Form(
                key: key,
                child: TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "La mail e' necessaria";
                    }
                    if (FormValidator().validateEmail(value)) {
                      return null;
                    } else {
                      return "Email non valida";
                    }
                  },
                ),
              ),

              //Email

              const SizedBox(height: 20),
              //action button

              LoadingButton(
                isLoading: isLoading,
                text: 'Cambia password',
                onPressed: () async {
                  if (key.currentState!.validate()) {
                    print("oh");
                    isLoading = true;
                    setState(() {});
                    var chenagepassreq = await get(
                        Uri.https("www.zophirel.it:8443", "/changepass"),
                        headers: {"emailTo": email.text, 'accept': '*/*'});
                    isLoading = false;
                    setState(() {});
                    if (chenagepassreq.statusCode == 200) {
                      print("200");

                      SuccessMessage message = SuccessMessage(
                          "E' stata mandata una mail contentente il link per il recupero della password",
                          successColor);
                      messagebox.controller.add(message);
                      //triggerSuccess();
                    } else if (chenagepassreq.statusCode == 400) {
                      print("400");
                      ErrorMessage message =
                          ErrorMessage(chenagepassreq.body, errorColor);
                      messagebox.controller.add(message);
                    } else {
                      ErrorMessage message = ErrorMessage(
                          "Si e' verificato un problema di connessione, si prega di riprovare",
                          errorColor);
                      messagebox.controller.add(message);
                    }
                  }
                },
              ),

              const SizedBox(height: 15),

              InkWell(
                child: Text(
                  'Hai gia un account?',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                onTap: () {
                  widget.pageStreamController.add(LoginScreen);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
