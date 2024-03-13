import 'package:email_validator/email_validator.dart';

class FormValidator {
  FormValidator();

  String validatePassword(String? value) {
    RegExp regex =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    RegExp maiuscole = RegExp('^(?=.*?[A-Z])');
    RegExp minuscole = RegExp('^(?=.*?[a-z])');
    RegExp numeri = RegExp('^(?=.*?[0-9])');
    RegExp simboli = RegExp('(?=.*?[!@#\$&*~])');
    RegExp lunghezza = RegExp('.{8,}');
    if (value == null) {
      return "Password mancante";
    } else if (!maiuscole.hasMatch(value)) {
      return "Almeno una lettera maiuscola";
    } else if (!minuscole.hasMatch(value)) {
      return "Almeno una lettera minuscola";
    } else if (!numeri.hasMatch(value)) {
      return "Almeno un numero";
    } else if (!simboli.hasMatch(value)) {
      return "Almeno un simbolo [!@#\$&*~]";
    } else if (!lunghezza.hasMatch(value)) {
      return "Almeno 8 caratteri";
    } else if (regex.hasMatch(value)) {
      return "Password corretta";
    } else {
      return "Password errata";
    }
  }

  bool validateEmail(String value) => EmailValidator.validate(value);
}
