import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/task.dart';
import '../services/reminder_service.dart';

class CategorySelector extends StatelessWidget {
  final List<TaskCategory> categories;
  final String selectedCategory;
  final List<Task> tasks;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onAddCategory;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.tasks,
    required this.onCategorySelected,
    required this.onAddCategory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build the list of chips: 'All', then the categories, then '+ Add'
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 2, // 'All' + categories + 'Add'
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            // 'All' Chip
            final isSelected = selectedCategory == 'All';
            final pendingCount = tasks.where((t) => !t.isCompleted).length;
            return FilterChip(
              avatar: Icon(
                Icons.grid_view_rounded,
                size: 16,
                color: isSelected ? Colors.white : theme.colorScheme.primary,
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('All'),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.25)
                          : theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$pendingCount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              showCheckmark: false,
              selectedColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                ),
              ),
              onSelected: (_) {
                ReminderService.triggerClickHaptic();
                onCategorySelected('All');
              },
            );
          }

          if (index == categories.length + 1) {
            // '+ Add Category' Chip
            return ActionChip(
              avatar: const Icon(Icons.add_rounded, size: 16),
              label: const Text('New'),
              onPressed: () {
                ReminderService.triggerClickHaptic();
                onAddCategory();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  style: BorderStyle.solid,
                ),
              ),
            );
          }

          final cat = categories[index - 1];
          final isSelected = selectedCategory == cat.name;
          final pendingCount = tasks
              .where((t) => !t.isCompleted && t.category == cat.name)
              .length;

          return FilterChip(
            avatar: Icon(
              cat.icon,
              size: 16,
              color: isSelected ? Colors.white : cat.color,
            ),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(cat.name),
                if (pendingCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.25)
                          : cat.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$pendingCount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : cat.color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: cat.color,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: isSelected ? cat.color : theme.colorScheme.outlineVariant,
              ),
            ),
            onSelected: (_) {
              ReminderService.triggerClickHaptic();
              onCategorySelected(cat.name);
            },
          );
        },
      ),
    );
  }
}
