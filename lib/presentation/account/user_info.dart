import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fuocherello/presentation/authentication/form_ui/comuni_text_field.dart';
import 'package:fuocherello/data/entities/user/user_data.dart';
import 'package:fuocherello/data/mappers/user_mapper.dart';
import 'package:fuocherello/presentation/authentication/form_ui/date_picker_field.dart';
import 'package:fuocherello/domain/models/user/edit_user_info.dart';
import 'package:fuocherello/domain/models/user/user.dart';
import 'package:fuocherello/domain/repositories/user_repository.dart';
import 'package:fuocherello/helper/loading_button.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

//this page list all the info provided by the user in an editable format and will let the user logout
class UserInfoPage extends StatefulWidget {
  UserInfoPage({super.key, required this.user, required this.repo});

  final UserRepository repo;
  final User user;

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final TextEditingController nomeCtrl = TextEditingController();
  final TextEditingController cognomeCtrl = TextEditingController();
  final TextEditingController dateOfBirthCtrl = TextEditingController();
  final TextEditingController comuniCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final FocusNode comuniFocus = FocusNode();
  ComuniTextField? comuniTextField;
  final ScrollController _comuniListController = ScrollController();
  bool isLoading = false;
  late final DatePickerField datePicker = DatePickerField(
    user: widget.user,
  );

  double listAdditionalHeight = 0;

  final _picker = ImagePicker();
  XFile? pickedFile;

  @override
  void initState() {
    super.initState();

    comuniTextField = ComuniTextField(
      focus: comuniFocus,
      initValue: widget.user.city,
    );

    comuniFocus.addListener(() {
      if (comuniFocus.hasFocus) {
        print("HAS FOCUS");
        listAdditionalHeight = 300;
        setState(() {});
      }
    });

    comuniCtrl.addListener(() {
      if (comuniCtrl.text != "") {
        _comuniListController.hasClients
            ? _comuniListController
                .jumpTo(_comuniListController.position.maxScrollExtent)
            : null;
      }
    });
    nomeCtrl.value = TextEditingValue(text: widget.user.name ?? "//");
    cognomeCtrl.value = TextEditingValue(text: widget.user.surname ?? "//");
    comuniCtrl.value = TextEditingValue(text: widget.user.city ?? "");
    emailCtrl.value = TextEditingValue(text: widget.user.email ?? "//");
  }

  @override
  void dispose() {
    nomeCtrl.dispose();
    cognomeCtrl.dispose();
    dateOfBirthCtrl.dispose();

    comuniCtrl.dispose();
    emailCtrl.dispose();

    comuniFocus.dispose();
    _comuniListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    comuniFocus.hasFocus
        ? _comuniListController
            .jumpTo(_comuniListController.position.maxScrollExtent)
        : null;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        scrolledUnderElevation: 0.0,
        actions: [
          IconButton(
            onPressed: () {
              widget.repo.logOut().whenComplete(() => context.pop());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        leading: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            "Account",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          controller: _comuniListController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.05),
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onBackground,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(100),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100)),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl:
                                  'https://fuocherello-bucket.s3.cubbit.eu/profiles/${widget.user.id}/${widget.user.id}.jpeg',
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  CachedNetworkImage(
                                fadeInDuration: const Duration(seconds: 0),
                                imageUrl:
                                    "https://api.multiavatar.com/${widget.user.id}.png",
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 4,
                                    offset: Offset(0, 0)),
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                            ),
                            child: IconButton(
                              onPressed: () async {
                                pickedFile = await _picker.pickImage(
                                    source: ImageSource.gallery);
                              },
                              icon: const Icon(
                                Icons.edit,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    width: 360,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nomeCtrl,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Nome',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          controller: cognomeCtrl,
                          decoration: const InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: 'Cognome',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        datePicker,
                        const SizedBox(
                          height: 30,
                        ),
                        comuniTextField!,
                        SizedBox(
                          width: 360,
                          child: LoadingButton(
                            isLoading: isLoading,
                            text: "Modifica profilo",
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              print(datePicker.date);
                              var info = EditUserInfo(
                                nomeCtrl.text,
                                cognomeCtrl.text,
                                comuniTextField!.txtCtrl.text,
                                DateTime.parse(datePicker.date.toString()),
                              );
                              if (pickedFile != null) {
                                await CachedNetworkImage.evictFromCache(
                                    'https://fuocherello-bucket.s3.cubbit.eu/profiles/${widget.user.id}/${widget.user.id}.jpeg');
                                widget.repo.putUserInfo(
                                  info,
                                  propic:
                                      File.fromUri(Uri.parse(pickedFile!.path)),
                                );
                              } else {
                                widget.repo.putUserInfo(info);
                              }
                              UserData data = UserData(
                                id: widget.user.id,
                                name: info.name,
                                surname: info.surname,
                                city: info.city,
                                email: widget.user.email,
                                dateOfBirth: info.dateOfBirth,
                              );

                              widget.repo
                                  .updateUserInfo(UserMapper.fromData(data));

                              print("info mandate");

                              setState(() {
                                isLoading = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: comuniFocus.hasFocus ? 300 : 0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
