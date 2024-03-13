import 'package:fuocherello/data/datasources/chat_datasource.dart';
import 'package:fuocherello/data/datasources/chat_list_datasource.dart';
import 'package:fuocherello/data/datasources/product_datasource.dart';
import 'package:fuocherello/data/datasources/user_datasources.dart';
import 'package:fuocherello/data/mappers/product_mapper.dart';
import 'package:fuocherello/data/mappers/public_user_mapper.dart';
import 'package:fuocherello/data/mappers/user_mapper.dart';
import 'package:fuocherello/data/repositories/chat_list_repository.dart';
import 'package:fuocherello/data/repositories/chat_repositoy.dart';
import 'package:fuocherello/data/repositories/product_repository.dart';
import 'package:fuocherello/data/repositories/public_user_repository.dart';
import 'package:fuocherello/data/repositories/user_repository.dart';
import 'package:fuocherello/domain/repositories/chat_list_repository.dart';
import 'package:fuocherello/domain/repositories/chat_repository.dart';
import 'package:fuocherello/domain/repositories/product_repository.dart';
import 'package:fuocherello/domain/repositories/public_user_repository.dart';
import 'package:fuocherello/domain/repositories/user_repository.dart';

//main repository to let widget access to the same repositories
class AppRepository {
  static final AppRepository _appRepository = AppRepository._internal();
  AppRepository._internal();
  static AppRepository get instance => _appRepository;

  final ChatRepository _chatRepository = DbChatRepository(ChatDataSource());
  final ChatListRepository _chatListRepository =
      DbChatList(ChatListDataSource());
  final ProductRepository _productRepository =
      DbProductRepository(ProductDataSource(), ProductMapper());
  final PublicUserRepository _publicUserRepository =
      DbPublicUserRepository(UserDataSource(), PublicUserMapper());

  UserRepository get userRepository =>
      DbUserRepository(UserDataSource(), UserMapper());
  ChatRepository get chatRepository => _chatRepository;
  ChatListRepository get chatListRepository => _chatListRepository;
  ProductRepository get productRepository => _productRepository;
  PublicUserRepository get publicUserRepository => _publicUserRepository;
}
