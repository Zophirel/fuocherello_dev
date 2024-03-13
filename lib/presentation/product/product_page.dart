import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuocherello/domain/models/app_repository.dart';
import 'package:fuocherello/domain/models/chat/chat_page_info.dart';
import 'package:fuocherello/domain/models/chat/init_chat_page.dart';
import 'package:fuocherello/domain/models/chat/message.dart';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:fuocherello/domain/repositories/chat_repository.dart';
import 'package:fuocherello/domain/repositories/product_repository.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';
import 'package:fuocherello/helper/singletons/path_checker.dart';
import 'package:fuocherello/presentation/product/product_page_image_carousel.dart';
import 'package:fuocherello/presentation/product/product_author_button.dart';
import 'package:fuocherello/presentation/saved/save_product_button.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid_type/uuid_type.dart';

class ProductPage extends StatefulWidget {
  const ProductPage(
      {super.key,
      required this.prodotto,
      required this.chatRepo,
      required this.productRepository});

  final Product prodotto;
  final ChatRepository chatRepo;
  final ProductRepository productRepository;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  LoginManager manager = LoginManager.instance;
  bool isUserOwner = false;
  bool isProductBeingDeleted = false;

  @override
  void initState() {
    super.initState();
    if ((manager.userId != null) &&
        (manager.userId == widget.prodotto.author)) {
      isUserOwner = true;
    }
  }

  Container bottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1),
          )
        ],
      ),
      height: 107,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 33, right: 40, bottom: 10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Prezzo",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.prodotto.getRightPrice(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ]),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              onPressed: () async {
                String author = widget.prodotto.author.toString();
                String product = widget.prodotto.id.toString();
                if (manager.userId != author &&
                    await manager.isTokenPresent()) {
                  Uuid productId = Uuid.parse(product);
                  ChatPageInfo chatPageInfo = ChatPageInfo(
                    from: manager.userId!,
                    to: author,
                    prodId: productId,
                    chatPageData: InitChatPageData(widget.chatRepo,
                        messages: List<Message>.empty()),
                    chatRepository: widget.chatRepo,
                  );
                  try {
                    await widget.chatRepo.fetchContactFromRemoteDbById(author);
                  } on Exception {
                    chatPageInfo.chatId =
                        await widget.chatRepo.getChatId(productId, author);
                    context.goNamed("chat",
                        extra: await chatPageInfo.getInfo());
                    return;
                  }
                  context.goNamed("chat", extra: chatPageInfo);
                } else {
                  Fluttertoast.showToast(msg: "Accedi per poter chattare");
                }
              },
              child: const Text("Contatta"),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (pop) {
        while (context.canPop()) {
          print("pop!!!");
          context.pop();
        }
        print("replace!!!");
        if (PathChecker.getCurrentLocation == "selling_form" ||
            PathChecker.getCurrentLocation == "edit_form") {
          context.pushReplacement("/");
        }
        return;
      },
      child: SafeArea(
        child: Scaffold(
          bottomNavigationBar: isUserOwner ? null : bottomNavigationBar(),
          appBar: AppBar(
            toolbarHeight: 70,
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            scrolledUnderElevation: 0.0,
            centerTitle: true,
            leading: IconButton(
                onPressed: () {
                  while (context.canPop()) {
                    context.pop();
                  }
                  print("replace!!!");
                  if (PathChecker.getCurrentLocation == "selling_form" ||
                      PathChecker.getCurrentLocation == "edit_form") {
                    context.pushReplacement("/");
                  }
                },
                icon: const Icon(Icons.arrow_back)),
            actions: isUserOwner
                ? [
                    SaveProductButton(
                      prodotto: widget.prodotto,
                    ),
                    IconButton(
                      onPressed: () {
                        context.goNamed("editProduct", extra: widget.prodotto);
                      },
                      icon: const Icon(
                        Icons.edit_document,
                      ),
                    ),
                    IconButton(
                      onPressed: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Elimina Annuncio'),
                          content: const Text(
                              'Vuoi davvero eliminare questo annuncio?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isProductBeingDeleted = true;
                                });
                                print("DELETEING ${widget.prodotto.id}");
                                widget.productRepository
                                    .deleteProduct(widget.prodotto)
                                    .whenComplete(() {
                                  while (context.canPop()) {
                                    context.pop();
                                  }
                                  context.push('/');
                                });
                                isProductBeingDeleted = false;
                              },
                              child: isProductBeingDeleted
                                  ? const CircularProgressIndicator()
                                  : const Text('OK'),
                            ),
                          ],
                        ),
                      ),
                      icon: const Icon(
                        Icons.delete,
                      ),
                    ),
                  ]
                : [
                    SaveProductButton(
                      prodotto: widget.prodotto,
                    ),
                  ],
            title: const Padding(
              padding: EdgeInsets.only(top: 20),
            ),
          ),
          body: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ProductPageCarousel(prodotto: widget.prodotto),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            alignment: MediaQuery.of(context).size.width < 375
                                ? null
                                : Alignment.center,
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                widget.prodotto.title,
                                style: const TextStyle(
                                  height: 1,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            alignment: MediaQuery.of(context).size.width < 375
                                ? null
                                : Alignment.center,
                            child: FittedBox(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 10),
                                  InkWell(
                                      onTap: () {
                                        context.goNamed('user',
                                            extra: widget.prodotto.author);
                                      },
                                      child: AuthorButton(
                                        prodotto: widget.prodotto,
                                        repo: AppRepository
                                            .instance.publicUserRepository,
                                      )),
                                  const SizedBox(width: 10),
                                  Row(children: [
                                    const Icon(Icons.place),
                                    Text(widget.prodotto.place),
                                  ]),
                                  const SizedBox(width: 10),
                                  Row(children: [
                                    const Icon(Icons.calendar_month),
                                    Text(widget.prodotto.getShortDate()),
                                    const SizedBox(width: 10),
                                  ]),
                                ],
                              ),
                            ),
                          ),
                        ]),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(children: [
                      Expanded(
                        child: Container(
                          height: 2,
                          width: 10,
                          color: Colors.black,
                        ),
                      )
                    ]),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: const Text(
                        "DESCRIZIONE",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Text(widget.prodotto.description),
                    ),
                  ],
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
