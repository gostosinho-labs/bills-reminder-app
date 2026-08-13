import 'package:bills_reminder/data/services/preference/preference_bool.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'preference_service.dart';

class PreferenceServiceLocal implements PreferenceService {
  final _log = Logger('PreferenceServiceLocal');

  @override
  Future<bool> isBool(PreferenceBool preference) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(preference.key) ?? preference.defaultValue;

    _log.fine('Read preference ${preference.key}: $value');

    return value;
  }

  @override
  Future<void> setBool(PreferenceBool preference, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(preference.key, value);

    _log.fine('Set preference ${preference.key}: $value');
  }
}
