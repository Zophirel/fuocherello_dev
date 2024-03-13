import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:fuocherello/data/entities/chat/contact_data.dart';
import 'package:fuocherello/data/entities/chat/message_data.dart';
import 'package:fuocherello/domain/enums/chat_enums.dart';
import 'package:fuocherello/domain/models/chat/chat_page_info.dart';
import 'package:fuocherello/domain/models/chat/contact.dart';
import 'package:fuocherello/domain/models/chat/message.dart';
import 'package:uuid_type/uuid_type.dart';

//external and internal db calls for chat data
abstract class ChatRepository {
  //needed by the main to initialize the controller before any other widget can listen to it
  set messageController(StreamController s);

  Stream get messageStream;
  Stream get notificationStream;
  List<Color> get getMessagesColors;
  List<Message> get getMessages;
  HashSet<String> get getBlurredImages;
  Map<int, CachedNetworkImage> get getChachedImages;
  Map<int, Image> get getLocalImages;

  //funtion to get all the message that couldn't be received due to connection issues
  Future<void> getNotReceivedMessages();

  Future<Uuid?> getChatId(Uuid productId, String userId);
  Future<Contact?> fetchChatContactFromLocalDb(Uuid chatId);
  Future<void> addNewMessageInLocalDb(MessageData message);
  Future<void> fetchContactFromRemoteDbById(String author);
  Future<void> addNewContactInLocalDb(ContactData data);

  //get already saved chat page info from local db
  Future<ChatPageInfo?> getSavedChatInfo(Uuid chatId);

  //used to check if the text message rapresent a path to a local or a remote image
  FileLocation isMediaMessage(String message);

  ///handle the insertion in the [DbChatRepository] messages list of the message obtained by `getNotReceivedMessages`

  //handle the messages received by the signalr through the ChatLogic signleton
  Future<void> handleNewMessage(List<Object?>? args);
  Future<List<Message>> initChatMessagesList(Uuid? chatId);

  //init current chat text messages that contain an image path to the localImages or cachedImages list
  void getImageFromMessage(Color myMessageColor, Color otherMessageColor);

  Future<void> insertImageMessageInList(Color myMessageColor,
      Color otherMessageColor, File file, ChatPageInfo info);
  Future<void> InsertImageMessageInLocalDb(List<File> files, String chatId);
}
