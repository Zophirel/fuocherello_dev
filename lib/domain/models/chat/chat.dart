//entity that rapresent the `chat` table of the local db
class Chat {
  final String id;
  final String prodId;
  final String prodName;
  final String contactId;
  final int notReadMessage;
  final String thumbnail;

  Chat(
      {required this.id,
      required this.prodId,
      required this.prodName,
      required this.contactId,
      required this.notReadMessage,
      required this.thumbnail});
}
