import 'dart:async';
import 'dart:io';
import 'package:fuocherello/domain/models/app_repository.dart';
import 'package:fuocherello/domain/models/product/product.dart';
import 'package:fuocherello/domain/repositories/product_repository.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';
import 'package:fuocherello/helper/singletons/path_checker.dart';
import 'package:fuocherello/helper/loading_button.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:fuocherello/presentation/selling/editing/edit_product_image_carousel.dart';
import 'package:go_router/go_router.dart';

class EditForm extends StatefulWidget {
  const EditForm({super.key, required this.prodotto});
  final Product prodotto;

  @override
  State<EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  late double sectionBtnMargin;
  final ProductRepository productRepository =
      AppRepository.instance.productRepository;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final GlobalKey<FormState> productFormKey = GlobalKey<FormState>();
  final StreamController submittingController = StreamController.broadcast();

  List<bool> categories = [false, false, false];
  Product? p;
  bool submitting = false;

  late final EditFormImageUploader imageUploader = EditFormImageUploader(
    prodotto: widget.prodotto,
    submittingController: submittingController,
  );

  @override
  void initState() {
    super.initState();
    PathChecker.setLocation = "edit_form";

    /// when the user click the submit button the [EditFormImageUploader] stream controller
    /// will send the list of selected messages to PUT to the server
    submittingController.stream.listen((event) async {
      if (event is List<File>) {
        print("FILENAMES PUT");
        print(p!.fileNames);
        Product tempProduct = Product(
            id: p!.id,
            author: p!.author,
            place: p!.place,
            title: p!.title,
            description: p!.description,
            price: p!.price,
            category: p!.category,
            fileNames: event.map((e) => e.path).toList(),
            createdAt: p!.createdAt);

        productRepository.putProduct(event, p!).whenComplete(() {
          setState(() {
            submitting = false;
          });
          context.pushNamed("product", extra: tempProduct);
        });
      }
    });

    titleController.text = widget.prodotto.title;
    descriptionController.text = widget.prodotto.description;
    priceController.text = widget.prodotto.price.toString();
    if (widget.prodotto.category == "legname") {
      categories = [true, false, false];
    } else if (widget.prodotto.category == "biomasse") {
      categories = [false, true, false];
    } else if (widget.prodotto.category == "pellet") {
      categories = [false, false, true];
    }
  }

  @override
  Widget build(BuildContext context) {
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
        automaticallyImplyLeading: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        scrolledUnderElevation: 0.0,
        centerTitle: true,
        title: const Text(
          "Modifica prodotto",
          style: TextStyle(
            fontWeight: FontWeight.bold,
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
            //TITOLO
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
            //DESCRIZIONE
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
            //PREZZO
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
            //SUBMIT
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LoadingButton(
                isLoading: submitting,
                text: "Modifica",
                onPressed: () async {
                  if (productFormKey.currentState!.validate()) {
                    print("form corretto");

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

                    //gather all the new info of the current product
                    p = Product(
                        id: widget.prodotto.id,
                        author: LoginManager.instance.userId!,
                        place: widget.prodotto.place,
                        title: titleController.text,
                        description: descriptionController.text,
                        price: double.parse(priceController.text),
                        category: category,
                        fileNames: imageUploader.fileNames,
                        createdAt: widget.prodotto.createdAt);

                    //tell the EditFormImageUploader to send all the selected images to the current EditForm widget
                    submittingController.add(p);
                  }
                },
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
