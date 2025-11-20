/// Goal Detail Screen - Shows detailed information about a goal
///
/// Features:
/// - Goal title and description
/// - Progress tracking
/// - Time tracking
/// - Session history
library;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../widgets/delete_confirmation_bottom_sheet.dart';
import 'edit_goal_screen.dart';

class GoalDetailScreen extends StatelessWidget {
  final String title;
  final String progress;
  final String duration;
  final String totalTime;
  final String timeSpent;
  final bool isCompleted;

  const GoalDetailScreen({
    super.key,
    required this.title,
    required this.progress,
    required this.duration,
    required this.totalTime,
    required this.timeSpent,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFAFAFA);
    final textColor = isDark ? Colors.white : const Color(0xFF141414);
    final subtextColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF999999);

    // Card color based on completion status
    final cardColor = isDark
        ? const Color(0xFF2C2C2E)
        : (isCompleted
            ? const Color(0xFF4CAF50).withOpacity(0.05) // Very subtle green for completed
            : const Color(0xFF613EEA).withOpacity(0.04)); // Very subtle purple for incomplete

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Goal Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        actions: [
          if (!isCompleted)
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: textColor,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditGoalScreen(
                      title: title,
                      duration: duration,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal Info Card with subtle background color
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon with gradient
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isCompleted
                              ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                              : [const Color(0xFF613EEA), const Color(0xFF7C5FEE)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (isCompleted ? const Color(0xFF4CAF50) : const Color(0xFF613EEA))
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        isCompleted ? Icons.check_circle : Icons.flag_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Progress info
                    Row(
                      children: [
                        Icon(
                          Icons.radio_button_checked,
                          size: 16,
                          color: subtextColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$progress · $totalTime',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Duration',
                      value: duration,
                      backgroundColor: const Color(0xFF2D4FC6),
                      accentColor: const Color(0xFFFED132),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Time Spent',
                      value: timeSpent,
                      backgroundColor: const Color(0xFF273257),
                      accentColor: const Color(0xFFFF6641),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Description Section
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Text(
                  'This is a placeholder description for the goal. You can add detailed information about what needs to be accomplished.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: subtextColor,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              if (!isCompleted)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Start Focus Button (Left)
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF613EEA),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF613EEA).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () {
                          // Pop and return 'focus' to indicate user wants to start a focus session
                          Navigator.of(context).pop('focus');
                        },
                        icon: const Icon(
                          HugeIcons.strokeRoundedTarget02,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                    // Delete Button (Right)
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5252),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF5252).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () async {
                          final confirmed = await DeleteConfirmationBottomSheet.show(
                            context: context,
                            title: 'Delete Goal',
                            message: 'Are you sure you want to delete this goal?',
                            subtitle: 'The goal will be removed from your list.\nThis action can\'t be undone.',
                          );
                          if (confirmed == true) {
                            // TODO: Delete goal
                            Navigator.of(context).pop();
                          }
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                )
              else
                // Delete Button Only (Centered for completed goals)
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5252).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () async {
                        final confirmed = await DeleteConfirmationBottomSheet.show(
                          context: context,
                          title: 'Delete Goal',
                          message: 'Are you sure you want to delete this goal?',
                          subtitle: 'The goal will be removed from your list.\nThis action can\'t be undone.',
                        );
                        if (confirmed == true) {
                          // TODO: Delete goal
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color backgroundColor,
    required Color accentColor,
    required bool isDark,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 102,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Decorative accent element (bottom-right corner)
            Positioned(
              right: 0,
              bottom: -31,
              child: Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(98.4),
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Value
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
