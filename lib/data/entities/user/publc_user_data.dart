///Class to rapresent the data needed to parse to create [PublicUser] objects

class PublicUserData {
  final String id;
  final String name;
  final String propic;

  PublicUserData({
    required this.id,
    required this.name,
    required this.propic,
  });

  factory PublicUserData.fromMap(Map<String, dynamic> data) {
    print("PUBLIC USER DATA ==== $data");
    return PublicUserData(
      id: data['id'] as String,
      name: data['name'] as String,
      propic: data["propic"] as String,
    );
  }
  Map<String, dynamic> toMap() => {"id": id, "name": name, "propic": propic};
}
