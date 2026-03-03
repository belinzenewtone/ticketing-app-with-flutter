class Comment {
  final String id;
  final String ticketId;
  final String content;
  final String authorId;
  final String authorName;
  final bool isInternal;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.ticketId,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.isInternal,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'] as String,
        ticketId: json['ticketId'] as String,
        content: json['content'] as String,
        authorId: json['authorId'] as String,
        authorName: json['authorName'] as String? ?? 'Unknown',
        isInternal: json['isInternal'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
