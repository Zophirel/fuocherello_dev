import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

//form field that help the user to select his birth place
class ComuniTextField extends StatefulWidget {
  ComuniTextField({super.key, required this.focus, this.initValue});
  final TextEditingController txtCtrl = TextEditingController();
  final FocusNode focus;
  final String? initValue;
  get value {
    return txtCtrl.text;
  }

  @override
  State<ComuniTextField> createState() => _ComuniTextFieldState();
}

class _ComuniTextFieldState extends State<ComuniTextField> {
  final List<String> comuni = [];

  double additionalSpace = 0;
  String selectedValue = "";
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.focus.addListener(_onFocusChange);
    if (widget.initValue != null) {
      widget.txtCtrl.text = widget.initValue!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var comuniJson = await getListaComuni();
      comuni.addAll(comuniJson.keys);
      setState(() {});
    });
    selectedValue = comuni.isEmpty ? "" : comuni[0];
  }

  void _onFocusChange() {
    if (widget.focus.hasFocus) {
      additionalSpace = 150;
    } else {
      additionalSpace = 0;
    }
    print("focus changed");
    setState(() {});
  }

  Future<Map<String, String>> getListaComuni() async {
    String response = await rootBundle
        .loadString('assets/android/data_comuni/comuni_ordinati.json');
    List<dynamic> map = jsonDecode(response);
    dynamic dataObj;
    Map<String, String> territori = {};
    for (int i = 0; i < map.length; i++) {
      dataObj = jsonDecode(jsonEncode(map[i]));
      territori.addAll(
          <String, String>{'${dataObj['Comune']}': '${dataObj['Regione']}'});
    }
    return territori;
  }

  List<String> filteredItems = [];

  void _filterList(String query) {
    setState(() {
      if (query != "") {
        filteredItems = comuni
            .where((item) => item.toLowerCase().startsWith(query.toLowerCase()))
            .toList();
      } else {
        filteredItems = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: widget.txtCtrl,
          onChanged: _filterList,
          focusNode: widget.focus,
          decoration: const InputDecoration(
            labelText: 'City',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        filteredItems.isNotEmpty
            ? Container(
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    border: Border.all(
                        color: Theme.of(context).colorScheme.primary),
                    borderRadius: const BorderRadius.all(Radius.circular(5))),
                height: filteredItems.length == 1 ? 60 : 100,
                child: Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        tileColor: Colors.white,
                        title: Text(filteredItems[index]),
                        onTap: () {
                          selectedValue = filteredItems[index];
                          widget.txtCtrl.text = filteredItems[index];
                          widget.focus.unfocus();
                          filteredItems = [];
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
              )
            : const SizedBox(),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}
