class TicketStats {
  final int total;
  final int open;
  final int inProgress;
  final int resolved;
  final int closed;

  const TicketStats({
    required this.total,
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.closed,
  });

  factory TicketStats.fromJson(Map<String, dynamic> json) => TicketStats(
        total: json['total'] as int? ?? 0,
        open: json['open'] as int? ?? 0,
        inProgress: json['in_progress'] as int? ?? 0,
        resolved: json['resolved'] as int? ?? 0,
        closed: json['closed'] as int? ?? 0,
      );
}

class TaskStats {
  final int total;
  final int completed;
  final int pending;

  const TaskStats({
    required this.total,
    required this.completed,
    required this.pending,
  });

  factory TaskStats.fromJson(Map<String, dynamic> json) => TaskStats(
        total: json['total'] as int? ?? 0,
        completed: json['completed'] as int? ?? 0,
        pending: json['pending'] as int? ?? 0,
      );
}

class MachineStats {
  final int total;
  final int pending;
  final int inProgress;
  final int resolved;

  const MachineStats({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.resolved,
  });

  factory MachineStats.fromJson(Map<String, dynamic> json) => MachineStats(
        total: json['total'] as int? ?? 0,
        pending: json['pending'] as int? ?? 0,
        inProgress: json['in_progress'] as int? ?? 0,
        resolved: json['resolved'] as int? ?? 0,
      );
}

class DashboardStats {
  final TicketStats tickets;
  final TaskStats tasks;
  final MachineStats machines;

  const DashboardStats({
    required this.tickets,
    required this.tasks,
    required this.machines,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        tickets: TicketStats.fromJson(json['tickets'] as Map<String, dynamic>),
        tasks: TaskStats.fromJson(json['tasks'] as Map<String, dynamic>),
        machines:
            MachineStats.fromJson(json['machines'] as Map<String, dynamic>),
      );
}
