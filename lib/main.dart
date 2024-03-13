import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fuocherello/helper/singletons/chat_page_logic.dart';
import 'package:fuocherello/presentation/account/user_profile.dart';
import 'package:fuocherello/presentation/authentication/sign_up_outcome.dart';
import 'package:fuocherello/presentation/chat/camera.dart';
import 'package:fuocherello/colorscheme/color_schemes.g.dart';
import 'package:fuocherello/domain/models/app_repository.dart';
import 'package:fuocherello/domain/models/chat/chat_page_info.dart';
import 'package:fuocherello/domain/models/chat/message_notification.dart';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:fuocherello/domain/models/user/public_user.dart';
import 'package:fuocherello/helper/custom_alert.dart';
import 'package:fuocherello/helper/image_view.dart';
import 'package:fuocherello/helper/notification_manager.dart';
import 'package:fuocherello/helper/singletons/path_checker.dart';
import 'package:fuocherello/presentation/authentication/change_password.dart';
import 'package:fuocherello/presentation/authentication/google_signup_screen.dart';
import 'package:fuocherello/presentation/chat/chat_page.dart';
import 'package:fuocherello/presentation/product/product_page.dart';
import 'package:fuocherello/presentation/selling/editing/edit_form.dart';
import 'package:fuocherello/presentation/home/search/search_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:uuid_type/uuid_type.dart';
import 'package:workmanager/workmanager.dart';
import 'domain/models/json_web_token/jsonwebtoken.dart';
import 'helper/singletons/login_manager.dart';
import 'helper/verify_email_outcome.dart';
import 'navigation_bar.dart';

ChatLogic chatLogic = ChatLogic.instance;

@pragma('vm:entry-point')
void backgroundCheckChatConnection() async {
  print("ISOLATE 2-1: ${chatLogic.hashCode}");
  Workmanager().executeTask((task, inputData) async {
    Future.delayed(Duration(seconds: 10));
    return true;
  });
}

void checkChatConnection(bool isTokenPresent) async {
  HubConnectionState? connectionState = chatLogic.hubConnection.state;
  if (connectionState != null) {
    if (isTokenPresent && connectionState == "HubConnectionState.Connected") {
      print("Chat still connected");
    } else if (!isTokenPresent &&
        connectionState == HubConnectionState.Connected) {
      await chatLogic.hubConnection.stop();
    } else if (!isTokenPresent &&
        connectionState == HubConnectionState.Disconnected) {
      print("Chat not connected");
    } else if (isTokenPresent &&
        (connectionState == HubConnectionState.Disconnected)) {
      print("disconnected");
      await chatLogic.start();
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationManager.requestPermission();
  await NotificationManager.init();
  print("MAIN CHATLOGIC: ${chatLogic.hashCode}");
  Workmanager().initialize(backgroundCheckChatConnection, isInDebugMode: true);
  // Periodic task registration
  await Workmanager()
      .registerPeriodicTask("periodic-task-identifier", "simplePeriodicTask",
          //frequency: Duration(minutes: 15),
          inputData: {"isTokenPresent": await LoginManager().isTokenPresent()});
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  ;
  await NotificationManager.init();
  AppRepository.instance.chatRepository.messageController =
      StreamController.broadcast();

  AppRepository.instance.chatRepository.notificationStream.listen((event) {
    if (event is MessageNotification) {
      //check if the user needs to receive a notification based on:
      //if he is on the chat page or not
      if (PathChecker.isChatOpen) {
        var currentChat = PathChecker.getChatValue();
        //if the notification doese not come from the opened chat page
        print(Uuid.parse(currentChat[1]) != event.chatId);
        if (Uuid.parse(currentChat[1]) != event.chatId) {
          event.showNotification();
        }
      } else {
        event.showNotification();
      }
    }
  });

  Timer.periodic(Duration(seconds: 5), (timer) async {
    print("CHAT: ${chatLogic.hashCode}");
    print("IS CHAT ACTIVE ${chatLogic.hubConnection.state}");
    checkChatConnection(await LoginManager.instance.isTokenPresent());
  });
  final manager = LoginManager.instance;
  final router = GoRouter(
    initialLocation: "/",
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (_, __) => NavBarPage(index: 0),
        routes: [
          GoRoute(
              path: 'signupoutcome',
              name: 'signupoutcome',
              builder: (_, state) => SignUpOutcome()),
          GoRoute(
            path: 'verifyemail/:token',
            builder: (_, state) => VerifyEmailOutcome(
              token: state.pathParameters["token"]!,
            ),
          ),
          GoRoute(
            path: "changepass/:token",
            builder: (_, state) => ChangePassScreen(
              token: state.pathParameters["token"]!,
            ),
          ),
          GoRoute(
            path: "login",
            name: "login",
            builder: (_, __) => NavBarPage(index: 4),
          ),
          GoRoute(
            path: "search",
            builder: (_, __) => const SearchScreen(),
          ),
          GoRoute(
            name: "chat",
            path: "chat",
            pageBuilder: (context, state) {
              ChatPageInfo info = state.extra as ChatPageInfo;
              return MaterialPage<void>(
                  key: UniqueKey(),
                  child: ChatPage(
                    chatId: info.chatId,
                    prodId: info.prodId.toString(),
                    from: manager.userId.toString(),
                    to: info.to!,
                    initData: info.chatPageData!.messages!,
                    chatRepository: AppRepository.instance.chatRepository,
                    chatListRepository:
                        AppRepository.instance.chatListRepository,
                  ));
            },
          ),
          GoRoute(
            name: "chatpicupload",
            path: "chat/chatpicupload",
            pageBuilder: (context, state) => MaterialPage<void>(
                key: UniqueKey(), child: const CustomAlert()),
          ),
          GoRoute(
            name: "chatList",
            path: "chatList",
            builder: (_, state) => NavBarPage(index: 1),
          ),
          GoRoute(
            name: "product",
            path: "product",
            builder: (_, state) {
              return ProductPage(
                prodotto: state.extra! as Product,
                chatRepo: AppRepository.instance.chatRepository,
                productRepository: AppRepository.instance.productRepository,
              );
            },
          ),
          GoRoute(
              name: "user",
              path: "user",
              builder: (context, state) {
                return UserProfilePage(
                  publicUser: state.extra as PublicUser,
                  userRepo: AppRepository.instance.userRepository,
                );
              }),
          GoRoute(
            name: "editProduct",
            path: "editProduct",
            builder: (_, state) {
              return EditForm(prodotto: state.extra! as Product);
            },
          ),
          GoRoute(
            path: "camera",
            name: "camera",
            builder: (_, state) => Camera(
              cameras: state.extra as List<CameraDescription>,
            ),
          ),
          GoRoute(
            path: "image",
            name: "image",
            builder: (_, state) => ImageView(
              image: state.extra as Widget,
            ),
          ),
          GoRoute(
            path: "googleSignUp",
            name: "googleSignUp",
            builder: (_, state) {
              JsonWebToken token = state.extra as JsonWebToken;
              print(token.claims);
              print(token.claims["sub"]);
              return GoogleSignUpScreen(
                signUpToken: state.extra as JsonWebToken,
              );
            },
          ),
        ],
      ),
    ],
  );

  runApp(MaterialApp.router(
    theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
    routerConfig: router,
  ));
}
