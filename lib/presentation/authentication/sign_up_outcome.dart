import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//screen that let the user ask for a password renewal token (sent by the server by email)
class SignUpOutcome extends StatefulWidget {
  const SignUpOutcome({
    super.key,
  });

  @override
  State<SignUpOutcome> createState() => _SignUpOutcomeState();
}

class _SignUpOutcomeState extends State<SignUpOutcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conferma la tua mail"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: const Text(
                  "Per ultimare la registrazione e' neccessario cliccare il link mandato all'email indicata"),
            ),
            SizedBox(height: 30),
            ElevatedButton(
                onPressed: () => context.go("/"),
                child: Text("Torna alla Home"))
          ],
        ),
      ),
    );
  }
}
