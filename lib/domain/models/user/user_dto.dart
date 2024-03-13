import 'dart:convert';

class UserDTO {
  String? name;
  String? surname;
  String? city;
  String? email;
  String? password;
  DateTime? dateOfBirth;

  UserDTO({this.name, this.surname, this.city, this.email, this.dateOfBirth});

  UserDTO.fromMap(Map<String, dynamic> data) {
    print(data);
    this.name = data["name"];
    this.surname = data["surname"];
    this.city = data["city"];
    this.email = data["email"];
    this.password = data["password"];
    this.dateOfBirth = DateTime.parse(data["dateOfBirth"]);
  }

  String toJson() {
    Map<String, String> data = {
      "Name": this.name!,
      "Surname": this.surname!,
      "City": this.city!,
      "Email": this.email!,
      "Password": this.password!,
      "DateOfBirth": this.dateOfBirth!.toIso8601String()
    };
    return json.encode(data);
  }

  String getUserFormatDate() {
    return "${dateOfBirth!.day} - ${dateOfBirth!.month} - ${dateOfBirth!.year}";
  }
}
