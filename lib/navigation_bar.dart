//App main page navigation

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fuocherello/data/mappers/user_mapper.dart';
import 'package:fuocherello/helper/singletons/chat_page_logic.dart';
import 'package:fuocherello/domain/models/app_repository.dart';
import 'package:fuocherello/domain/models/chat/chat_page_info.dart';
import 'package:fuocherello/domain/repositories/user_repository.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';
import 'package:fuocherello/helper/notification_manager.dart';
import 'package:fuocherello/helper/singletons/path_checker.dart';
import 'package:fuocherello/presentation/authentication/auth_menager.dart';
import 'package:fuocherello/presentation/chat/chat_list.dart';
import 'package:fuocherello/presentation/saved/saved.dart';
import 'package:fuocherello/domain/models/user/user.dart';
import 'package:fuocherello/presentation/selling/selling_form.dart';
import 'package:go_router/go_router.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'domain/models/json_web_token/jsonwebtoken.dart';
import 'presentation/home/home.dart';

class NavBarPage extends StatefulWidget {
  NavBarPage({super.key, required this.index});
  final int index;

  @override
  State<NavBarPage> createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  //init varibales
  final GlobalKey navKey = GlobalKey();

  late int currentIndex;
  late User _user = User();
  bool isTokenPresent = false;
  StreamSubscription? notificationStreamSub;

  //navigable pages
  SellingForm? userForm;

  late final _authPage = AuthManager(
    user: _user,
    repo: AppRepository.instance.userRepository,
  );
  late Widget profile = _authPage;

  late final ChatList chatState = ChatList(
      chatListRepository: AppRepository.instance.chatListRepository,
      chatRepository: AppRepository.instance.chatRepository);

  //singletons
  final ChatLogic chatLogic = ChatLogic.instance;
  final _manager = LoginManager.instance;

  //needed repositories
  late final UserRepository repo = AppRepository.instance.userRepository;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _manager.isTokenPresent().then((isPresent) async {
        if (!isPresent && isTokenPresent) {
          isTokenPresent = false;
          await repo.logOut();
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    notificationStreamSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    notificationStreamSub =
        NotificationManager.pushRouteStream.listen((event) async {
      print("EVENT IS CHATPAGEINFO ${event is ChatPageInfo}");
      if (event is ChatPageInfo) {
        event.chatRepository = AppRepository.instance.chatRepository;
        var completeData = await event.getInfo();

        //check if we need to push or replace
        //the new chat screen triggerd
        //by the tap on the notification

        if (PathChecker.isChatOpen) {
          var currentChat = PathChecker.getChatValue();
          print("CURRENT CHAT $currentChat $completeData");
          if (currentChat[1] != completeData.to ||
              currentChat[2] != completeData.prodId.toString()) {
            print("different chat");
            context.replaceNamed("chat", extra: completeData);
          }
        } else {
          //if the notification has been tapped when the app is not in an active state
          context.pushNamed("chat", extra: completeData);
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await _manager.isTokenPresent()) {
        //set up the selling from screen with the user info after the user logged in
        isTokenPresent = true;
        print(UserMapper.toData(await repo.importUserSavedInfo()).toMap());
        userForm = SellingForm(user: await repo.importUserSavedInfo());
        setState(() {});
        print("TOKEN PRESENTE");
      } else {
        print("TOKEN NON PRESENTE");
        isTokenPresent = false;
      }

      if (isTokenPresent &&
          chatLogic.hubConnection.state == HubConnectionState.Disconnected) {
        await chatLogic.start();
      }
    });

    //enables the navigation to all the pages after the user logged in
    _manager.userLoggingStream.listen((event) async {
      if (event is bool && !event && mounted) {
        //User logged out
        isTokenPresent = false;
        profile = _authPage;

        setState(() => currentIndex = 0);
      } else if (event is User && mounted) {
        //User logged in
        userForm = SellingForm(user: await repo.importUserSavedInfo());
        isTokenPresent = true;
        setState(() {});
      } else if (event is JsonWebToken) {
        context.pushNamed("googleSignUp", extra: event);
      }
    });
    currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (pop) {
        print("back");
      },
      child: Scaffold(
        key: navKey,
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: NavigationBar(
          height: 70,
          onDestinationSelected: (int index) async {
            if (!(await _manager.isTokenPresent())) {
              if (index == 0 || index == 4) {
                ///if token is not present let the user navigate [Home] and [Login] pages only
                currentIndex = index;
              } else {
                ///if user click on other pages it will be redirected to the [Login] page
                currentIndex = index = 4;
              }
            } else {
              //if token is present let the user navigate all pages
              currentIndex = index;
            }

            setState(() {});
          },
          selectedIndex: currentIndex,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.message),
              icon: Icon(Icons.message_outlined),
              label: 'Messaggi',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.add_circle),
              icon: Icon(Icons.add_circle_outline_outlined),
              label: 'Vendi',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.bookmark),
              icon: Icon(Icons.bookmark_border),
              label: 'Salvati',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.account_circle),
              icon: Icon(Icons.account_circle_outlined),
              label: 'Account',
            ),
          ],
        ),
        body: [
          //index: 0 -> home page
          SafeArea(
            child: MyHomePage(
              productRepository: AppRepository.instance.productRepository,
              chatRepository: AppRepository.instance.chatRepository,
            ),
          ),
          //index: 1 -> chat page
          SafeArea(child: chatState),
          //index: 2 -> selling form page
          userForm,
          //index: 3 -> saved product page
          SafeArea(
            child: MySavedPage(
              user: _user,
              repo: AppRepository.instance.productRepository,
            ),
          ),

          ////index: 4 -> user profile
          SafeArea(child: profile),
        ][currentIndex],
      ),
    );
  }
}
