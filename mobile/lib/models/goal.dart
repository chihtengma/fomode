/// Goal Model
///
/// This represents a user's daily goal/task.
/// It matches the backend's Goal schema from backend/app/schemas/goal.py
library;

class Goal {
  // Properties (data fields)
  final int id;
  final int userId;
  final String title;
  final String? description;
  final bool completed;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Constructor
  Goal(
      {required this.id,
      required this.userId,
      required this.title,
      this.description,
      required this.completed,
      required this.createdAt,
      this.updatedAt});

  /// Create a Goal from JSON (from backend API)
  ///
  /// When backend sends us data like:
  /// {
  ///   "id": 1,
  ///   "user_id": 1,
  ///   "title": "Solve 10 LeetCode problems",
  ///   "description": "Focus on arrays",
  ///   "completed": false,
  ///   "created_at": "2025-11-14T10:00:00Z",
  ///   "updated_at": null
  /// }
  ///
  /// This function converts it to a Goal object
  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      completed: json['completed'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert Goal to JSON (to send to backend)
  ///
  /// When we need to send data to backend, we convert our Goal object
  /// back to JSON format
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": id,
      "user_id": userId,
      "title": title,
      "description": description,
      "completed": completed,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
    };
  }

  /// For debugging - prints Goal object nicely in console
  @override
  String toString() {
    return "Goal(id: $id, title: $title, completed: $completed)";
  }
}
