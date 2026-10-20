import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskStorageService {
  static const String _tasksKey = 'app_todo_tasks_v1';
  static const String _categoriesKey = 'app_custom_categories_v1';

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_tasksKey);

    if (jsonString == null || jsonString.isEmpty) {
      // First run: provide initial helpful tasks
      final initialTasks = _getInitialTasks();
      await saveTasks(initialTasks);
      return initialTasks;
    }

    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => Task.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = tasks.map((t) => t.toJson()).toList();
    await prefs.setString(_tasksKey, jsonEncode(jsonList));
  }

  static Future<List<String>> loadCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_categoriesKey) ?? [];
  }

  static Future<void> saveCustomCategories(List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_categoriesKey, categories);
  }

  static List<Task> _getInitialTasks() {
    final now = DateTime.now();
    return [
      Task(
        id: '1',
        title: 'Complete project documentation',
        description: 'Review architecture diagram and API contracts before client meeting',
        category: 'Work',
        priority: TaskPriority.high,
        dueDate: now.add(const Duration(hours: 4)),
        hasReminder: true,
        reminderDateTime: now.add(const Duration(hours: 3)),
        isCompleted: false,
      ),
      Task(
        id: '2',
        title: 'Weekly grocery shopping',
        description: 'Milk, oats, Greek yogurt, fresh fruits, and almonds',
        category: 'Shopping',
        priority: TaskPriority.medium,
        dueDate: now.add(const Duration(days: 1, hours: 2)),
        hasReminder: false,
        isCompleted: false,
      ),
      Task(
        id: '3',
        title: 'Morning 5km run',
        description: 'Keep steady pace under 28 minutes',
        category: 'Health',
        priority: TaskPriority.low,
        dueDate: now.subtract(const Duration(hours: 2)),
        hasReminder: false,
        isCompleted: true,
        completedAt: now.subtract(const Duration(hours: 1)),
      ),
      Task(
        id: '4',
        title: 'Read 2 chapters of Flutter Best Practices',
        description: 'Focus on state management and asynchronous patterns',
        category: 'Study',
        priority: TaskPriority.medium,
        dueDate: now.add(const Duration(days: 2)),
        hasReminder: true,
        reminderDateTime: now.add(const Duration(days: 2, hours: -1)),
        isCompleted: false,
      ),
      Task(
        id: '5',
        title: 'Pay electricity bill',
        description: 'Check online utility portal before due date',
        category: 'Finance',
        priority: TaskPriority.high,
        dueDate: now.add(const Duration(days: 3)),
        hasReminder: true,
        reminderDateTime: now.add(const Duration(days: 3, hours: -2)),
        isCompleted: false,
      ),
    ];
  }
}
