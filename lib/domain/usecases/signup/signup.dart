import 'package:flutter/material.dart';
import 'package:fuocherello/data/exception/signup_exception.dart';
import 'package:fuocherello/domain/repositories/user_repository.dart';
import 'package:go_router/go_router.dart';

class SignUp {
  final UserRepository repo;
  final BuildContext context;
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> data;

  SignUp(this.repo, this.context, this.formKey, this.data);

  Future<void> execute() async {
    if (formKey.currentState!.validate()) {
      try {
        await repo.signUp(data);
        context.pushNamed("signupoutcome");
      } on SignUpException catch (e) {
        throw e;
      }
    }
  }
}
