import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/task.dart';
import '../services/reminder_service.dart';
import '../services/task_storage.dart';
import '../widgets/category_selector.dart';
import '../widgets/filter_sort_sheet.dart';
import '../widgets/stats_overview.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_dialog.dart';

class TodoHomeScreen extends StatefulWidget {
  const TodoHomeScreen({super.key});

  @override
  State<TodoHomeScreen> createState() => _TodoHomeScreenState();
}

class _TodoHomeScreenState extends State<TodoHomeScreen> {
  List<Task> _tasks = [];
  List<TaskCategory> _categories = List.from(TaskCategory.defaultCategories);
  bool _isLoading = true;

  // Search & Filters
  String _searchQuery = '';
  String _selectedCategory = 'All';
  TaskStatusFilter _statusFilter = TaskStatusFilter.all;
  TaskPriority? _priorityFilter;
  TaskSortOption _sortOption = TaskSortOption.dueDateAsc;
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();

  final ReminderService _reminderService = ReminderService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _reminderService.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final loadedTasks = await TaskStorageService.loadTasks();
    final customCategories = await TaskStorageService.loadCustomCategories();

    final allCategories = List<TaskCategory>.from(TaskCategory.defaultCategories);
    for (final catName in customCategories) {
      if (!allCategories.any((c) => c.name.toLowerCase() == catName.toLowerCase())) {
        allCategories.add(
          TaskCategory(
            id: catName,
            name: catName,
            icon: Icons.bookmark_rounded,
            color: const Color(0xFF0EA5E9),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _tasks = loadedTasks;
        _categories = allCategories;
        _isLoading = false;
      });

      _reminderService.initialize(
        tasks: _tasks,
        onReminder: _handleReminderTriggered,
      );
    }
  }

  Future<void> _saveTasks() async {
    await TaskStorageService.saveTasks(_tasks);
    _reminderService.updateTasks(_tasks);
  }

  void _handleReminderTriggered(Task task) {
    if (!mounted) return;

    // Show reminder alert modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFF6366F1),
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Task Reminder!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                task.description,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: task.priority.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flag_rounded, size: 14, color: task.priority.color),
                  const SizedBox(width: 6),
                  Text(
                    'Priority: ${task.priority.label}  •  Category: ${task.category}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: task.priority.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _snoozeReminder(task, const Duration(minutes: 10));
            },
            child: const Text('Snooze 10m'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _dismissReminder(task);
            },
            child: const Text('Dismiss'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _toggleTaskCompletion(task, true);
            },
            child: const Text('Mark Done'),
          ),
        ],
      ),
    );
  }

  void _snoozeReminder(Task task, Duration duration) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          reminderDateTime: DateTime.now().add(duration),
          isReminderTriggered: false,
        );
      }
    });
    _saveTasks();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Snoozed "${task.title}" for 10 minutes.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _dismissReminder(Task task) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(isReminderTriggered: true);
      }
    });
    _saveTasks();
  }

  void _addTask(Task task) {
    setState(() {
      _tasks.insert(0, task);
    });
    _saveTasks();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${task.title}" created.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _updateTask(Task updated) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == updated.id);
      if (index != -1) {
        _tasks[index] = updated;
      }
    });
    _saveTasks();
  }

  void _toggleTaskCompletion(Task task, bool completed) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          isCompleted: completed,
          completedAt: completed ? DateTime.now() : null,
        );
      }
    });
    _saveTasks();
  }

  void _deleteTask(Task task) {
    final deletedIndex = _tasks.indexWhere((t) => t.id == task.id);
    if (deletedIndex == -1) return;

    final removedTask = _tasks[deletedIndex];

    setState(() {
      _tasks.removeAt(deletedIndex);
    });
    _saveTasks();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${removedTask.title}"'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _tasks.insert(deletedIndex, removedTask);
            });
            _saveTasks();
          },
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Fitness, Groceries, Ideas',
            labelText: 'Category Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                if (!_categories.any((c) => c.name.toLowerCase() == text.toLowerCase())) {
                  final newCat = TaskCategory(
                    id: text,
                    name: text,
                    icon: Icons.label_important_rounded,
                    color: const Color(0xFF0EA5E9),
                  );
                  setState(() {
                    _categories.add(newCat);
                    _selectedCategory = text;
                  });
                  final customNames = _categories
                      .where((c) => !TaskCategory.defaultCategories.any((dc) => dc.id == c.id))
                      .map((c) => c.name)
                      .toList();
                  await TaskStorageService.saveCustomCategories(customNames);
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  List<Task> _getFilteredAndSortedTasks() {
    return _tasks.where((task) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = task.title.toLowerCase().contains(query);
        final matchDesc = task.description.toLowerCase().contains(query);
        final matchCategory = task.category.toLowerCase().contains(query);
        if (!matchTitle && !matchDesc && !matchCategory) return false;
      }

      // Category filter
      if (_selectedCategory != 'All' && task.category != _selectedCategory) {
        return false;
      }

      // Status filter
      if (_statusFilter == TaskStatusFilter.pending && task.isCompleted) {
        return false;
      }
      if (_statusFilter == TaskStatusFilter.completed && !task.isCompleted) {
        return false;
      }

      // Priority filter
      if (_priorityFilter != null && task.priority != _priorityFilter) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        // Keep uncompleted tasks before completed tasks when sorting
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }

        switch (_sortOption) {
          case TaskSortOption.dueDateAsc:
            if (a.dueDate == null && b.dueDate == null) return 0;
            if (a.dueDate == null) return 1;
            if (b.dueDate == null) return -1;
            return a.dueDate!.compareTo(b.dueDate!);

          case TaskSortOption.priorityDesc:
            final pDiff = b.priority.rank.compareTo(a.priority.rank);
            if (pDiff != 0) return pDiff;
            return b.createdAt.compareTo(a.createdAt);

          case TaskSortOption.createdAtDesc:
            return b.createdAt.compareTo(a.createdAt);

          case TaskSortOption.alphabetical:
            return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        }
      });
  }

  bool get _hasActiveFilters =>
      _statusFilter != TaskStatusFilter.all ||
      _priorityFilter != null ||
      _sortOption != TaskSortOption.dueDateAsc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredTasks = _getFilteredAndSortedTasks();

    return Scaffold(
      appBar: AppBar(
        title: _isSearchOpen
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search tasks, notes, category...',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
              )
            : const Text(
                'My Tasks',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearchOpen ? Icons.close_rounded : Icons.search_rounded),
            tooltip: _isSearchOpen ? 'Close search' : 'Search tasks',
            onPressed: () {
              ReminderService.triggerClickHaptic();
              setState(() {
                _isSearchOpen = !_isSearchOpen;
                if (!_isSearchOpen) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Filter & Sort',
                onPressed: () {
                  ReminderService.triggerClickHaptic();
                  FilterSortSheet.show(
                    context,
                    statusFilter: _statusFilter,
                    priorityFilter: _priorityFilter,
                    sortOption: _sortOption,
                    onStatusFilterChanged: (s) => setState(() => _statusFilter = s),
                    onPriorityFilterChanged: (p) => setState(() => _priorityFilter = p),
                    onSortOptionChanged: (so) => setState(() => _sortOption = so),
                    onReset: () => setState(() {
                      _statusFilter = TaskStatusFilter.all;
                      _priorityFilter = null;
                      _sortOption = TaskSortOption.dueDateAsc;
                    }),
                  );
                },
              ),
              if (_hasActiveFilters)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  // Overview Dashboard Card with pending / completed counts and haptic test
                  SliverToBoxAdapter(
                    child: StatsOverviewCard(
                      tasks: _tasks,
                      onTestHaptic: () async {
                        await ReminderService.triggerReminderHaptic();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.vibration_rounded, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Haptic Vibrate Pulse Triggered!'),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  // Category horizontal selector
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: CategorySelector(
                        categories: _categories,
                        selectedCategory: _selectedCategory,
                        tasks: _tasks,
                        onCategorySelected: (cat) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        onAddCategory: _showAddCategoryDialog,
                      ),
                    ),
                  ),

                  // Filter / search status banner if active
                  if (_searchQuery.isNotEmpty || _hasActiveFilters || _selectedCategory != 'All')
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              'Showing ${filteredTasks.length} ${_selectedCategory != 'All' ? 'in $_selectedCategory' : 'tasks'}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            if (_hasActiveFilters || _searchQuery.isNotEmpty || _selectedCategory != 'All')
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _searchController.clear();
                                    _selectedCategory = 'All';
                                    _statusFilter = TaskStatusFilter.all;
                                    _priorityFilter = null;
                                    _sortOption = TaskSortOption.dueDateAsc;
                                  });
                                },
                                child: const Text('Clear Filters', style: TextStyle(fontSize: 12)),
                              ),
                          ],
                        ),
                      ),
                    ),

                  // Tasks list or Empty state
                  if (filteredTasks.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty || _hasActiveFilters
                                  ? Icons.search_off_rounded
                                  : Icons.task_alt_rounded,
                              size: 64,
                              color: theme.colorScheme.outlineVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty || _hasActiveFilters
                                  ? 'No matching tasks found'
                                  : 'No tasks in this list',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _searchQuery.isNotEmpty || _hasActiveFilters
                                  ? 'Try adjusting your search or filters'
                                  : 'Tap "+" to add your first task with priority & reminders',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final task = filteredTasks[index];
                          return TaskCard(
                            task: task,
                            onToggleComplete: (completed) =>
                                _toggleTaskCompletion(task, completed),
                            onEdit: () {
                              TaskFormDialog.show(
                                context,
                                task: task,
                                categories: _categories,
                                onSave: _updateTask,
                              );
                            },
                            onDelete: () => _deleteTask(task),
                          );
                        },
                        childCount: filteredTasks.length,
                      ),
                    ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 90),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ReminderService.triggerLightHaptic();
          TaskFormDialog.show(
            context,
            categories: _categories,
            onSave: _addTask,
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
