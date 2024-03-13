import 'package:fuocherello/data/datasources/user_datasources.dart';
import 'package:fuocherello/data/entities/user/publc_user_data.dart';
import 'package:fuocherello/data/mappers/public_user_mapper.dart';
import 'package:fuocherello/domain/repositories/public_user_repository.dart';
import 'package:fuocherello/helper/singletons/login_manager.dart';
import '../../domain/models/user/public_user.dart';

class DbPublicUserRepository implements PublicUserRepository {
  static LoginManager manager = LoginManager.instance;

  final UserDataSource datasource;
  final PublicUserMapper mapper;

  DbPublicUserRepository(this.datasource, this.mapper);

  @override
  Future<PublicUser> getOtherUserPublicInfo(String userId) async {
    var data = await datasource.getOtherUserPublicInfo(userId);
    PublicUserData userData = PublicUserData.fromMap(data);

    return mapper.fromData(userData);
  }
}
