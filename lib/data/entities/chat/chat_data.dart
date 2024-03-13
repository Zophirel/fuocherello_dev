///Class to rapresent the data needed to parse to create [Chat] objects

class ChatData {
  late String id;
  late String prodId;
  late String prodName;
  late String contactId;
  late int notReadMessage;
  late String thumbnail;

  ChatData(
      {required this.id,
      required this.prodId,
      required this.prodName,
      required this.contactId,
      required this.notReadMessage,
      required this.thumbnail});

  ChatData.fromMap(Map<String, dynamic> data) {
    id = data["id"];
    prodId = data["prod_id"];
    prodName = data["prod_name"];
    contactId = data["contact_id"]!;
    notReadMessage = int.parse(data["not_read_message"]);
    thumbnail = data["thumbnail"];
  }
}
