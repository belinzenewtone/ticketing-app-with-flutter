class Machine {
  final String id;
  final String machineName;
  final String issueDescription;
  final String status;
  final String importance;
  final String requestedById;
  final String requestedByName;
  final String? assignedToId;
  final String? assignedToName;
  final String? resolutionNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Machine({
    required this.id,
    required this.machineName,
    required this.issueDescription,
    required this.status,
    required this.importance,
    required this.requestedById,
    required this.requestedByName,
    this.assignedToId,
    this.assignedToName,
    this.resolutionNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Machine.fromJson(Map<String, dynamic> json) => Machine(
        id: json['id'] as String,
        machineName: json['machineName'] as String,
        issueDescription: json['issueDescription'] as String,
        status: json['status'] as String,
        importance: json['importance'] as String,
        requestedById: json['requestedById'] as String? ?? '',
        requestedByName: json['requestedByName'] as String? ?? 'Unknown',
        assignedToId: json['assignedToId'] as String?,
        assignedToName: json['assignedToName'] as String?,
        resolutionNotes: json['resolutionNotes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
