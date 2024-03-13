import 'package:fuocherello/domain/models/user/public_user.dart';

abstract class PublicUserRepository {
  Future<PublicUser> getOtherUserPublicInfo(String userId);
}
