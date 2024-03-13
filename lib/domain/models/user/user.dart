class User {
  final String? id;
  final String? name;
  final String? surname;
  final String? city;
  final String? email;
  final DateTime? dateOfBirth;

  User(
      {this.id,
      this.name,
      this.surname,
      this.city,
      this.email,
      this.dateOfBirth});

  String getUserFormatDate() {
    return "${dateOfBirth!.day} - ${dateOfBirth!.month} - ${dateOfBirth!.year}";
  }
}
