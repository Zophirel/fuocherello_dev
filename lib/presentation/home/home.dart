import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:fuocherello/domain/repositories/chat_repository.dart';
import 'package:fuocherello/domain/repositories/product_repository.dart';
import 'package:fuocherello/helper/singletons/path_checker.dart';
import 'package:fuocherello/presentation/home/home_filtered_prord_carousel.dart';
import 'package:go_router/go_router.dart';
import 'home_promo_carousel.dart';
import 'home_latest_carousel.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.productRepository,
    required this.chatRepository,
  });
  final ProductRepository productRepository;
  final ChatRepository chatRepository;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //init variables
  bool opened = false;
  late ScrollController _scrollViewController;
  bool _showAppbar = true;
  bool isScrollingDown = false;

  //requred widgets:
  late final FilteredProdCarousel carouselLegname =
      FilteredProdCarousel(tipo: "legname");
  late final FilteredProdCarousel carouselBiomasse =
      FilteredProdCarousel(tipo: "biomasse");
  late final FilteredProdCarousel carouselPellet =
      FilteredProdCarousel(tipo: "pellet");
  //currently selected fitered product list
  late FilteredProdCarousel current = carouselLegname;

  late final LatestArticlesCarousel latestArticles = LatestArticlesCarousel(
    chatRepository: widget.chatRepository,
    productRepository: widget.productRepository,
  );

  @override
  void initState() {
    PathChecker.setLocation = "/";
    super.initState();
    _scrollViewController = ScrollController();
    _scrollViewController.addListener(() {
      if (_scrollViewController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!isScrollingDown) {
          isScrollingDown = true;
          _showAppbar = false;
          mounted ? setState(() {}) : null;
        }
      }

      if (_scrollViewController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (isScrollingDown) {
          isScrollingDown = false;
          _showAppbar = true;
          mounted ? setState(() {}) : null;
        }
      }
    });

    productPageCtrl.stream.listen((event) {
      if (event is Product) {
        goToProductPage(event);
      } else {
        selected = false;
        setState(() {});
      }
    });

    current = carouselLegname;
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    _scrollViewController.removeListener(() {});
    super.dispose();
  }

  double resultsListCtnHeight = 0;
  double backButtonOpct = 0;
  double promoCarouselOpct = 1;

  late double sectionBtnMargin;

  final List<bool> categories = [true, false, false];
  bool selected = false;
  Product? selectedProduct;
  StreamController productPageCtrl = StreamController.broadcast();

  void goToProductPage(Product product) {
    selectedProduct = product;
    selected = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 425) {
      sectionBtnMargin = 75;
    } else {
      sectionBtnMargin = (MediaQuery.of(context).size.width - 210) / 4;
    }

    Stack homePageStack = Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            height: resultsListCtnHeight,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.bottomCenter,
            duration: const Duration(milliseconds: 300),
            color: Theme.of(context).colorScheme.background,
            curve: Curves.easeInOut,
            child: const SizedBox(),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: CustomScrollView(
            controller: _scrollViewController,
            slivers: [
              SliverToBoxAdapter(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: promoCarouselOpct,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: _showAppbar
                            ? const EdgeInsets.only(top: 20)
                            : const EdgeInsets.only(top: 0),
                        height: 170,
                        width: 360,
                        child: const PromoCarousel(),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      height: 50,
                                      width: 360,
                                      child: Text(
                                        'Ultimi arrivi',
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              alignment: Alignment.topLeft,
                              width: MediaQuery.of(context).size.width,
                              height: 280,
                              child: latestArticles,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      //CATEGORIE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 14),
                                //LEGNAME
                                child: Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color: categories[0]
                                        ? Theme.of(context)
                                            .colorScheme
                                            .inversePrimary
                                        : const Color.fromARGB(60, 8, 12, 14),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(100),
                                    ),
                                  ),
                                  child: Container(
                                    margin: categories[0]
                                        ? const EdgeInsets.all(5)
                                        : const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(100),
                                      ),
                                    ),
                                    child: IconButton(
                                      splashRadius: 0.1,
                                      onPressed: (() {
                                        setState(() {
                                          categories[0] = true;
                                          categories[1] = false;
                                          categories[2] = false;
                                          current = carouselLegname;
                                        });
                                      }),
                                      icon: SvgPicture.asset(
                                        "assets/android/home/legna_icon.svg",
                                        height: 50,
                                        width: 50,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(right: 14),
                                child: Text("Legname"),
                              ),
                            ],
                          ),
                          SizedBox(width: sectionBtnMargin),
                          Column(
                            children: [
                              //BIOMASSE
                              Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  color: categories[1]
                                      ? Theme.of(context)
                                          .colorScheme
                                          .inversePrimary
                                      : const Color.fromARGB(60, 8, 12, 14),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(100),
                                  ),
                                ),
                                child: Container(
                                  margin: categories[1]
                                      ? const EdgeInsets.all(5)
                                      : const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(100),
                                    ),
                                  ),
                                  child: IconButton(
                                      splashRadius: 0.1,
                                      onPressed: (() {
                                        setState(() {
                                          categories[0] = false;
                                          categories[1] = true;
                                          categories[2] = false;
                                          current = carouselBiomasse;
                                        });
                                      }),
                                      icon: SvgPicture.asset(
                                        "assets/android/home/ghianda_icon.svg",
                                        height: 40,
                                        width: 40,
                                      ),
                                      style:
                                          IconButton.styleFrom(elevation: 1)),
                                ),
                              ),
                              const Text("Biomasse"),
                            ],
                          ),
                          SizedBox(width: sectionBtnMargin),
                          Column(
                            children: [
                              //PELLET
                              Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  color: categories[2]
                                      ? Theme.of(context)
                                          .colorScheme
                                          .inversePrimary
                                      : const Color.fromARGB(60, 8, 12, 14),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(100),
                                  ),
                                ),
                                child: Container(
                                  margin: categories[2]
                                      ? const EdgeInsets.all(5)
                                      : const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(100),
                                    ),
                                  ),
                                  height: 70,
                                  width: 70,
                                  child: IconButton(
                                    onPressed: (() {
                                      setState(() {
                                        categories[0] = false;
                                        categories[1] = false;
                                        categories[2] = true;
                                        current = carouselPellet;
                                      });
                                    }),
                                    icon: SvgPicture.asset(
                                      "assets/android/home/pellet_icon.svg",
                                      height: 40,
                                      width: 40,
                                    ),
                                  ),
                                ),
                              ),
                              const Text("Pellet")
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 30,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 2 - 180),
                sliver: categories[0]
                    ? carouselLegname
                    : categories[1]
                        ? carouselBiomasse
                        : carouselPellet,
              ),
            ],
          ),
        ),
      ],
    );

    //aspettando il tap sull'input di ricerca
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          AnimatedContainer(
            margin: const EdgeInsets.only(top: 10),
            height: _showAppbar ? 65.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: AppBar(
              automaticallyImplyLeading: false,
              scrolledUnderElevation: 0.0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("LOGO"),
                  ElevatedButton(
                    onPressed: () => context.go("/search"),
                    child: const Row(
                      children: [
                        Icon(Icons.search),
                        Text("Cerca"),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.background,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: homePageStack,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
