import 'package:flutter/material.dart';

class TaskCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const TaskCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<TaskCategory> defaultCategories = [
    TaskCategory(
      id: 'General',
      name: 'General',
      icon: Icons.checklist_rounded,
      color: Color(0xFF6366F1), // Indigo
    ),
    TaskCategory(
      id: 'Personal',
      name: 'Personal',
      icon: Icons.person_rounded,
      color: Color(0xFFEC4899), // Pink
    ),
    TaskCategory(
      id: 'Work',
      name: 'Work',
      icon: Icons.work_rounded,
      color: Color(0xFF3B82F6), // Blue
    ),
    TaskCategory(
      id: 'Shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFF10B981), // Emerald
    ),
    TaskCategory(
      id: 'Health',
      name: 'Health',
      icon: Icons.favorite_rounded,
      color: Color(0xFFEF4444), // Red
    ),
    TaskCategory(
      id: 'Study',
      name: 'Study',
      icon: Icons.school_rounded,
      color: Color(0xFF8B5CF6), // Purple
    ),
    TaskCategory(
      id: 'Finance',
      name: 'Finance',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFFF59E0B), // Amber
    ),
  ];

  static TaskCategory getCategory(String name) {
    return defaultCategories.firstWhere(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
      orElse: () => TaskCategory(
        id: name,
        name: name,
        icon: Icons.label_rounded,
        color: const Color(0xFF64748B),
      ),
    );
  }
}
