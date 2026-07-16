import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controls the app-wide [ThemeMode] and persists the choice.
class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences prefs;
  static const _key = 'theme_mode';

  ThemeCubit(this.prefs) : super(_read(prefs));

  static ThemeMode _read(SharedPreferences prefs) {
    switch (prefs.getString(_key)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await prefs.setString(_key, mode.name);
  }

  Future<void> toggleDark(bool isDark) =>
      setMode(isDark ? ThemeMode.dark : ThemeMode.light);

  bool get isDark => state == ThemeMode.dark;
}
