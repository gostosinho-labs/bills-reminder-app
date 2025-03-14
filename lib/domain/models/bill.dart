class Bill {
  final int id;
  final String name;
  final DateTime date;
  final bool notification;
  final bool recurrence;
  final bool paid;
  final double? value;

  Bill({
    required this.id,
    required this.name,
    required this.date,
    required this.notification,
    required this.recurrence,
    required this.paid,
    this.value,
  });

  Bill copyWith({
    int? id,
    String? name,
    DateTime? date,
    bool? notification,
    bool? recurrence,
    bool? paid,
    double? value,
  }) {
    return Bill(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      notification: notification ?? this.notification,
      recurrence: recurrence ?? this.recurrence,
      paid: paid ?? this.paid,
      value: value ?? this.value,
    );
  }

  // Booleans are represented as integers in the database.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'notification': notification ? 1 : 0,
      'recurrence': recurrence ? 1 : 0,
      'paid': paid ? 1 : 0,
      'value': value,
    };
  }

  // Booleans are represented as integers in the database.
  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      notification: map['notification'] == 1,
      recurrence: map['recurrence'] == 1,
      paid: map['paid'] == 1,
      value: map['value'],
    );
  }
}
