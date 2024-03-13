import 'dart:convert';

class EditUserInfo {
  EditUserInfo(String this.name, String this.surname, String this.city,
      DateTime this.dateOfBirth);

  String? name;
  String? surname;
  String? city;
  DateTime? dateOfBirth;

  String toJson() {
    String result =
        """{"Name" : $name, "Surname" : $surname, "City" : $city ,"dateOfBirth" : $dateOfBirth}""";
    return jsonEncode(result);
  }

  Map<String, String> toMap() {
    return {
      "Name": name ?? "",
      "Surname": surname ?? "",
      "City": city ?? "",
      "dateOfBirth": dateOfBirth.toString()
    };
  }
}
