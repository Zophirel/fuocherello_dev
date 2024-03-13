import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fuocherello/domain/models/app_repository.dart';
import 'package:fuocherello/domain/models/chat/chat_page_info.dart';
import 'package:fuocherello/domain/repositories/chat_list_repository.dart';
import 'package:fuocherello/domain/repositories/chat_repository.dart';
import 'package:fuocherello/helper/singletons/path_checker.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid_type/uuid_type.dart';

class ChatPath {
  Uuid chatId;
  ChatPath(this.chatId);
}

//Notification manager used with flutter_local_notifications to provide push notification
class NotificationManager {
  static final ChatListRepository _chatListrepo =
      AppRepository.instance.chatListRepository;
  static final ChatRepository _chatRepo = AppRepository.instance.chatRepository;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  static final StreamController _pushRouteFromNotification =
      StreamController.broadcast();
  static Stream pushRouteStream = _pushRouteFromNotification.stream;

  static void requestPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();
  }

  static Future init({bool isScheduled = false}) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    if (notificationResponse.payload != null) {
      var payload = json.decode(notificationResponse.payload!);

      ChatPageInfo info = ChatPageInfo(
          chatRepository: _chatRepo, chatId: Uuid.parse(payload["chat_id"]));
      await info.getInfo();

      if (PathChecker.isChatOpen) {
        var currentChat = PathChecker.getChatValue();
        if (currentChat[1] != payload["chat_id"]) {
          await _chatListrepo.resetChatTile(Uuid.parse(payload["chat_id"]));
        }
      }
      _chatRepo.getMessages.clear();
      _chatRepo.getMessagesColors.clear();
      NotificationManager._pushRouteFromNotification.add(info);
    }
  }

  static Future _notificationDetails(String? title, String? body) async {
    return NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          channelDescription: '',
          importance: Importance.max,
          styleInformation: BigTextStyleInformation(body!,
              htmlFormatBigText: true,
              htmlFormatTitle: true,
              htmlFormatContent: true,
              contentTitle: title,
              htmlFormatContentTitle: true,
              summaryText: '',
              htmlFormatSummaryText: true),
        ),
        iOS: const DarwinNotificationDetails());
  }

  static Future showNotification(
          {int id = 0, String? title, String? body, String? payload}) async =>
      flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        await _notificationDetails(title, body),
        payload: payload,
      );
}

class LocalNotificationManager {
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  LocalNotificationManager() {
    initialize();
  }

  Future<void> initialize() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await flutterLocalNotificationsPlugin!.initialize(initializationSettings);
  }

  Future<void> showNotification(
      int id, String title, String body, String payload) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your_channel_id', 'your_channel_name',
            channelDescription: 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            icon: '@mipmap/ic_launcher',
            styleInformation: DefaultStyleInformation(true, false));

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails());

    await flutterLocalNotificationsPlugin!
        .show(id, title, body, platformChannelSpecifics, payload: payload);
  }
}
