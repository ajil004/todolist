import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class StatsOverviewCard extends StatelessWidget {
  final List<Task> tasks;
  final VoidCallback? onTestHaptic;

  const StatsOverviewCard({
    super.key,
    required this.tasks,
    this.onTestHaptic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final pending = total - completed;
    final overdue = tasks.where((t) => t.isOverdue).length;
    final progress = total > 0 ? (completed / total) : 0.0;
    final percent = (progress * 100).round();

    final dateStr = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.85),
            const Color(0xFF4F46E5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Task Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (onTestHaptic != null)
                Tooltip(
                  message: 'Test Reminder & Haptic Vibrate',
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: onTestHaptic,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.vibration_rounded,
                                color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Test Haptic',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Metric counts row
          Row(
            children: [
              _buildCountItem(
                context,
                title: 'Pending',
                count: pending,
                icon: Icons.pending_actions_rounded,
                bgColor: Colors.amber.withValues(alpha: 0.25),
                textColor: Colors.amber.shade200,
              ),
              const SizedBox(width: 10),
              _buildCountItem(
                context,
                title: 'Completed',
                count: completed,
                icon: Icons.task_alt_rounded,
                bgColor: Colors.greenAccent.withValues(alpha: 0.25),
                textColor: Colors.greenAccent.shade100,
              ),
              const SizedBox(width: 10),
              _buildCountItem(
                context,
                title: 'Overdue',
                count: overdue,
                icon: Icons.warning_amber_rounded,
                bgColor: overdue > 0
                    ? Colors.redAccent.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.15),
                textColor: overdue > 0 ? Colors.redAccent.shade100 : Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountItem(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 15, color: textColor),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
