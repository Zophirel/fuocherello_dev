import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fuocherello/data/exception/user_exception.dart';
import 'package:fuocherello/domain/models/user/edit_user_info.dart';
import 'package:fuocherello/domain/models/user/user_dto.dart';
import 'package:fuocherello/helper/singletons/db_singleton.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import '../../domain/models/json_web_token/jsonwebtoken.dart';

class UserDataSource {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LoginManager manager = LoginManager.instance;

  Future<void> _deleteLocalDb() async {
    await DbSingleton.instance.database;
    await DbSingleton.cleanDatabase();
  }

  //GET PRODOTTO //GET PRODOTTO //GET PRODOTTO
  Future<List<List<Map<String, dynamic>>>> initLocalDb() async {
    print("INIT USER LOCAL DB");
    await _deleteLocalDb();
    var preferiti = await _fetchPreferiti();
    var contatti = await _fetchContatti();
    var chat = await _fetchChat();
    var messaggi = await _fetchMessaggi();
    return [preferiti, contatti, chat, messaggi];
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      var response = await post(
        Uri.https('www.zophirel.it:8443', '/login'),
        headers: <String, String>{
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*'
        },
        body: jsonEncode(
          {'email': email, 'password': password},
        ),
      );

      if (response.statusCode == 200) {
        List<String> tokens = response.body.split("@");
        var idToken = JsonWebToken.unverified(tokens[0]);

        String rawDateOfBirth = idToken.claims['dateOfBirth']!;
        List<String> dateDigits = rawDateOfBirth.split('-');

        DateTime formattedDateOfBirth = DateTime(int.parse(dateDigits[0]),
            int.parse(dateDigits[1]), int.parse(dateDigits[2]));

        await _secureStorage.write(key: "access_token", value: tokens[1]);
        await _secureStorage.write(key: "refresh_token", value: tokens[2]);

        return {
          "access_token": tokens[1],
          "refresh_token": tokens[2],
          "sub": idToken.claims['sub'],
          "name": idToken.claims['name'],
          "surname": idToken.claims['surname'],
          "city": idToken.claims['city'],
          "email": idToken.claims['email'],
          "dateOfBirth": formattedDateOfBirth,
        };
      } else {
        return {"error": response.body};
      }
    } catch (e, stacktrace) {
      print('Exception: $e');
      print('Stacktrace: $stacktrace');
      return {};
    }
  }

  Future<Map<String, dynamic>> getOtherUserPublicInfo(String userId) async {
    var response =
        await get(Uri.https("www.zophirel.it:8443", "/api/user/$userId"));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return {
        "id": userId.toString(),
        "name": data[0]["Name"].toString(),
        "propic": data[0]['Propic'].toString(),
      };
    } else {
      print("USER ID: $userId");
      return {};
    }
  }

  Future<String> signInGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['openid', 'email', 'profile'],
    );
    print("sign in");
    Response response = Response("", 404);
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    var auth = await googleUser!.authentication;
    print("AUTH ID TOKEN:  ${auth.idToken}");
    response = await post(
      Uri.parse("https://www.zophirel.it:8443/api/signup/oauthlogin"),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'idtoken': auth.idToken,
      },
    );

    if (response.statusCode == 200) {
      manager.googleSignIn = googleSignIn;
      List<String> tokens = response.body.split("@");
      await _secureStorage.write(key: "access_token", value: tokens[1]);
      await _secureStorage.write(key: "refresh_token", value: tokens[2]);
      return response.body;
    } else if (response.statusCode == 401) {
      throw GoogleSignUpTokenException(response.body);
    }
    return "";
  }

  Future<List<Map<String, dynamic>>> _fetchPreferiti() async {
    var token = await _secureStorage.read(key: 'access_token');
    var response = await get(
        Uri.https("www.zophirel.it:8443", "/api/product/saved"),
        headers: <String, String>{
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*//*',
          'Authentication': token!
        });

    if (response.statusCode == 204) {
      return List.empty();
    }
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }

  Future<List<Map<String, dynamic>>> _fetchContatti() async {
    //[ contact_id TEXT ] [ contact_name TEXT ]
    var token = await _secureStorage.read(key: 'access_token');
    print("TOKEN = $token ");
    var response = await get(
        Uri.https("www.zophirel.it:8443", "/api/user/contacts"),
        headers: <String, String>{
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*//*',
          'Authentication': token!
        });

    if (response.statusCode == 204) {
      return List.empty();
    }

    print("RESPONSE BODY ${response.statusCode}");
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }

  Future<List<Map<String, dynamic>>> _fetchChat() async {
    var token = await _secureStorage.read(key: 'access_token');
    var response = await get(
        Uri.https("www.zophirel.it:8443", "/api/user/chat"),
        headers: <String, String>{
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*/*',
          'Authentication': token!
        });

    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }

  Future<List<Map<String, dynamic>>> _fetchMessaggi() async {
    var token = await _secureStorage.read(key: 'access_token');
    var response = await get(
        Uri.https("www.zophirel.it:8443", "/api/user/messages"),
        headers: <String, String>{
          "Access-Control-Allow-Origin": "*",
          'Content-Type': 'application/json',
          'Accept': '*//*',
          'Authentication': token!
        });

    if (response.body.isEmpty) {
      return [];
    }
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }

  Future<Response?> putUserInfo(EditUserInfo info, {File? propic}) async {
    var uri = Uri.parse("https://www.zophirel.it:8443/api/user/info");
    var request = MultipartRequest("PUT", uri);
    List<MultipartFile> multipartFile = [];

    //images
    if (propic != null) {
      var fileName = propic.path;
      var stream = ByteStream(Stream.castFrom(propic.openRead()));
      var length = await propic.length();
      multipartFile.add(
        MultipartFile(
          'file',
          stream,
          length,
          filename: basename(fileName),
          contentType: MediaType.parse('image/jpeg'),
        ),
      );
    }
    request.files.addAll(multipartFile);

    //json product
    request.fields.addAll(info.toMap());

    request.headers.addAll({
      "Content-Type": "multipart/form-data",
      "Accept": "application/json",
      "Authentication": await _secureStorage.read(key: "access_token") ?? "",
    });

    var streamResponse = await request.send();
    var response = await Response.fromStream(streamResponse);
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception("${response.statusCode} ${response.body}");
    }
  }

  Future<Response> signUpGoogleUser(
      JsonWebToken googleToken, String city, DateTime birthDate) async {
    final url =
        Uri.parse('https://www.zophirel.it:8443/api/signup/oauthsignup');
    final headers = {
      'accept': '*/*',
      'Authentication': googleToken.value,
      'Content-Type': 'application/json',
    };

    final requestBody = json.encode({
      'Sub': googleToken.claims["sub"].toString(),
      'Name': '${googleToken.claims["nome"]}',
      'Surname': '${googleToken.claims["cognome"]}',
      'City': city,
      'Email': '${googleToken.claims["email"]}',
      'Propic': '${googleToken.claims["propic"]}',
      'DateOfBirth': birthDate.toIso8601String(),
    });

    return await post(url, headers: headers, body: requestBody);
  }

  Future<Response> signUp(UserDTO user) async {
    var response = await post(
      Uri.https(
        "www.zophirel.it:8443",
        '/api/signup',
      ),
      headers: {
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json',
        'Accept': '*/*'
      },
      body: user.toJson(),
    );
    print(response.statusCode);
    print(response.body);
    return response;
  }
}
