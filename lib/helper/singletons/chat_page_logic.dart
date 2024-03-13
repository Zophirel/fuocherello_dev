import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fuocherello/data/entities/chat/chat_data.dart';
import 'package:fuocherello/data/entities/chat/contact_data.dart';
import 'package:fuocherello/domain/models/app_repository.dart';
import 'package:fuocherello/domain/repositories/chat_list_repository.dart';
import 'package:fuocherello/domain/repositories/chat_repository.dart';
import 'package:logging/logging.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../notification_manager.dart';

//this signleton class provide the methods invoked by the remote singalr sever
//in charge of the chat functionalities
class ChatLogic {
  //init variables
  static final ChatLogic _chatLogic = ChatLogic._internal();
  ChatLogic._internal();
  static ChatLogic get instance => _chatLogic;
  static bool isLoadingNewChatInfo = false;
  final String serverUrl = "https://www.zophirel.it:8444/chathub";
  final Logger hubProtLogger = Logger("SignalR - hub");
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late final NotificationManager localNoti = NotificationManager();
  late final HubConnection hubConnection = HubConnectionBuilder()
      .withUrl(serverUrl)
      .configureLogging(hubProtLogger)
      .build();

  //needed repositories
  final ChatListRepository chatListRepository =
      AppRepository.instance.chatListRepository;
  final ChatRepository chatRepository = AppRepository.instance.chatRepository;

  //stream used to set the chat id of new chats
  final StreamController _signalrStreamCtrl = StreamController.broadcast();
  late Stream signalrStream = _signalrStreamCtrl.stream;

  Future<void> start() async {
    String? token = await _secureStorage.read(key: "access_token");
    await NotificationManager.init();

    //reset handlers
    if (hubConnection.state == HubConnectionState.Disconnected) {
      hubConnection.onclose(({error}) async {
        hubConnection.off("broadcasttoclient");
        hubConnection.off("notifyuserofnewconversation");
        hubConnection.off("ping");
        hubConnection.off("sendchatinfo");
      });

      hubConnection.onreconnected(({connectionId}) async {
        await hubConnection
            .send("OnConnect", args: List.from([token]))
            .whenComplete(() async {
          print("ON CONNECT");
          //check for not received messages after starting the connection from a disconnected state
          await chatRepository.getNotReceivedMessages();
        }).onError((error, stackTrace) => print("${error} , ${stackTrace}"));
      });

      await hubConnection.start();

      //set handlers
      hubConnection.on(
        "broadcasttoclient",
        ((list) async {
          print(list.toString());
          await chatRepository.handleNewMessage(list);
        }),
      );

      hubConnection.on(
        "notifyuserofnewconversation",
        ((list) async {
          if (list != null && list.isNotEmpty) {
            isLoadingNewChatInfo = true;
            //data from the signalr server
            var rawContactData = json.decode(list[0] as String)[0];
            var rawChatData = json.decode(list[0] as String)[1];

            //when a new chat is created by or with an already registered user (in the local db)
            //it will throw a UNIQUE exception if we try to add it again
            var contatto = await chatListRepository
                .fetchContactByIdFromLocalDb(rawContactData["contact_id"]);

            ContactData? contactData;

            //so we check if it is present
            if (contatto.isEmpty) {
              contactData = ContactData.fromMap(rawContactData);
              await chatRepository.addNewContactInLocalDb(contactData);
              print("contatto aggiunto!");
            } else {
              print("contatto gia' aggiunto!");
            }

            //add the chat data in any case
            ChatData data = ChatData.fromMap(rawChatData);
            await chatListRepository.addNewChatInLocalDb(data);
            print("chat aggiunta al db locale!");
            isLoadingNewChatInfo = false;
          }
        }),
      );

      hubConnection.on(
        "ping",
        ((list) async {
          //method used by the singalr server to check if the client is online before sending a message
          //if the user is not onine the message will be saved in the remote db
          print('ping success');
          String? token = await _secureStorage.read(key: "access_token");
          if (token != null) {
            await hubConnection.invoke("pingSuccess", args: [token, list![0]!]);
          } else {
            print("token non presente");
          }
        }),
      );

      hubConnection.on(
        "sendchatinfo",
        ((list) async {
          //when a user send the first message in a new chat the info of that chat will be used to create
          //a new tile that will let the user access the chat from the ChatList page
          print("SENDCHATINFO");
          if (list != null && list.isNotEmpty) {
            print(list[0] as String);
            var chatDataJson = json.decode(list[0] as String);
            ChatData chatData = ChatData.fromMap(chatDataJson);
            await chatListRepository.addNewChatInLocalDb(chatData);
            _signalrStreamCtrl.add(chatData.id);
          }
        }),
      );

      print("sending on connect info");
      await hubConnection
          .send("OnConnect", args: List.from([token]))
          .whenComplete(() async {
        print("ON CONNECT");
        //check for not received messages after starting the connection from a disconnected state
        await chatRepository.getNotReceivedMessages();
      }).onError((error, stackTrace) => print("${error} , ${stackTrace}"));
    }
    return null;
  }
}
