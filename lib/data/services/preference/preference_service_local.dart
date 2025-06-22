import 'package:bills_reminder/data/services/preference/preference_bool.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'preference_service.dart';

class PreferenceServiceLocal implements PreferenceService {
  @override
  Future<bool> isBool(PreferenceBool preference) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(preference.key) ?? preference.defaultValue;
  }

  @override
  Future<void> setBool(PreferenceBool preference, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(preference.key, value);
  }
}
