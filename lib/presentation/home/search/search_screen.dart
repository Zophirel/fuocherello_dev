import 'package:flutter/material.dart';
import 'package:fuocherello/presentation/home/search/search_result.dart';

//Search screen accessible from the Home screen by clicking the search button on the top right corner of the home screen
class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
  });
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController input = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Cerca"),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary, width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Theme.of(context).colorScheme.primaryContainer),
                child: TextField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                  ),
                  controller: input,
                ),
              ),
              ItemSearchList(
                inputController: input,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
