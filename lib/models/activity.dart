class Activity {
  final String id;
  final String ticketId;
  final String action;
  final String? oldValue;
  final String? newValue;
  final String userId;
  final String userName;
  final DateTime createdAt;

  const Activity({
    required this.id,
    required this.ticketId,
    required this.action,
    this.oldValue,
    this.newValue,
    required this.userId,
    required this.userName,
    required this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as String,
        ticketId: json['ticketId'] as String,
        action: json['action'] as String,
        oldValue: json['oldValue'] as String?,
        newValue: json['newValue'] as String?,
        userId: json['userId'] as String? ?? '',
        userName: json['userName'] as String? ?? 'Unknown',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
