///Class to rapresent the data needed to parse to create [Contact] objects

class ContactData {
  late String contactId;
  late String contactName;

  ContactData({required contactId, required contactName});

  ContactData.fromMap(Map<String, Object?>? data) {
    print('contact data ${data!["contact_id"]} ${data["contact_name"]}');
    contactId = data["contact_id"] as String;
    contactName = data["contact_name"] as String;
  }
}
