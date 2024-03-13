import 'dart:convert';

class JsonWebToken {
  Map<String, dynamic> claims = {};

  String value = "";
  Codec<String, String> stringToBase64 = utf8.fuse(base64);

  JsonWebToken.unverified(String token) {
    var splittedToken = token.split('.');
    this.claims =
        json.decode(stringToBase64.decode(base64.normalize(splittedToken[1])));
    print(this.claims);
    this.value = token;
  }
}
