import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fuocherello/data/entities/user/user_data.dart';
import 'package:fuocherello/data/mappers/user_mapper.dart';
import 'package:fuocherello/domain/models/user/public_user.dart';
import 'package:fuocherello/domain/repositories/public_user_repository.dart';
import 'package:fuocherello/domain/repositories/user_repository.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';
import 'package:fuocherello/domain/models/user/user.dart';
import 'package:fuocherello/helper/singletons/path_checker.dart';
import 'package:fuocherello/presentation/account/user_info.dart';
import 'package:fuocherello/presentation/account/user_products_list.dart';
import 'package:go_router/go_router.dart';

/// user profile page accessible from product page (through author button)
/// or from the account section of the [NavigationBar] after loggin in
/// if the page is accessed by the navigation bar it will let the user access his info
/// using the icon button on the top right corner

class UserProfilePage extends StatefulWidget {
  const UserProfilePage(
      {super.key,
      this.user,
      this.publicUser,
      this.publicUserRepo,
      required this.userRepo});

  final User? user;
  final PublicUser? publicUser;
  final PublicUserRepository? publicUserRepo;
  final UserRepository userRepo;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  LoginManager manager = LoginManager.instance;

  late UserData user = UserMapper.toData(widget.user ?? User());

  late UserInfoPage? userInfoPage = widget.user == null
      ? null
      : UserInfoPage(
          user: UserMapper.fromData(user),
          repo: widget.userRepo,
        );

  late StreamSubscription? getUserInfoChanges =
      widget.userRepo.userInfoStream.listen((event) {
    if (event is User) {
      print("EVENT USER DETECTED");
      user = UserMapper.toData(event);
      userInfoPage = UserInfoPage(
        user: UserMapper.fromData(user),
        repo: widget.userRepo,
      );
      setState(() {});
    }
  });

  @override
  void initState() {
    PathChecker.setLocation = "user_profile";
    super.initState();
    if (getUserInfoChanges != null) {
      getUserInfoChanges;
    }

    print(
        "PROFILE ======== https://api.multiavatar.com/${widget.user != null ? widget.user!.id : widget.publicUser!.id}.png");
  }

  @override
  void dispose() {
    getUserInfoChanges?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (user.id != null || widget.publicUser != null) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
          scrolledUnderElevation: 0.0,
          centerTitle: true,
          leading: user.email == null
              ? IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: const Icon(Icons.arrow_back))
              : null,
          title: const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              "Profilo",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: user.email != null
                  ? IconButton(
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return userInfoPage!;
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings),
                    )
                  : null,
            )
          ],
        ),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.bottomCenter,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 150,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.amber,
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left: 20),
                                      height: 150,
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          FittedBox(
                                            child: Text(
                                              user.name ??
                                                  widget.publicUser!.name,
                                              style:
                                                  const TextStyle(fontSize: 35),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Container(
                                      height: 150,
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      padding: const EdgeInsets.only(right: 20),
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(100),
                                          ),
                                          color: Colors.white,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(100)),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl:
                                                "https://fuocherello-bucket.s3.cubbit.eu/profiles/${widget.user != null ? widget.user!.id : widget.publicUser!.id}/${widget.user != null ? widget.user!.id : widget.publicUser!.id}.jpeg",
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    CachedNetworkImage(
                                              imageUrl:
                                                  "https://api.multiavatar.com/${widget.user != null ? widget.user!.id : widget.publicUser!.id}.png",
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          height: 30,
                          child: const Text(
                            "Articoli in vendita",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width / 2 - 180),
                        sliver: UserProductCarousel(
                          authorId: widget.user != null
                              ? widget.user!.id.toString()
                              : widget.publicUser!.id.toString(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        color: Colors.white,
      );
    }
  }
}
