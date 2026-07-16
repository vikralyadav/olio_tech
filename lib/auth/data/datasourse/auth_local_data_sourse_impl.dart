import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/ user_model.dart';
import 'auth_local_data_sourse.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences prefs;

  AuthLocalDataSourceImpl(this.prefs);

  static const _userKey = "user";
  static const _passwordKey = "password";
  static const _loggedInKey = "loggedIn";
  static const _rememberKey = "rememberMe";

  @override
  Future<void> register({
    required UserModel user,
    required String password,
  }) async {
    await prefs.setString(
      _userKey,
      jsonEncode(user.toJson()),
    );

    await prefs.setString(
      _passwordKey,
      password,
    );
  }

  @override
  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final userString = prefs.getString(_userKey);

    if (userString == null) return false;

    final user = UserModel.fromJson(
      jsonDecode(userString),
    );

    final savedPassword = prefs.getString(_passwordKey);

    if (user.email == email &&
        savedPassword == password) {
      await prefs.setBool(_loggedInKey, true);
      await prefs.setBool(_rememberKey, rememberMe);

      return true;
    }

    return false;
  }

  @override
  Future<void> logout() async {
    await prefs.setBool(_loggedInKey, false);
  }

  @override
  Future<bool> isLoggedIn() async {
    final remember = prefs.getBool(_rememberKey) ?? false;

    if (!remember) {
      return false;
    }

    return prefs.getBool(_loggedInKey) ?? false;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final userString = prefs.getString(_userKey);

    if (userString == null) return null;

    return UserModel.fromJson(
      jsonDecode(userString),
    );
  }
}