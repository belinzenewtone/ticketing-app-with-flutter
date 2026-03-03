class Task {
  final String id;
  final String title;
  final bool completed;
  final String? ticketId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    required this.completed,
    this.ticketId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        completed: json['completed'] as bool? ?? false,
        ticketId: json['ticketId'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Task copyWith({bool? completed}) => Task(
        id: id,
        title: title,
        completed: completed ?? this.completed,
        ticketId: ticketId,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
