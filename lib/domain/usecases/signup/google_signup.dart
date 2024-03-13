import 'package:flutter/material.dart';
import 'package:fuocherello/domain/repositories/user_repository.dart';
import 'package:go_router/go_router.dart';

import '../../models/json_web_token/jsonwebtoken.dart';

class GoogleSignUp {
  UserRepository userRepository;
  BuildContext context;
  GlobalKey<FormState> formKey;
  JsonWebToken googleToken;
  String city;
  DateTime brithDate;

  GoogleSignUp(this.userRepository, this.context, this.formKey,
      this.googleToken, this.city, this.brithDate);

  Future<void> execute() async {
    if (formKey.currentState!.validate()) {
      bool userSignedUp =
          await userRepository.signUpGoogleUser(googleToken, city, brithDate);

      if (userSignedUp) {
        await userRepository
            .loginGoogleUser()
            .whenComplete(() => context.pop());
      }
    }
  }
}
