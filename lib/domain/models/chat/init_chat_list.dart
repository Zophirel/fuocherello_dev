import 'package:flutter/material.dart';

class InitChatList {
  Widget contactList;
  List<Map<String, Object?>>? contactData;
  bool thereAreNoContacts = false;
  InitChatList(this.contactList, this.contactData) {
    thereAreNoContacts = contactData!.isEmpty;
  }
}
