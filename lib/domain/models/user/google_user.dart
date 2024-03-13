import 'dart:convert';

class GoogleUser {
  String sub;
  String name;
  String surname;
  String city;
  String email;
  DateTime dateOfBirth;

  GoogleUser(this.sub, this.name, this.surname, this.city, this.email,
      this.dateOfBirth);

  String toJson() {
    Map<String, String> data = {
      "sub": sub,
      "name": name,
      "surname": surname,
      "city": city,
      "email": email,
      "dateOfBirth": dateOfBirth.toIso8601String()
    };
    return jsonEncode(data);
  }
}
