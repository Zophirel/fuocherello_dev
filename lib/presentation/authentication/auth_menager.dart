import 'dart:async';
import 'package:fuocherello/helper/singletons/chat_page_logic.dart';
import 'package:fuocherello/data/mappers/user_mapper.dart';
import 'package:fuocherello/domain/models/user/user.dart';
import 'package:fuocherello/domain/repositories/user_repository.dart';
import 'package:fuocherello/presentation/account/user_profile.dart';
import 'package:fuocherello/presentation/authentication/forgot_pass_screen.dart';
import 'package:fuocherello/presentation/authentication/google_signup_screen.dart';
import 'package:fuocherello/presentation/authentication/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';
import 'package:fuocherello/presentation/authentication/signup_screen.dart';

import '../../domain/models/json_web_token/jsonwebtoken.dart';

/// widget used by the [NavigationBar] to show the correct auth section page according to the user status (logged in or not)
class AuthManager extends StatefulWidget {
  const AuthManager({
    super.key,
    required this.user,
    required this.repo,
  });

  final User user;
  final UserRepository repo;
  @override
  State<AuthManager> createState() => _AuthManagerState();
}

class _AuthManagerState extends State<AuthManager> {
  final _manager = LoginManager.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final StreamController mainController = StreamController.broadcast();
  late final UserRepository userRepository = widget.repo;
  final ChatLogic chatLogic = ChatLogic.instance;

  late LoginScreen loginChoice = LoginScreen(
    pageStreamController: mainController,
    formKey: formKey,
    repo: widget.repo,
  );

  late ForgotPassScreen forgotPassChoice =
      ForgotPassScreen(pageStreamController: mainController, formKey: formKey);

  late SignUpScreen signUpUserChoice = SignUpScreen(
      pageStreamController: mainController,
      formKey: formKey,
      repo: userRepository);

  late Widget currentScreen = loginChoice;

  void initState() {
    super.initState();

    mainController.stream.listen((event) async {
      print("event $event");
      if (event == LoginScreen) {
        currentScreen = loginChoice;
      } else if (event == ForgotPassScreen) {
        currentScreen = forgotPassChoice;
      } else if (event == SignUpScreen) {
        currentScreen = signUpUserChoice;
      } else if (event is JsonWebToken) {
        currentScreen = GoogleSignUpScreen(signUpToken: event);
      } else if (event is User) {
        currentScreen = UserProfilePage(
          user: event,
          userRepo: widget.repo,
        );
      }
      mounted ? setState(() {}) : null;
    });
  }

  String headerText = "";

  @override
  Widget build(BuildContext context) {
    if (currentScreen is LoginScreen) {
      headerText = "Accedi";
    } else if (currentScreen is ForgotPassScreen) {
      headerText = "Recupera Password";
    } else if (currentScreen is SignUpScreen) {
      headerText = "Registrati";
    } else if (currentScreen is User) {}
    return FutureBuilder(
      future: _manager.isLoggedin(),
      builder: (context, snapshot) {
        print(snapshot.hasData);
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          if (snapshot.data == false) {
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.background,
              appBar: AppBar(
                toolbarHeight: 70,
                automaticallyImplyLeading: false,
                backgroundColor: Theme.of(context).colorScheme.surface,
                surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
                scrolledUnderElevation: 0.0,
                centerTitle: true,
                title: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    headerText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              body: currentScreen,
            );
          } else {
            return FutureBuilder(
                future: userRepository.importUserSavedInfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    print(UserMapper.toData(snapshot.data!).toMap().toString());
                    return UserProfilePage(
                      user: snapshot.data,
                      userRepo: widget.repo,
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                });
          }
        }
        return Container(
          color: Theme.of(context).colorScheme.background,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
