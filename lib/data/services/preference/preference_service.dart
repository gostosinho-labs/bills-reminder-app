import 'package:bills_reminder/data/services/preference/preference_bool.dart';

abstract class PreferenceService {
  Future<bool> isBool(PreferenceBool preference);
  Future<void> setBool(PreferenceBool preference, bool value);
}
