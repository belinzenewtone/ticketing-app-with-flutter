class KnowledgeArticle {
  final String id;
  final String title;
  final String content;
  final String category;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const KnowledgeArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KnowledgeArticle.fromJson(Map<String, dynamic> json) =>
      KnowledgeArticle(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        category: json['category'] as String? ?? 'general',
        authorId: json['authorId'] as String? ?? '',
        authorName: json['authorName'] as String? ?? 'Unknown',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
