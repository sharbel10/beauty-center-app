import 'dart:convert';

import 'package:beauty_center_app/features/auth/models/customer.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@singleton
class PreferenceManager {
  PreferenceManager(this._sharedPreferences);

  static const String _firstLaunchKey = 'is_first_launch';
  static const String _languageKey = 'language';
  static const String _loggedInKey = 'is_logged_in';
  static const String _customerKey = 'customer_profile';

  final SharedPreferences _sharedPreferences;

  bool isFirstLaunch() {
    return _sharedPreferences.getBool(_firstLaunchKey) ?? true;
  }

  Future<void> setFirstLaunch() async {
    await _sharedPreferences.setBool(_firstLaunchKey, false);
  }

  Future<void> markFirstLaunchCompleted() async {
    await _sharedPreferences.setBool(_firstLaunchKey, false);
  }

  String? getLanguage() {
    return _sharedPreferences.getString(_languageKey);
  }

  Future<void> setLanguage(String lang) async {
    await _sharedPreferences.setString(_languageKey, lang);
  }

  bool isLoggedIn() {
    return _sharedPreferences.getBool(_loggedInKey) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    await _sharedPreferences.setBool(_loggedInKey, value);
  }

  Future<void> saveCustomer(Customer customer) async {
    await _sharedPreferences.setString(
      _customerKey,
      jsonEncode(customer.toJson()),
    );
  }

  Customer? getCustomer() {
    final String? raw = _sharedPreferences.getString(_customerKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return Customer.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  String? getCustomerName() => getCustomer()?.name;

  Future<void> clearCustomer() async {
    await _sharedPreferences.remove(_customerKey);
  }

  Future<void> clear() async {
    await _sharedPreferences.clear();
  }
}
