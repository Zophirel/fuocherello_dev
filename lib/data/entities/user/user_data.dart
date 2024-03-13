///Class to rapresent the data needed to parse to create [User] objects
class UserData {
  final String? id;
  final String? name;
  final String? surname;
  final String? city;
  final String? email;
  final DateTime? dateOfBirth;

  UserData(
      {required this.id,
      required this.name,
      required this.surname,
      required this.city,
      required this.email,
      required this.dateOfBirth});

  factory UserData.fromMap(Map<String, dynamic> data) {
    print("FROM MAP DATA: $data");
    return UserData(
      id: data['sub'],
      name: data['name'],
      surname: data['surname'],
      city: data['city'],
      email: data['email'],
      dateOfBirth: data['dateOfBirth'],
    );
  }

  factory UserData.fromJsonWebTokenClaims(Map<String, dynamic> data) {
    print(data);
    String rawDateOfBirth = data['dateOfBirth']!;
    List<String> dateDigits = rawDateOfBirth.split('-');
    DateTime formattedDateOfBirth = DateTime(int.parse(dateDigits[0]),
        int.parse(dateDigits[1]), int.parse(dateDigits[2]));
    return UserData(
      id: data['sub'],
      name: data['name'],
      surname: data['surname'],
      city: data['city'],
      email: data['email'],
      dateOfBirth: formattedDateOfBirth,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "surname": surname,
      "city": city,
      "email": email,
      "dateOfBirth": dateOfBirth,
    };
  }
}
