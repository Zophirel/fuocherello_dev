import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fuocherello/domain/models/user/user.dart';
import 'package:fuocherello/domain/repositories/product_repository.dart';
import 'package:fuocherello/presentation/saved/user_saved_product_carousel.dart';

//Saved product screen
class MySavedPage extends StatefulWidget {
  const MySavedPage({
    super.key,
    required this.user,
    required this.repo,
  });

  final User user;
  final ProductRepository repo;
  @override
  State<MySavedPage> createState() => _MySavedPageState();
}

class _MySavedPageState extends State<MySavedPage> {
  bool _showAppbar = true;
  late ScrollController _scrollViewController;
  StreamController onRemoveController = StreamController.broadcast();
  late Stream onRemoveStream = onRemoveController.stream;
  bool isScrollingDown = false;

  @override
  void initState() {
    super.initState();
    onRemoveStream.listen((event) {
      if (event is bool && event) {
        setState(() {});
      }
    });
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
  }

  @override
  void dispose() {
    onRemoveController.close();
    _scrollViewController.dispose();
    _scrollViewController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            AnimatedContainer(
              margin: _showAppbar
                  ? const EdgeInsets.only(top: 20)
                  : const EdgeInsets.only(top: 0),
              height: _showAppbar ? 50.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: AppBar(
                scrolledUnderElevation: 0.0,
                centerTitle: true,
                title: const Text(
                  "Articoli salvati",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.background,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 2 - 180,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: CustomScrollView(
                      controller: _scrollViewController,
                      slivers: [
                        UserSavedProductCarousel(
                          onRemoveController: onRemoveController,
                          user: widget.user,
                          repo: widget.repo,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
