import 'package:flutter/material.dart';
import 'package:fuocherello/domain/models/user/user.dart';

class DatePickerField extends StatefulWidget {
  DatePickerField({
    super.key,
    this.user,
  });

  get dateString {
    return dateOfBirthCtrl.text != ""
        ? dateOfBirthCtrl.text
        : user!.getUserFormatDate();
  }

  DateTime? get date {
    List<String> dateStringValue = [];
    List<int> dateIntValue = [];
    if (dateOfBirthCtrl.text == "") {
      dateStringValue.clear();
      dateIntValue.clear();
      if (user != null) {
        dateStringValue = user!.getUserFormatDate().split(' - ');
        for (String date in dateStringValue) {
          dateIntValue.add(int.parse(date));
        }
        return DateTime(dateIntValue[2], dateIntValue[1], dateIntValue[0]);
      } else {
        return null;
      }
    } else {
      dateStringValue.clear();
      dateIntValue.clear();
      dateStringValue = dateOfBirthCtrl.text.split(' - ');
      for (String date in dateStringValue) {
        dateIntValue.add(int.parse(date));
      }
      return DateTime(dateIntValue[2], dateIntValue[1], dateIntValue[0]);
    }
  }

  final User? user;
  final TextEditingController dateOfBirthCtrl = TextEditingController();
  @override
  State<DatePickerField> createState() => _DatepickerFieldState();
}

class _DatepickerFieldState extends State<DatePickerField> {
  DateTime? pickedDate;

  @override
  Widget build(BuildContext context) {
    print(
        "${widget.dateOfBirthCtrl.text} - ${widget.user?.getUserFormatDate()}");

    return TextFormField(
      controller: widget.dateOfBirthCtrl, //editing controller of this TextField
      decoration: InputDecoration(
        hintText: widget.user == null
            ? "-- -- --"
            : widget.dateOfBirthCtrl.text != ""
                ? widget.dateOfBirthCtrl.text
                : widget.user!.getUserFormatDate(),
        suffixIcon: const Icon(Icons.calendar_month),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelText: 'Data di nascita',
        border: const OutlineInputBorder(),
      ),
      readOnly: true, // when true user cannot edit text
      onTap: () async {
        print("SELECTING DATE ");
        var hundreadYearsAgo = DateTime(DateTime.now().year - 100);
        pickedDate = await showDatePicker(
          context: context,
          initialDate:
              widget.user != null ? widget.user!.dateOfBirth! : DateTime.now(),
          firstDate: hundreadYearsAgo,
          lastDate: DateTime.now(),
        );

        if (pickedDate != null) {
          String formattedDate =
              "${pickedDate!.day} - ${pickedDate!.month} - ${pickedDate!.year}";
          setState(() {
            widget.dateOfBirthCtrl.text = formattedDate;
          });
        } else {
          print("Date is not selected");
        }
      },
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          return null;
        } else {
          return "Campo errato";
        }
      },
    );
  }
}
