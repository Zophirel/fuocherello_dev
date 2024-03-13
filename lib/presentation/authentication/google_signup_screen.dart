import 'dart:async';
import 'package:fuocherello/domain/models/app_repository.dart';
import 'package:fuocherello/domain/repositories/user_repository.dart';
import 'package:fuocherello/domain/usecases/signup/google_signup.dart';
import 'package:fuocherello/helper/form_validators.dart';
import 'package:flutter/material.dart';
import '../../domain/models/json_web_token/jsonwebtoken.dart';
import 'form_ui/comuni_text_field.dart';
import 'form_ui/date_picker_field.dart';

/// When a new user log in using the google oauth button
/// google will provide some information about the user
/// but not enough to create a [User] in the server so
/// all the missing info will be asked in this screen

class GoogleSignUpScreen extends StatefulWidget {
  const GoogleSignUpScreen({super.key, required this.signUpToken});
  final JsonWebToken signUpToken;

  @override
  State<GoogleSignUpScreen> createState() => _GoogleSignUpScreenState();
}

StreamController userLoggingStatus = StreamController.broadcast();
Stream userLoggingStream = userLoggingStatus.stream;

class _GoogleSignUpScreenState extends State<GoogleSignUpScreen> {
  final DatePickerField datePicker = DatePickerField();
  final FocusNode comuniFocusNode = FocusNode();
  final UserRepository userRepository = AppRepository.instance.userRepository;
  late final ComuniTextField comuniPicker = ComuniTextField(
    focus: comuniFocusNode,
  );

  final TextEditingController email = TextEditingController();
  final TextEditingController nome = TextEditingController();
  final TextEditingController cognome = TextEditingController();
  final TextEditingController city = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey();

  bool isLoading = false;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    nome.text = widget.signUpToken.claims["nome"]!;
    cognome.text = widget.signUpToken.claims["cognome"]!;
    email.text = widget.signUpToken.claims["email"]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Completa le tue informazioni")),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height - 2,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).colorScheme.background,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      //Nome
                      TextFormField(
                        controller: nome,
                        readOnly: true,
                        decoration: const InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          labelText: 'Nome',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              !value.contains(" ")) {
                            return null;
                          } else {
                            return "campo errato";
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      //Cognome
                      TextFormField(
                        controller: cognome,
                        readOnly: true,
                        decoration: const InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          labelText: 'Cognome',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              !value.endsWith(" ") &&
                              value[0] != " ") {
                            return null;
                          } else {
                            return "campo errato";
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      datePicker,
                      const SizedBox(height: 20),
                      //Email
                      TextFormField(
                        controller: email,
                        readOnly: true,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          labelText: 'E-mail',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (FormValidator().validateEmail(value!)) {
                            return null;
                          } else {
                            return "Email non valida";
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      comuniPicker,
                      const SizedBox(height: 30),
                      //action button
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                          minimumSize: MaterialStateProperty.all(
                            const Size(double.infinity, 50),
                          ),
                        ),
                        onPressed: () async {
                          await GoogleSignUp(
                                  this.userRepository,
                                  context,
                                  formKey,
                                  widget.signUpToken,
                                  comuniPicker.value,
                                  datePicker.date!)
                              .execute();
                        },
                        child: Text(
                          'Registrati',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
