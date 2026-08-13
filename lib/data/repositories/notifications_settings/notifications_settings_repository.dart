abstract class NotificationsSettingsRepository {
  Future<bool> isStartupNotificationEnabled();
  Future<void> setStartupNotificationEnabled(bool value);

  Future<bool> isPerBillNotificationEnabled();
  Future<void> setPerBillNotificationEnabled(bool value);

  Future<bool> isDailyNotificationEnabled();
  Future<void> setDailyNotificationEnabled(bool value);
}
