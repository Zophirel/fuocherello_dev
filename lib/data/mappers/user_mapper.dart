import 'package:fuocherello/data/entities/user/user_data.dart';
import 'package:fuocherello/domain/models/user/user.dart';

class UserMapper {
  static User fromData(UserData userData) {
    return User(
        id: userData.id,
        name: userData.name,
        surname: userData.surname,
        city: userData.city,
        email: userData.email,
        dateOfBirth: userData.dateOfBirth);
  }

  static UserData toData(User user) {
    return UserData(
        id: user.id,
        name: user.name,
        surname: user.surname,
        city: user.city,
        email: user.email,
        dateOfBirth: user.dateOfBirth);
  }
}
