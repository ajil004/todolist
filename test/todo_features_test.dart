import 'package:flutter_test/flutter_test.dart';
import 'package:todolist/models/category.dart';
import 'package:todolist/models/task.dart';

void main() {
  group('Task Model & Serialization Tests', () {
    test('Task creation and default properties', () {
      final task = Task(
        id: 't1',
        title: 'Buy groceries',
        category: 'Shopping',
        priority: TaskPriority.high,
        dueDate: DateTime(2026, 10, 25, 14, 0),
        hasReminder: true,
        reminderDateTime: DateTime(2026, 10, 25, 13, 30),
      );

      expect(task.id, 't1');
      expect(task.title, 'Buy groceries');
      expect(task.category, 'Shopping');
      expect(task.priority, TaskPriority.high);
      expect(task.isCompleted, false);
      expect(task.hasReminder, true);
      expect(task.reminderDateTime, isNotNull);
    });

    test('Task toJson and fromJson roundtrip serialization', () {
      final original = Task(
        id: 't2',
        title: 'Submit report',
        description: 'Quarterly financial report',
        category: 'Work',
        priority: TaskPriority.medium,
        dueDate: DateTime(2026, 11, 1, 10, 0),
        hasReminder: true,
        reminderDateTime: DateTime(2026, 11, 1, 9, 0),
        isCompleted: true,
        completedAt: DateTime(2026, 10, 20, 11, 0),
        isReminderTriggered: false,
      );

      final json = original.toJson();
      final restored = Task.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.description, original.description);
      expect(restored.category, original.category);
      expect(restored.priority, original.priority);
      expect(restored.isCompleted, original.isCompleted);
      expect(restored.hasReminder, original.hasReminder);
      expect(restored.dueDate?.toIso8601String(), original.dueDate?.toIso8601String());
      expect(restored.reminderDateTime?.toIso8601String(), original.reminderDateTime?.toIso8601String());
    });

    test('Task copyWith updates fields correctly', () {
      final task = Task(
        id: 't3',
        title: 'Gym session',
        priority: TaskPriority.low,
      );

      final updated = task.copyWith(
        title: 'Gym session - Leg Day',
        priority: TaskPriority.high,
        isCompleted: true,
      );

      expect(updated.id, 't3');
      expect(updated.title, 'Gym session - Leg Day');
      expect(updated.priority, TaskPriority.high);
      expect(updated.isCompleted, true);
    });

    test('Priority levels rank correctly', () {
      expect(TaskPriority.high.rank > TaskPriority.medium.rank, true);
      expect(TaskPriority.medium.rank > TaskPriority.low.rank, true);
    });
  });

  group('Category & Filter Tests', () {
    test('Default categories exist with appropriate names and icons', () {
      final categories = TaskCategory.defaultCategories;
      expect(categories.any((c) => c.name == 'Work'), true);
      expect(categories.any((c) => c.name == 'Personal'), true);
      expect(categories.any((c) => c.name == 'Shopping'), true);
      expect(categories.any((c) => c.name == 'Health'), true);
    });

    test('Filter tasks by status and priority', () {
      final tasks = [
        Task(id: '1', title: 'Task 1', priority: TaskPriority.low, isCompleted: false),
        Task(id: '2', title: 'Task 2', priority: TaskPriority.high, isCompleted: true),
        Task(id: '3', title: 'Task 3', priority: TaskPriority.high, isCompleted: false),
      ];

      final pendingTasks = tasks.where((t) => !t.isCompleted).toList();
      expect(pendingTasks.length, 2);

      final completedTasks = tasks.where((t) => t.isCompleted).toList();
      expect(completedTasks.length, 1);

      final highPriorityPending = tasks.where((t) => !t.isCompleted && t.priority == TaskPriority.high).toList();
      expect(highPriorityPending.length, 1);
      expect(highPriorityPending.first.title, 'Task 3');
    });

    test('Filter and sort by due date', () {
      final now = DateTime.now();
      final tasks = [
        Task(id: '1', title: 'Late Task', dueDate: now.add(const Duration(days: 3))),
        Task(id: '2', title: 'Soon Task', dueDate: now.add(const Duration(hours: 1))),
        Task(id: '3', title: 'No Due Date Task', dueDate: null),
      ];

      tasks.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });

      expect(tasks[0].title, 'Soon Task');
      expect(tasks[1].title, 'Late Task');
      expect(tasks[2].title, 'No Due Date Task');
    });
  });
}
