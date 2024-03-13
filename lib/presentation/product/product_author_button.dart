import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:fuocherello/domain/models/user/public_user.dart';
import 'package:fuocherello/domain/models/user/user.dart';
import 'package:fuocherello/domain/repositories/public_user_repository.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';
import 'package:go_router/go_router.dart';

/// Author button used in product pages to let the user see the author [UserProfilePage]
class AuthorButton extends StatefulWidget {
  const AuthorButton({
    super.key,
    required this.prodotto,
    required this.repo,
  });
  final PublicUserRepository repo;
  final Product prodotto;

  @override
  State<AuthorButton> createState() => _AuthorButtonState();
}

class _AuthorButtonState extends State<AuthorButton> {
  LoginManager manager = LoginManager.instance;
  late final PublicUserRepository repo = widget.repo;
  late User user = User();
  late PublicUser publicUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PublicUser? userData =
          await repo.getOtherUserPublicInfo(widget.prodotto.author);
      print(userData.name);
      publicUser = PublicUser(
          id: userData.id, name: userData.name, propic: userData.propic);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: repo.getOtherUserPublicInfo(widget.prodotto.author),
      builder: (context, snapshot) {
        print("SNAPSHOT ${snapshot.hasData}");
        if (snapshot.connectionState.name == "done" && snapshot.hasData) {
          PublicUser publicUser = snapshot.data!;
          if (publicUser.propic.isNotEmpty) {
            print("AUTHOR ${widget.prodotto.author}");
            return FittedBox(
              child: InkWell(
                onTap: () => context.pushNamed('user', extra: publicUser),
                child: Container(
                  padding: const EdgeInsets.only(left: 3, right: 10),
                  alignment: Alignment.centerLeft,
                  height: 35,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(100),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                        )
                      ]),
                  child: Row(children: [
                    Container(
                      margin: const EdgeInsets.only(right: 7),
                      height: 28,
                      width: 28,
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(100)),
                        child: CachedNetworkImage(
                            fit: BoxFit.fitWidth,
                            imageUrl:
                                'https://fuocherello-bucket.s3.cubbit.eu/profiles/${widget.prodotto.author}/${widget.prodotto.author}.jpeg',
                            placeholder: (context, url) => const SizedBox(
                                  height: 5,
                                  width: 5,
                                  child: CircularProgressIndicator(),
                                ),
                            errorWidget: (context, url, error) {
                              return CachedNetworkImage(
                                fit: BoxFit.fitWidth,
                                imageUrl:
                                    'https://api.multiavatar.com/${widget.prodotto.author}.png',
                                placeholder: (context, url) => const SizedBox(
                                  height: 5,
                                  width: 5,
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              );
                            }),
                      ),
                    ),
                    Text(
                      publicUser.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ]),
                ),
              ),
            );
          } else {
            return FittedBox(
              child: Container(
                padding: const EdgeInsets.only(left: 5, right: 10),
                alignment: Alignment.centerLeft,
                height: 35,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(100),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      )
                    ]),
                child: Row(children: [
                  const SizedBox(
                    width: 7,
                  ),
                  Text(
                    publicUser.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ]),
              ),
            );
          }
        } else {
          return const SizedBox(
            height: 35,
            width: 35,
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
