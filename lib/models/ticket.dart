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
  final int commentCount;
  final int publicCommentCount;

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
    this.commentCount = 0,
    this.publicCommentCount = 0,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        id: json['id'] as String,
        subject: json['subject'] as String,
        description: (json['description'] as String?) ?? '',
        status: json['status'] as String,
        priority: json['priority'] as String,
        category: json['category'] as String,
        assigneeId: json['assigneeId'] as String?,
        assigneeName: json['assigneeName'] as String?,
        submittedById: json['submittedById'] as String?
            ?? json['created_by'] as String? ?? '',
        submittedByName: json['submittedByName'] as String?
            ?? json['employee_name'] as String? ?? 'Unknown',
        submittedByEmail: json['submittedByEmail'] as String?,
        createdAt: DateTime.tryParse(
              json['createdAt'] as String? ?? json['created_at'] as String? ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(
              json['updatedAt'] as String? ?? json['updated_at'] as String? ?? '') ??
            DateTime.now(),
        commentCount: (json['comment_count'] as num?)?.toInt()
            ?? (json['commentCount'] as num?)?.toInt() ?? 0,
        publicCommentCount: (json['public_comment_count'] as num?)?.toInt()
            ?? (json['publicCommentCount'] as num?)?.toInt() ?? 0,
      );
}
