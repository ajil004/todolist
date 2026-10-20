import 'package:flutter/material.dart';

enum TaskPriority {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF10B981); // Emerald green
      case TaskPriority.medium:
        return const Color(0xFFF59E0B); // Amber / orange
      case TaskPriority.high:
        return const Color(0xFFEF4444); // Crimson red
    }
  }

  Color get backgroundColor {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFFE8F5E9);
      case TaskPriority.medium:
        return const Color(0xFFFFF7ED);
      case TaskPriority.high:
        return const Color(0xFFFEF2F2);
    }
  }

  int get rank {
    switch (this) {
      case TaskPriority.high:
        return 3;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.low:
        return 1;
    }
  }

  static TaskPriority fromString(String? value) {
    if (value == null) return TaskPriority.medium;
    return TaskPriority.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TaskPriority.medium,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final String category;
  final TaskPriority priority;
  final DateTime? dueDate;
  final bool hasReminder;
  final DateTime? reminderDateTime;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final bool isReminderTriggered;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.category = 'General',
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.hasReminder = false,
    this.reminderDateTime,
    this.isCompleted = false,
    this.completedAt,
    DateTime? createdAt,
    this.isReminderTriggered = false,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? clearDueDate,
    bool? hasReminder,
    DateTime? reminderDateTime,
    bool? clearReminderDateTime,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? createdAt,
    bool? isReminderTriggered,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: clearDueDate == true ? null : (dueDate ?? this.dueDate),
      hasReminder: hasReminder ?? this.hasReminder,
      reminderDateTime: clearReminderDateTime == true
          ? null
          : (reminderDateTime ?? this.reminderDateTime),
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      isReminderTriggered: isReminderTriggered ?? this.isReminderTriggered,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'hasReminder': hasReminder,
      'reminderDateTime': reminderDateTime?.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isReminderTriggered': isReminderTriggered,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      category: (json['category'] as String?) ?? 'General',
      priority: TaskPriority.fromString(json['priority'] as String?),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      hasReminder: json['hasReminder'] as bool? ?? false,
      reminderDateTime: json['reminderDateTime'] != null
          ? DateTime.parse(json['reminderDateTime'])
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isReminderTriggered: json['isReminderTriggered'] as bool? ?? false,
    );
  }
}
