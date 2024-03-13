import 'package:fuocherello/domain/models/chat/init_chat_page.dart';
import 'package:fuocherello/domain/repositories/chat_repository.dart';
import 'package:uuid_type/uuid_type.dart';

//class used to obtain or initialize (in case of a new chat)
//locally saved infromation about chats that will be
//used to build [Chat] screens

class ChatPageInfo {
  Uuid? chatId;
  Uuid? prodId;
  String? from;
  String? to;

  InitChatPageData? chatPageData;
  ChatRepository chatRepository;

  ChatPageInfo(
      {this.chatId,
      this.from,
      this.to,
      this.prodId,
      this.chatPageData,
      required this.chatRepository});

  bool get allInfoPresent {
    return this.chatId != null &&
        this.prodId != null &&
        this.from != null &&
        this.to != null &&
        this.chatPageData != null;
  }

  /// get all the info about the chat with the current [chatId] if stored in the local db
  Future<ChatPageInfo> getInfo() async {
    if (this.chatId != null) {
      ChatPageInfo? info = await chatRepository.getSavedChatInfo(this.chatId!);
      if (info != null) {
        InitChatPageData chatPageData = InitChatPageData(chatRepository);
        chatPageData = await info.chatPageData!.initChatUi(chatId: this.chatId);

        return ChatPageInfo(
          chatId: this.chatId,
          chatRepository: chatRepository,
          prodId: info.prodId,
          from: info.from,
          to: info.to,
          chatPageData: chatPageData,
        );
      } else {
        return this;
      }
    } else {
      return this;
    }
  }

  String toMap() =>
      """{chatId: ${this.chatId ?? ""}, prodId: ${this.prodId ?? ""}, from: ${this.from ?? ""}, to: ${this.to ?? ""}, chatData : ${this.chatPageData != null}}""";
}
