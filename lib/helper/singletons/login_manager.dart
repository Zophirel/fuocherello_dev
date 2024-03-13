import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fuocherello/data/mappers/user_mapper.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import '../../domain/models/json_web_token/jsonwebtoken.dart';
import '../../domain/models/user/user.dart';

class LoginManager {
  static final LoginManager manager = LoginManager._internal();
  LoginManager._internal();
  static LoginManager get instance => manager;
  GoogleSignIn? googleSignIn;

  final _userLoggingStreamController = StreamController.broadcast();
  late final userLoggingStream = _userLoggingStreamController.stream;
  final _secureStorage = const FlutterSecureStorage();
  String? _userId;
  LoginManager();

  String getJsonFromJWT(String splittedToken) {
    String normalizedSource = base64Url.normalize(splittedToken);
    return utf8.decode(base64Url.decode(normalizedSource));
  }

  String? get userId {
    return _userId;
  }

  void googleSignUp(JsonWebToken token) =>
      _userLoggingStreamController.add(token);

  //check for the access token validity
  Future<Response> _accessTokenCall(String accessToken) async {
    return get(Uri.https("www.zophirel.it:8443", "/api/jwt"),
        headers: {"Authentication": accessToken});
  }

  //check for the refresh token validity
  Future<Response> _refreshTokenCall(String refreshToken) async {
    return get(Uri.https("www.zophirel.it:8443", "/api/jwt"),
        headers: {"Authentication": refreshToken});
  }

  Future<bool> isTokenPresent() async {
    String? key = await _secureStorage.read(key: "access_token");
    if (key == null) {
      return false;
    } else {
      if (manager.userId == null) {
        var token = JsonWebToken.unverified(key);
        _userId = token.claims["sub"];
      }
      return true;
    }
  }

  void userLogout() {
    _userId = "";
    googleSignIn = null;
    _userLoggingStreamController.add(false);
  }

  void userLogin(User loggedUser) {
    print("USER LOGIN: ${UserMapper.toData(loggedUser).toMap()}");
    _userId = loggedUser.id;
    _userLoggingStreamController.add(loggedUser);
  }

  Future<bool> isLoggedin() async {
    String accessToken = await _secureStorage.read(key: 'access_token') ?? "";
    String refreshToken = await _secureStorage.read(key: 'refresh_token') ?? "";
    if (accessToken == "" || refreshToken == "") {
      print("empty");
      return false;
    } else {
      var accessTokenCheck = await _accessTokenCall(accessToken);
      print("ACCESS TOKEN CHECK: ${accessTokenCheck.statusCode}, $accessToken");
      if (accessTokenCheck.statusCode == 200) {
        //when the app goes to an inactive state the LoginManager singleton lose the
        //previously added _userId, in this case it will be read again by the registered token
        if (_userId == null) {
          String jsonString = getJsonFromJWT(accessToken.split('.')[1]);
          Map data = jsonDecode(jsonString);
          _userId = data["sub"];
        }
        print("access token valido");
        return true;
      } else if (accessTokenCheck.statusCode == 401) {
        //if access token is not valid we make _refreshTokenCall to check if another
        //access token can be released by the server or if the client needs to login again
        print("access token non valido");
        var refreshTokenCheck = await _refreshTokenCall(refreshToken);
        if (refreshTokenCheck.statusCode == 200) {
          //the token has been released by the server
          print("refresh token valido");
          await _secureStorage.write(
              key: 'access_token', value: refreshTokenCheck.body);
          return true;
        }
      }
      //refresh token is not valid, the user needs to login again
      await _secureStorage.delete(key: "access_token");
      await _secureStorage.delete(key: "refresh_token");
      userLogout();
      return false;
    }
  }
}
