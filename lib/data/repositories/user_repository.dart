import 'dart:async';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fuocherello/data/exception/login_excepiton.dart';
import 'package:fuocherello/data/exception/signup_exception.dart';
import 'package:fuocherello/domain/models/app_repository.dart';
import 'package:fuocherello/domain/models/user/user_dto.dart';
import 'package:fuocherello/helper/singletons/chat_page_logic.dart';
import 'package:fuocherello/data/datasources/user_datasources.dart';
import 'package:fuocherello/data/entities/chat/chat_data.dart';
import 'package:fuocherello/data/entities/chat/contact_data.dart';
import 'package:fuocherello/data/entities/chat/message_data.dart';
import 'package:fuocherello/data/entities/user/user_data.dart';
import 'package:fuocherello/data/exception/user_exception.dart';
import 'package:fuocherello/data/mappers/user_mapper.dart';
import 'package:fuocherello/domain/models/user/edit_user_info.dart';
import 'package:fuocherello/domain/models/user/user.dart';
import 'package:fuocherello/domain/repositories/chat_list_repository.dart';
import 'package:fuocherello/domain/repositories/chat_repository.dart';
import 'package:fuocherello/domain/repositories/product_repository.dart';
import 'package:fuocherello/domain/repositories/user_repository.dart';
import 'package:fuocherello/helper/singletons/db_singleton.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../../domain/models/json_web_token/jsonwebtoken.dart';

class DbUserRepository implements UserRepository {
  //singleton
  final LoginManager manager = LoginManager.instance;

  //required repositories
  final ChatRepository chatRepository = AppRepository.instance.chatRepository;
  final ChatListRepository chatListRepository =
      AppRepository.instance.chatListRepository;
  final ProductRepository productRepository =
      AppRepository.instance.productRepository;

  final UserDataSource datasource;
  final UserMapper mapper;
  DbUserRepository(this.datasource, this.mapper);

  SharedPreferences? _prefs;

  final StreamController _userInfoController = StreamController.broadcast();
  @override
  Stream get userInfoStream => _userInfoController.stream;

  @override
  void updateUserInfo(User user) => _userInfoController.add(user);

  @override
  Future<void> logOut() async {
    chatRepository.getMessages.clear();
    chatRepository.getMessagesColors.clear();
    chatListRepository.tiles.clear();
    _prefs = await SharedPreferences.getInstance();
    _prefs!.clear();

    await FlutterSecureStorage().deleteAll();
    await DbSingleton.cleanDatabase();
    if (manager.googleSignIn != null) {
      await manager.googleSignIn!.disconnect();
      manager.googleSignIn = null;
    }

    manager.userLogout();

    if (ChatLogic.instance.hubConnection.state ==
        HubConnectionState.Connected) {
      await ChatLogic.instance.hubConnection.stop();
    }
  }

  @override
  Future<User?> logIn(String email, String password) async {
    var data = await datasource.login(email, password);
    print("LOGIN DATA : $data");
    if (data["error"] == null) {
      UserData userData = UserData.fromMap(data);
      _writeUserSavedInfo(userData);

      User user = UserMapper.fromData(userData);
      return user;
    }

    throw LoginException(message: data["error"]);
  }

  @override
  Future<User> importUserSavedInfo() async {
    _prefs = await SharedPreferences.getInstance();
    List<String>? userInfo = _prefs?.getStringList("userInfo");
    if (userInfo == null || userInfo.isEmpty) {
      print("empty user data");

      return User();
    } else {
      final UserData userData = UserData(
          id: userInfo[0],
          name: userInfo[1],
          surname: userInfo[2],
          city: userInfo[3],
          email: userInfo[4],
          dateOfBirth: DateTime.parse(userInfo[5]));
      print("IMPORT USER SAVED INFO ${userData.toMap()}");
      return UserMapper.fromData(userData);
    }
  }

  Future<void> _writeUserSavedInfo(UserData data) async {
    print("WRITE USER SAVED INFO ${data.toMap()}");

    List<String> userInfo = [
      data.id!,
      data.name!,
      data.surname!,
      data.city!,
      data.email!,
      data.dateOfBirth.toString()
    ];

    _prefs = await SharedPreferences.getInstance();
    _prefs!.setStringList("userInfo", userInfo);
  }

  Future<void> _initLocalDb() async {
    final List<List<Map<String, dynamic>>> data =
        await datasource.initLocalDb();

    print("INIT LOCAL DB DATA");
    print(data);
    final List<Map<String, dynamic>> preferiti = data[0];
    final List<Map<String, dynamic>> contatti = data[1];
    final List<Map<String, dynamic>> chat = data[2];
    final List<Map<String, dynamic>> messaggi = data[3];

    if (data[0].isNotEmpty) {
      for (int i = 0; i < preferiti.length; i++) {
        await productRepository.saveProductInLocalDb(preferiti[i]["id"]);
      }
    }

    if (contatti.isNotEmpty) {
      for (Map<String, dynamic> contatto in contatti) {
        ContactData contactData = ContactData.fromMap(contatto);
        await chatRepository.addNewContactInLocalDb(contactData);
      }
    }
    if (chat.isNotEmpty) {
      for (Map<String, dynamic> c in chat) {
        ChatData chatData = ChatData.fromMap(c);
        await chatListRepository.addNewChatInLocalDb(chatData);
      }
    }
    if (messaggi.isNotEmpty) {
      for (Map<String, dynamic> messaggio in messaggi) {
        print("adding message from db");

        await chatRepository
            .addNewMessageInLocalDb(MessageData.fromMap(messaggio));
      }
    }
  }

  @override
  Future<User?> loginGoogleUser() async {
    String tokenString = "";
    try {
      tokenString = await datasource.signInGoogle();
      if (tokenString.isNotEmpty) {
        List<String> tokens = tokenString.split("@");
        JsonWebToken idToken = JsonWebToken.unverified(tokens[0]);
        UserData userData = UserData.fromJsonWebTokenClaims(idToken.claims);
        User loggedUser = UserMapper.fromData(userData);
        manager.userLogin(loggedUser);
        await _initLocalDb();
        await _writeUserSavedInfo(userData);
        return loggedUser;
      } else {
        return null;
      }
    } on GoogleSignUpTokenException catch (e) {
      //push google signup screen that will let the user fill the remaining informaitons
      manager.googleSignUp(JsonWebToken.unverified(e.token));
    }
    return null;
  }

  @override
  Future<bool> signUp(Map<String, dynamic> data) async {
    var response = await datasource.signUp(UserDTO.fromMap(data));
    if (response.statusCode == 200) {
      return true;
    } else {
      throw SignUpException(message: response.body);
    }
  }

  @override
  void putUserInfo(EditUserInfo info, {File? propic}) async {
    try {
      datasource.putUserInfo(info, propic: propic);
      print('PUT USER INFO OK');
    } on Exception {
      print("PUT USER INFO ERROR");
    }
  }

  @override
  Future<bool> signUpGoogleUser(
      JsonWebToken googleToken, String city, DateTime birthDate) async {
    var response =
        await datasource.signUpGoogleUser(googleToken, city, birthDate);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
