import 'dart:async';
import 'package:fuocherello/data/exception/login_excepiton.dart';
import 'package:fuocherello/helper/singletons/chat_page_logic.dart';
import 'package:fuocherello/data/exception/user_exception.dart';
import 'package:fuocherello/domain/repositories/user_repository.dart';
import 'package:fuocherello/helper/singletons/db_singleton.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';
import 'package:fuocherello/helper/loading_button.dart';
import 'package:fuocherello/presentation/authentication/forgot_pass_screen.dart';
import 'package:fuocherello/presentation/authentication/signup_screen.dart';
import 'package:fuocherello/domain/models/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:email_validator/email_validator.dart';
import '../../domain/models/json_web_token/jsonwebtoken.dart';
import '../../helper/message_box.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.pageStreamController,
    required this.formKey,
    required this.repo,
  });
  final GlobalKey<FormState> formKey;
  final StreamController pageStreamController;
  final UserRepository repo;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginManager manager = LoginManager.instance;
  final ChatLogic chatLogic = ChatLogic.instance;

  //input text
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool passwordVisibility = true;

  //button
  bool isLoading = false;
  final MessageBox messagebox = MessageBox();

  //sign out from google
  Future<void> signOut() async {
    print("sign out");

    try {
      await manager.googleSignIn?.disconnect();
      await widget.repo.logOut();
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color errorColor = Theme.of(context).colorScheme.errorContainer;
    return SafeArea(
      key: GlobalKey(),
      child: Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height - 2,
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).colorScheme.background,
        child: Form(
          key: widget.formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              messagebox,
              const SizedBox(height: 20),
              //Email
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: email,
                decoration: const InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  return EmailValidator.validate(value!)
                      ? null
                      : "Email non valida";
                },
              ),
              const SizedBox(height: 20),

              //Passowrd
              TextField(
                keyboardType:
                    passwordVisibility ? null : TextInputType.visiblePassword,
                controller: password,
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
              ),
              const SizedBox(height: 30),
              //action button
              LoadingButton(
                isLoading: isLoading,
                text: 'Accedi',
                onPressed: () async {
                  if (widget.formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });
                    User? user;
                    try {
                      user = await widget.repo.logIn(email.text, password.text);
                      manager.userLogin(user!);
                      await chatLogic.start();
                      widget.pageStreamController.add(user);
                      setState(() {});
                    } on LoginException catch (e) {
                      messagebox.controller
                          .add(ErrorMessage("${e.message}", errorColor));
                    }
                    setState(() {
                      isLoading = false;
                    });
                  } else {
                    ErrorMessage message = ErrorMessage(
                        "Si e' verificato un problema di connessione, si prega di riprovare",
                        errorColor);
                    messagebox.controller.add(message);
                  }
                },
              ),
              const SizedBox(height: 20),

              //recover password
              InkWell(
                child: Text(
                  'Hai dimenticato la password?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () {
                  widget.pageStreamController.add(ForgotPassScreen);
                },
              ),
              const SizedBox(height: 15),
              //signup
              InkWell(
                child: Text(
                  'Sei un nuovo utente?',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                onTap: () {
                  print("tapped");
                  widget.pageStreamController.add(SignUpScreen);
                },
              ),

              SizedBox(height: 30),
              Container(
                height: 50,
                width: 50,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(
                    Radius.circular(100),
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: InkWell(
                  onTap: () async {
                    GoogleSignIn googleUser = GoogleSignIn();
                    bool isUserSignedIn = await googleUser.isSignedIn();

                    try {
                      if (isUserSignedIn == true) {
                        await googleUser.disconnect();
                      }

                      User? user = await widget.repo.loginGoogleUser();

                      widget.pageStreamController.add(user);
                      manager.userLogin(user!);
                      await DbSingleton.instance.database;
                      await chatLogic.start();
                    } on GoogleSignUpTokenException catch (exception) {
                      manager.googleSignUp(
                          JsonWebToken.unverified(exception.token));
                    }
                  },
                  child: SvgPicture.asset(
                    "assets/android/login/google_icon.svg",
                    height: 20,
                    width: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
