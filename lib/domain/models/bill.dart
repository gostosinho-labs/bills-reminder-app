class Bill {
  final String name;
  final DateTime date;
  final bool notification;
  final bool recurrence;
  final bool paid;
  final double value;

  Bill({
    required this.name,
    required this.date,
    required this.notification,
    required this.recurrence,
    required this.paid,
    required this.value,
  });
}
