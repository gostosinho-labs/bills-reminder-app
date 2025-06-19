enum BillsPreferenceBool {
  startup('startup', true),
  perBill('per_bill', true),
  daily('daily', true);

  final String key;
  final bool defaultValue;

  const BillsPreferenceBool(this.key, this.defaultValue);
}
