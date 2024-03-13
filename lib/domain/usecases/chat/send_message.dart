import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fuocherello/helper/singletons/chat_page_logic.dart';

class SendMessage {
  String jsonMessage;
  FlutterSecureStorage storage = const FlutterSecureStorage();

  SendMessage({required this.jsonMessage});

  void execute() async {
    String? token = await this.storage.read(key: "access_token");

    ChatLogic.instance.hubConnection
        .invoke("SendMessage", args: [this.jsonMessage, token!]);
  }
}
