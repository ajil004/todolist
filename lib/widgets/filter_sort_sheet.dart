import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/reminder_service.dart';

enum TaskSortOption {
  dueDateAsc('Due Date (Earliest first)', Icons.calendar_today_rounded),
  priorityDesc('Priority (High to Low)', Icons.flag_rounded),
  createdAtDesc('Creation Date (Newest first)', Icons.access_time_rounded),
  alphabetical('Alphabetical (A - Z)', Icons.sort_by_alpha_rounded);

  final String label;
  final IconData icon;
  const TaskSortOption(this.label, this.icon);
}

enum TaskStatusFilter {
  all('All'),
  pending('Pending'),
  completed('Completed');

  final String label;
  const TaskStatusFilter(this.label);
}

class FilterSortSheet extends StatelessWidget {
  final TaskStatusFilter statusFilter;
  final TaskPriority? priorityFilter;
  final TaskSortOption sortOption;
  final ValueChanged<TaskStatusFilter> onStatusFilterChanged;
  final ValueChanged<TaskPriority?> onPriorityFilterChanged;
  final ValueChanged<TaskSortOption> onSortOptionChanged;
  final VoidCallback onReset;

  const FilterSortSheet({
    super.key,
    required this.statusFilter,
    required this.priorityFilter,
    required this.sortOption,
    required this.onStatusFilterChanged,
    required this.onPriorityFilterChanged,
    required this.onSortOptionChanged,
    required this.onReset,
  });

  static Future<void> show(
    BuildContext context, {
    required TaskStatusFilter statusFilter,
    required TaskPriority? priorityFilter,
    required TaskSortOption sortOption,
    required ValueChanged<TaskStatusFilter> onStatusFilterChanged,
    required ValueChanged<TaskPriority?> onPriorityFilterChanged,
    required ValueChanged<TaskSortOption> onSortOptionChanged,
    required VoidCallback onReset,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FilterSortSheet(
        statusFilter: statusFilter,
        priorityFilter: priorityFilter,
        sortOption: sortOption,
        onStatusFilterChanged: onStatusFilterChanged,
        onPriorityFilterChanged: onPriorityFilterChanged,
        onSortOptionChanged: onSortOptionChanged,
        onReset: onReset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter & Sort Tasks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ReminderService.triggerClickHaptic();
                      onReset();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Reset All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Status Filter
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: TaskStatusFilter.values.map((filter) {
                  final isSelected = statusFilter == filter;
                  return ChoiceChip(
                    label: Text(filter.label),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        ReminderService.triggerClickHaptic();
                        onStatusFilterChanged(filter);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Priority Filter
              const Text(
                'Priority',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All Priorities'),
                    selected: priorityFilter == null,
                    onSelected: (selected) {
                      if (selected) {
                        ReminderService.triggerClickHaptic();
                        onPriorityFilterChanged(null);
                      }
                    },
                  ),
                  ...TaskPriority.values.map((priority) {
                    final isSelected = priorityFilter == priority;
                    return ChoiceChip(
                      label: Text(priority.label),
                      selected: isSelected,
                      selectedColor: priority.color.withValues(alpha: 0.25),
                      onSelected: (selected) {
                        ReminderService.triggerClickHaptic();
                        onPriorityFilterChanged(selected ? priority : null);
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),

              // Sort Options
              const Text(
                'Sort Order',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              ...TaskSortOption.values.map((option) {
                final isSelected = sortOption == option;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Icon(
                    option.icon,
                    size: 20,
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 20)
                      : null,
                  onTap: () {
                    ReminderService.triggerClickHaptic();
                    onSortOptionChanged(option);
                  },
                );
              }),
              const SizedBox(height: 12),

              FilledButton(
                onPressed: () {
                  ReminderService.triggerLightHaptic();
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Apply'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
