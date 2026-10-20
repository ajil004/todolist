import 'dart:async';
import 'package:flutter/services.dart';
import '../models/task.dart';

typedef ReminderCallback = void Function(Task task);

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  Timer? _timer;
  List<Task> _tasks = [];
  ReminderCallback? _onReminder;

  void initialize({
    required List<Task> tasks,
    required ReminderCallback onReminder,
  }) {
    _tasks = tasks;
    _onReminder = onReminder;
    _startTimer();
  }

  void updateTasks(List<Task> tasks) {
    _tasks = tasks;
  }

  void _startTimer() {
    _timer?.cancel();
    // Check every 10 seconds for due reminders
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkReminders();
    });
    // Also check immediately
    _checkReminders();
  }

  void _checkReminders() {
    final now = DateTime.now();
    for (int i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      if (task.hasReminder &&
          !task.isCompleted &&
          !task.isReminderTriggered &&
          task.reminderDateTime != null &&
          task.reminderDateTime!.isBefore(now)) {
        // Trigger haptic sequence
        triggerReminderHaptic();
        // Invoke UI callback
        if (_onReminder != null) {
          _onReminder!(task);
        }
      }
    }
  }

  /// Vibrates with a distinct multi-beat pattern for reminders
  static Future<void> triggerReminderHaptic() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 120));
      await HapticFeedback.vibrate();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.heavyImpact();
    } catch (_) {
      // Graceful fallback on devices without vibrator motor
    }
  }

  /// Single short haptic for task check/uncheck
  static Future<void> triggerCompletionHaptic() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Subtle click haptic for UI actions
  static Future<void> triggerClickHaptic() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Light impact for deletion or filters
  static Future<void> triggerLightHaptic() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  void dispose() {
    _timer?.cancel();
  }
}
