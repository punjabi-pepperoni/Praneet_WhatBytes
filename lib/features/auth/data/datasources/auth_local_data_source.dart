import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel> getLastUser();
  Future<void> clearUser();
}

const CACHED_USER_KEY = 'CACHED_USER';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel user) {
    return sharedPreferences.setString(
      CACHED_USER_KEY,
      json.encode(user.toJson()),
    );
  }

  @override
  Future<UserModel> getLastUser() {
    final jsonString = sharedPreferences.getString(CACHED_USER_KEY);
    if (jsonString != null) {
      return Future.value(UserModel.fromJson(json.decode(jsonString)));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> clearUser() {
    return sharedPreferences.remove(CACHED_USER_KEY);
  }
}
