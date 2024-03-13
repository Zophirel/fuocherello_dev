import 'dart:io';
import 'package:fuocherello/domain/models/user/edit_user_info.dart';
import 'package:fuocherello/domain/models/user/user.dart';
import '../models/json_web_token/jsonwebtoken.dart';

abstract class UserRepository {
  Stream get userInfoStream;
  void updateUserInfo(User user);
  Future<User?> logIn(String email, String password);
  Future<void> logOut();
  Future<User> importUserSavedInfo();
  Future<User?> loginGoogleUser();
  Future<bool> signUpGoogleUser(
      JsonWebToken googleToken, String city, DateTime birthDate);
  Future<bool> signUp(Map<String, dynamic> data);
  void putUserInfo(EditUserInfo info, {File? propic});
}
