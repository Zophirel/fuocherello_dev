import 'package:fuocherello/data/entities/user/publc_user_data.dart';
import 'package:fuocherello/domain/models/user/public_user.dart';

class PublicUserMapper {
  PublicUser fromData(PublicUserData userData) {
    return PublicUser(
      id: userData.id,
      name: userData.name,
      propic: userData.propic,
    );
  }

  PublicUserData toData(PublicUser user) {
    return PublicUserData(
      id: user.id,
      name: user.name,
      propic: user.propic,
    );
  }
}
