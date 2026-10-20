import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/task.dart';
import '../services/reminder_service.dart';

class TaskFormDialog extends StatefulWidget {
  final Task? task; // null if adding new task
  final List<TaskCategory> categories;
  final ValueChanged<Task> onSave;

  const TaskFormDialog({
    super.key,
    this.task,
    required this.categories,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    Task? task,
    required List<TaskCategory> categories,
    required ValueChanged<Task> onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskFormDialog(
        task: task,
        categories: categories,
        onSave: onSave,
      ),
    );
  }

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;

  late String _selectedCategory;
  late TaskPriority _selectedPriority;
  DateTime? _selectedDueDate;
  bool _hasReminder = false;
  DateTime? _reminderDateTime;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _selectedCategory = task?.category ??
        (widget.categories.isNotEmpty ? widget.categories.first.name : 'General');
    _selectedPriority = task?.priority ?? TaskPriority.medium;
    _selectedDueDate = task?.dueDate ?? DateTime.now().add(const Duration(hours: 3));
    _hasReminder = task?.hasReminder ?? false;
    _reminderDateTime = task?.reminderDateTime ?? _selectedDueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    ReminderService.triggerClickHaptic();
    final now = DateTime.now();
    final initialDate = _selectedDueDate ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (pickedDate != null && mounted) {
      final initialTime = _selectedDueDate != null
          ? TimeOfDay(hour: _selectedDueDate!.hour, minute: _selectedDueDate!.minute)
          : const TimeOfDay(hour: 12, minute: 0);

      final pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      final time = pickedTime ?? const TimeOfDay(hour: 23, minute: 59);
      setState(() {
        _selectedDueDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          time.hour,
          time.minute,
        );

        if (_hasReminder && _reminderDateTime == null) {
          _reminderDateTime = _selectedDueDate;
        }
      });
    }
  }

  Future<void> _pickCustomReminderTime() async {
    ReminderService.triggerClickHaptic();
    final now = DateTime.now();
    final initial = _reminderDateTime ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
      );

      if (pickedTime != null) {
        setState(() {
          _reminderDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ReminderService.triggerLightHaptic();
      final updatedTask = Task(
        id: widget.task?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        hasReminder: _hasReminder,
        reminderDateTime: _hasReminder ? _reminderDateTime : null,
        isCompleted: widget.task?.isCompleted ?? false,
        completedAt: widget.task?.completedAt,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        isReminderTriggered: false,
      );

      widget.onSave(updatedTask);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.task != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                // Handle indicator
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

                // Dialog Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Task' : 'Add New Task',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title Input
                TextFormField(
                  controller: _titleController,
                  autofocus: !isEditing,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Task Title *',
                    hintText: 'What needs to be done?',
                    prefixIcon: const Icon(Icons.title_rounded),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Description Input
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Description / Notes (Optional)',
                    hintText: 'Add details, links, or sub-notes...',
                    prefixIcon: const Icon(Icons.notes_rounded),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Priority Selection
                const Text(
                  'Priority Level',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: TaskPriority.values.map((priority) {
                    final isSelected = _selectedPriority == priority;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () {
                            ReminderService.triggerClickHaptic();
                            setState(() {
                              _selectedPriority = priority;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? priority.color.withValues(alpha: 0.15)
                                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? priority.color
                                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.flag_rounded,
                                  size: 18,
                                  color: isSelected
                                      ? priority.color
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  priority.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? priority.color
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // Category Selection
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.categories.map((cat) {
                    final isSelected = _selectedCategory == cat.name;
                    return ChoiceChip(
                      avatar: Icon(
                        cat.icon,
                        size: 16,
                        color: isSelected ? Colors.white : cat.color,
                      ),
                      label: Text(cat.name),
                      selected: isSelected,
                      selectedColor: cat.color,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          ReminderService.triggerClickHaptic();
                          setState(() {
                            _selectedCategory = cat.name;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // Due Date & Time
                const Text(
                  'Due Date & Time',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today_rounded, size: 18),
                        label: Text(
                          _selectedDueDate == null
                              ? 'Set Due Date'
                              : DateFormat('MMM d, yyyy • h:mm a').format(_selectedDueDate!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _pickDueDate,
                      ),
                    ),
                    if (_selectedDueDate != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Clear due date',
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          setState(() {
                            _selectedDueDate = null;
                            _hasReminder = false;
                            _reminderDateTime = null;
                          });
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 18),

                // Reminder & Haptic Section
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _hasReminder
                        ? const Color(0xFF6366F1).withValues(alpha: 0.08)
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _hasReminder
                          ? const Color(0xFF6366F1).withValues(alpha: 0.4)
                          : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.notifications_active_rounded,
                                color: Color(0xFF6366F1),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reminder with Haptic',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Vibrates device when reminder triggers',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Switch(
                            value: _hasReminder,
                            activeTrackColor: const Color(0xFF6366F1),
                            onChanged: (val) {
                              ReminderService.triggerClickHaptic();
                              setState(() {
                                _hasReminder = val;
                                if (_hasReminder && _reminderDateTime == null) {
                                  _reminderDateTime = _selectedDueDate ??
                                      DateTime.now().add(const Duration(hours: 1));
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      if (_hasReminder) ...[
                        const Divider(height: 20),
                        const Text(
                          'Notify me at:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            ActionChip(
                              label: const Text('At Due Time'),
                              onPressed: _selectedDueDate == null
                                  ? null
                                  : () {
                                      ReminderService.triggerClickHaptic();
                                      setState(() {
                                        _reminderDateTime = _selectedDueDate;
                                      });
                                    },
                            ),
                            ActionChip(
                              label: const Text('10m Before'),
                              onPressed: _selectedDueDate == null
                                  ? null
                                  : () {
                                      ReminderService.triggerClickHaptic();
                                      setState(() {
                                        _reminderDateTime = _selectedDueDate!
                                            .subtract(const Duration(minutes: 10));
                                      });
                                    },
                            ),
                            ActionChip(
                              label: const Text('⚡ In 5 sec (Test Haptic)'),
                              backgroundColor: Colors.indigo.withValues(alpha: 0.15),
                              onPressed: () {
                                ReminderService.triggerLightHaptic();
                                setState(() {
                                  _reminderDateTime =
                                      DateTime.now().add(const Duration(seconds: 5));
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Reminder set for 5 seconds from now! Listen/feel for haptic vibration.'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.edit_calendar_rounded, size: 14),
                              label: const Text('Custom Time'),
                              onPressed: _pickCustomReminderTime,
                            ),
                          ],
                        ),
                        if (_reminderDateTime != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Scheduled: ${DateFormat('EEE, MMM d, yyyy • h:mm a').format(_reminderDateTime!)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Save button
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(
                    isEditing ? 'Save Changes' : 'Create Task',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
