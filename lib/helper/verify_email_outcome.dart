import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';

//screen to welcome the user after it click on the verify email link
class VerifyEmailOutcome extends StatefulWidget {
  const VerifyEmailOutcome({
    super.key,
    required this.token,
  });
  final String token;
  @override
  State<VerifyEmailOutcome> createState() => _VerifyEmailOutcomeState();
}

class _VerifyEmailOutcomeState extends State<VerifyEmailOutcome> {
  Future<bool> isEmailVerified() async {
    print(widget.token);
    var isEmailVerified = await get(
      Uri.https(
        "www.zophirel.it:8443",
        "/api/email/verify/${widget.token}",
      ),
    );

    print(isEmailVerified.statusCode);
    if (isEmailVerified.statusCode == 200) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: isEmailVerified(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            alignment: Alignment.center,
            child: const SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: AppBar(
              toolbarHeight: 70,
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
              scrolledUnderElevation: 0.0,
              centerTitle: true,
              title: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  snapshot.data == true
                      ? "Operazione terminata!"
                      : "Errore di connessione!",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                height: MediaQuery.of(context).size.height - 2,
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).colorScheme.background,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      snapshot.data == true
                          ? "Il tuo account e' ora attivo"
                          : "C'e' stato qualche problema si prega di ritentare la registrazione",
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () => context.go("/login"),
                      child: const Text("Accedi"),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: AppBar(
              toolbarHeight: 70,
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
              scrolledUnderElevation: 0.0,
              centerTitle: true,
              title: const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  "Errore",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                height: MediaQuery.of(context).size.height - 2,
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).colorScheme.background,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                        "si prega di ritentare, non e' stato possibile contattare il server"),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () => context.go("/"),
                      child: const Text("Torna alla home"),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
