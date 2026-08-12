class Reminder {
  final String id;
  String title;
  String description;
  double amount;
  DateTime dueDate;
  bool isPaid;
  DateTime createdAt;
  DateTime? paidAt;
  final int notificationId;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.dueDate,
    required this.notificationId,
    this.isPaid = false,
    DateTime? createdAt,
    this.paidAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Reminder copyWith({
    String? title,
    String? description,
    double? amount,
    DateTime? dueDate,
    bool? isPaid,
    DateTime? paidAt,
  }) {
    return Reminder(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      notificationId: notificationId,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'amount': amount,
        'dueDate': dueDate.toIso8601String(),
        'isPaid': isPaid,
        'createdAt': createdAt.toIso8601String(),
        'paidAt': paidAt?.toIso8601String(),
        'notificationId': notificationId,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        amount: (json['amount'] as num).toDouble(),
        dueDate: DateTime.parse(json['dueDate'] as String),
        isPaid: json['isPaid'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt'] as String) : null,
        notificationId: json['notificationId'] as int,
      );

  bool get isOverdue => !isPaid && dueDate.isBefore(DateTime.now());
}
