enum PreferenceBool {
  startup('startup', true),
  perBill('per_bill', true),
  daily('daily', true);

  final String key;
  final bool defaultValue;

  const PreferenceBool(this.key, this.defaultValue);
}
