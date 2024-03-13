import 'dart:async';
import 'package:fuocherello/data/exception/signup_exception.dart';
import 'package:fuocherello/domain/repositories/user_repository.dart';
import 'package:fuocherello/domain/usecases/signup/signup.dart';
import 'package:fuocherello/helper/form_validators.dart';
import 'package:fuocherello/presentation/authentication/login_screen.dart';
import 'package:flutter/material.dart';
import 'form_ui/comuni_text_field.dart';
import 'form_ui/date_picker_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen(
      {super.key,
      required this.pageStreamController,
      required this.formKey,
      required this.repo});

  final UserRepository repo;
  final GlobalKey<FormState> formKey;
  final StreamController pageStreamController;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  //init variables
  bool passwordVisibility = true;
  final DatePickerField datePicker = DatePickerField();
  final FocusNode comuniFocusNode = FocusNode();
  late final ComuniTextField comuniPicker = ComuniTextField(
    focus: comuniFocusNode,
  );

  //form controller
  final TextEditingController email = TextEditingController();

  InputDecoration standardEmailDecoration = const InputDecoration(
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    labelText: 'E-mail',
    border: OutlineInputBorder(),
  );

  InputDecoration errorEmailDecoration = const InputDecoration(
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    labelText: 'E-mail',
    helperText: "Email gia' presente",
    helperStyle: TextStyle(color: Color.fromARGB(255, 166, 43, 34)),
    enabledBorder: const OutlineInputBorder(
      borderSide:
          const BorderSide(color: Color.fromARGB(255, 166, 43, 34), width: 1.0),
    ),
    border: const OutlineInputBorder(),
  );

  late InputDecoration currentEmailDecoration = standardEmailDecoration;

  final TextEditingController password = TextEditingController();
  final TextEditingController nome = TextEditingController();
  final TextEditingController cognome = TextEditingController();
  final TextEditingController city = TextEditingController();

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    comuniFocusNode.addListener(() {
      if (comuniFocusNode.hasFocus) {
        Future.delayed(
            const Duration(milliseconds: 370),
            () => scrollController
                .jumpTo(scrollController.position.maxScrollExtent));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height - 2,
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).colorScheme.background,
        child: Form(
          key: widget.formKey,
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
                      decoration: const InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        labelText: 'Cognome',
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
                    datePicker,
                    const SizedBox(height: 20),
                    //Email
                    TextFormField(
                      controller: email,
                      onChanged: ((value) {
                        if (currentEmailDecoration != standardEmailDecoration) {
                          currentEmailDecoration = standardEmailDecoration;
                          setState(() {});
                        }
                      }),
                      keyboardType: TextInputType.emailAddress,
                      decoration: currentEmailDecoration,
                      validator: (value) {
                        if (FormValidator().validateEmail(value!)) {
                          return null;
                        } else {
                          return "Email non valida";
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    //Passowrd
                    TextFormField(
                      controller: password,
                      keyboardType: passwordVisibility
                          ? null
                          : TextInputType.visiblePassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: passwordVisibility,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            passwordVisibility
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          onPressed: () {
                            setState(() {
                              passwordVisibility = !passwordVisibility;
                            });
                          },
                        ),
                      ),
                      validator: ((value) {
                        String result = FormValidator().validatePassword(value);
                        if (result == "Password corretta") {
                          return null;
                        } else {
                          return result;
                        }
                      }),
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        print("tapped");
                        scrollController.animateTo(
                          100,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.bounceIn,
                        );
                      },
                      child: comuniPicker,
                    ),

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
                        Map<String, dynamic> data = {
                          "name": nome.text,
                          "surname": cognome.text,
                          "city": comuniPicker.value,
                          "email": email.text,
                          "password": password.text,
                          "dateOfBirth": datePicker.date?.toIso8601String(),
                        };

                        try {
                          await SignUp(
                            widget.repo,
                            context,
                            widget.formKey,
                            data,
                          ).execute();
                        } on SignUpException {
                          currentEmailDecoration = errorEmailDecoration;
                          setState(() {});
                        }
                      },
                      child: Text(
                        'Registrati',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                //back to login
                InkWell(
                    child: Text(
                      'Hai gia un account?',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    onTap: () => widget.pageStreamController.add(LoginScreen)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
