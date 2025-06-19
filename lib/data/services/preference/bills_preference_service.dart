import 'package:bills_reminder/data/services/preference/bills_preference_bool.dart';

abstract class BillsPreferenceService {
  Future<bool> isBool(BillsPreferenceBool preference);
  Future<void> setBool(BillsPreferenceBool preference, bool value);
}
