import 'dart:async';
import 'dart:io';
import 'package:fuocherello/data/mappers/user_mapper.dart';
import 'package:fuocherello/domain/models/app_repository.dart';
import 'package:fuocherello/domain/models/product/product_dto.dart';
import 'package:fuocherello/domain/models/user/user.dart';
import 'package:fuocherello/domain/repositories/product_repository.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';
import 'package:fuocherello/helper/singletons/path_checker.dart';
import 'package:fuocherello/helper/loading_button.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fuocherello/presentation/selling/selling_form_image_uploader.dart';
import 'package:go_router/go_router.dart';

//Ui of the selling product screen
class SellingForm extends StatefulWidget {
  const SellingForm({super.key, required this.user});
  final User user;

  @override
  State<SellingForm> createState() => _SellingFormState();
}

class _SellingFormState extends State<SellingForm> {
  //init variables
  late double sectionBtnMargin;
  ProductDto? p;
  List<bool> categories = [false, false, false];
  bool submitting = false;
  late final ImageUploader imageUploader =
      ImageUploader(submittingController: submittingController);

  //form key
  final GlobalKey<FormState> productFormKey = GlobalKey<FormState>();

  //form controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  //submit controller
  final StreamController submittingController = StreamController();

  //required repositories
  final ProductRepository productRepository =
      AppRepository.instance.productRepository;

  @override
  void initState() {
    super.initState();
    PathChecker.setLocation = "selling_form";
    print("WIDGET USER ${widget.user.name}");

    ///when the user click the submit button the [ImageUploader] stream controller
    ///will send the list of selected messages to PUT to the server

    imageUploader.submittingController.stream.listen((images) {
      if (images is List<File>) {
        productRepository.postProduct(images, p!).then((value) {
          setState(() {
            submitting = false;
          });
          context.pushNamed("product", extra: value);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(UserMapper.toData(widget.user).toMap().toString());
    if (MediaQuery.of(context).size.width > 425) {
      sectionBtnMargin = 75;
    } else {
      sectionBtnMargin = (MediaQuery.of(context).size.width - 150) / 4;
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        scrolledUnderElevation: 0.0,
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            "Vendi",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Form(
        key: productFormKey,
        child: ListView(
          children: [
            //ImgUploader
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: MediaQuery.of(context).size.width,
              height: 288,
              child: imageUploader,
            ),
            const SizedBox(height: 10),
            //Heading categorie
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 12),
              child: const SizedBox(
                width: 380,
                child: Text(
                  "Seleziona una categoria",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
                              ? Theme.of(context).colorScheme.inversePrimary
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
                            color: Theme.of(context).colorScheme.background,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(100),
                            ),
                          ),
                          child: IconButton(
                            splashRadius: 0.1,
                            onPressed: (() {
                              setState(() {
                                categories = [true, false, false];
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
                            ? Theme.of(context).colorScheme.inversePrimary
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
                          color: Theme.of(context).colorScheme.background,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(100),
                          ),
                        ),
                        child: IconButton(
                            splashRadius: 0.1,
                            onPressed: (() {
                              setState(() {
                                categories = [false, true, false];
                              });
                            }),
                            icon: SvgPicture.asset(
                              "assets/android/home/ghianda_icon.svg",
                              height: 40,
                              width: 40,
                            ),
                            style: IconButton.styleFrom(elevation: 1)),
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
                            ? Theme.of(context).colorScheme.inversePrimary
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
                          color: Theme.of(context).colorScheme.background,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(100),
                          ),
                        ),
                        height: 70,
                        width: 70,
                        child: IconButton(
                          onPressed: (() {
                            setState(() {
                              categories = [false, false, true];
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
            Container(
              margin: const EdgeInsets.only(top: 20),
              width: 370,
              height: 100,
              alignment: Alignment.center,
              child: SizedBox(
                width: 370,
                child: TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    labelText: 'Titolo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    return value == "" ? "Inserire un titolo" : null;
                  },
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              width: 370,
              alignment: Alignment.center,
              child: SizedBox(
                width: 370,
                child: TextFormField(
                  maxLines: 5,
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: 'Descrizione',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    return value == "" ? "Inserire una descrizione" : null;
                  },
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              width: 370,
              height: 100,
              alignment: Alignment.center,
              child: SizedBox(
                width: 370,
                child: TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.euro),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    labelText: 'Prezzo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == "") {
                      return "Inserire un prezzo";
                    }
                    RegExp numeric = RegExp(r'^\d{0,8}(\.\d{1,4})?$');
                    return numeric.hasMatch(value!) ? null : "Dati incorretti";
                  },
                ),
              ),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LoadingButton(
                isLoading: submitting,
                text: "Vendi",
                onPressed: () async {
                  if (productFormKey.currentState!.validate()) {
                    if (!categories[0] && !categories[1] && !categories[2]) {
                      Fluttertoast.showToast(
                        msg: "Categoria non selezionata",
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    } else {
                      setState(() {
                        submitting = true;
                      });

                      String category = "";
                      if (categories[0]) {
                        category = "legname";
                      }
                      if (categories[1]) {
                        category = "biomasse";
                      }
                      if (categories[2]) {
                        category = "pellet";
                      }

                      p = ProductDto(
                        author: LoginManager.instance.userId,
                        title: titleController.text,
                        description: descriptionController.text,
                        place: widget.user.city!,
                        price: double.parse(priceController.text),
                        category: category,
                      );

                      imageUploader.uploadImageStreamCtrl.add(true);
                      FocusManager.instance.primaryFocus?.unfocus();
                      //erore nella pubblicazione
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }
}
