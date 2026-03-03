class Ticket {
  final String id;
  final String subject;
  final String description;
  final String status;
  final String priority;
  final String category;
  final String? assigneeId;
  final String? assigneeName;
  final String submittedById;
  final String submittedByName;
  final String? submittedByEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? commentCount;

  const Ticket({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.category,
    this.assigneeId,
    this.assigneeName,
    required this.submittedById,
    required this.submittedByName,
    this.submittedByEmail,
    required this.createdAt,
    required this.updatedAt,
    this.commentCount,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        id: json['id'] as String,
        subject: json['subject'] as String,
        description: json['description'] as String,
        status: json['status'] as String,
        priority: json['priority'] as String,
        category: json['category'] as String,
        assigneeId: json['assigneeId'] as String?,
        assigneeName: json['assigneeName'] as String?,
        submittedById: json['submittedById'] as String? ?? '',
        submittedByName: json['submittedByName'] as String? ?? 'Unknown',
        submittedByEmail: json['submittedByEmail'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        commentCount: json['commentCount'] as int?,
      );
}
