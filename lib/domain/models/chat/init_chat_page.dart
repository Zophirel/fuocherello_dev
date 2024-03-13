import 'package:fuocherello/domain/models/chat/message.dart';
import 'package:fuocherello/domain/repositories/chat_repository.dart';
import 'package:uuid_type/uuid_type.dart';

class InitChatPageData {
  ChatRepository repo;
  List<Message>? messages;
  bool thereAreNoMessages = false;
  InitChatPageData(this.repo, {this.messages}) {
    thereAreNoMessages = messages != null ? true : false;
  }

  Future<InitChatPageData> initChatUi({Uuid? chatId}) async {
    var list = await repo.initChatMessagesList(chatId);
    if (list.isEmpty) {
      thereAreNoMessages = true;
    }
    return InitChatPageData(repo, messages: list);
  }
}
