import 'package:bills_reminder/data/services/preference/bills_preference_bool.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bills_preference_service.dart';

class BillsPreferenceServiceLocal implements BillsPreferenceService {
  @override
  Future<bool> isBool(BillsPreferenceBool preference) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(preference.key) ?? preference.defaultValue;
  }

  @override
  Future<void> setBool(BillsPreferenceBool preference, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(preference.key, value);
  }
}
