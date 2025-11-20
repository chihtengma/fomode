/// Goals List Screen - Shows all active and completed goals
///
/// Features:
/// - Tab bar to switch between Active and Completed
/// - Reuses goal card design from calendar
/// - Shows completed goals with strikethrough and grayed out
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'goal_detail_screen.dart';
import 'add_goal_screen.dart';
import '../widgets/delete_confirmation_bottom_sheet.dart';
import '../widgets/bottom_nav_bar.dart';

class GoalsListScreen extends StatefulWidget {
  final int initialTab; // 0 for Active, 1 for Completed
  final Function(NavItem)? onNavigate;

  const GoalsListScreen({
    super.key,
    this.initialTab = 0,
    this.onNavigate,
  });

  @override
  State<GoalsListScreen> createState() => _GoalsListScreenState();
}

class _GoalsListScreenState extends State<GoalsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data - Active goals
  final List<Map<String, dynamic>> _activeGoals = [
    {
      'title': 'Market Research & Analysis',
      'progress': '7/7',
      'duration': '175 mins',
      'totalTime': '175/175 mins',
      'timeSpent': '2h 55m',
      'isCompleted': false,
      'date': DateTime.now(), // Today
    },
    {
      'title': 'Complete project proposal',
      'progress': '3/5',
      'duration': '90 mins',
      'totalTime': '60/90 mins',
      'timeSpent': '1h 0m',
      'isCompleted': false,
      'date': DateTime.now().add(const Duration(days: 1)), // Tomorrow
    },
    {
      'title': 'Team meeting preparation',
      'progress': '0/3',
      'duration': '45 mins',
      'totalTime': '0/45 mins',
      'timeSpent': '0m',
      'isCompleted': false,
      'date': DateTime.now().subtract(const Duration(days: 1)), // Overdue
    },
    {
      'title': 'Code review for feature branch',
      'progress': '2/4',
      'duration': '60 mins',
      'totalTime': '30/60 mins',
      'timeSpent': '30m',
      'isCompleted': false,
      'date': DateTime.now().add(const Duration(days: 3)), // Future
    },
    {
      'title': 'Update documentation',
      'progress': '1/2',
      'duration': '30 mins',
      'totalTime': '15/30 mins',
      'timeSpent': '15m',
      'isCompleted': false,
      'date': DateTime.now(), // Today
    },
  ];

  // Mock data - Completed goals
  final List<Map<String, dynamic>> _completedGoals = [
    {
      'title': 'Design system wireframes',
      'progress': '5/5',
      'duration': '120 mins',
      'totalTime': '120/120 mins',
      'timeSpent': '2h 0m',
      'isCompleted': true,
      'date': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'title': 'Client presentation slides',
      'progress': '8/8',
      'duration': '90 mins',
      'totalTime': '90/90 mins',
      'timeSpent': '1h 30m',
      'isCompleted': true,
      'date': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'title': 'Bug fixes for v2.1',
      'progress': '12/12',
      'duration': '180 mins',
      'totalTime': '180/180 mins',
      'timeSpent': '3h 0m',
      'isCompleted': true,
      'date': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'title': 'Database optimization',
      'progress': '4/4',
      'duration': '150 mins',
      'totalTime': '150/150 mins',
      'timeSpent': '2h 30m',
      'isCompleted': true,
      'date': DateTime.now().subtract(const Duration(days: 7)),
    },
  ];

  String _formatGoalDate(DateTime date, bool isCompleted) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final goalDate = DateTime(date.year, date.month, date.day);
    final difference = goalDate.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return isCompleted ? 'Yesterday' : 'Overdue';
    } else if (difference < -1 && !isCompleted) {
      return 'Overdue';
    } else {
      return DateFormat('EEEE, MMM d').format(date);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab changes
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFAFAFA);
    final textColor = isDark ? Colors.white : const Color(0xFF141414);

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
          'All Goals',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF613EEA),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: isDark ? const Color(0xFF8E8E93) : const Color(0xFF666666),
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGoalsList(_activeGoals, isDark),
          _buildGoalsList(_completedGoals, isDark),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF613EEA),
                    Color(0xFF7C5FEE),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF613EEA).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddGoalScreen(
                        selectedDate: DateTime.now(),
                      ),
                    ),
                  );
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildGoalsList(List<Map<String, dynamic>> goals, bool isDark) {
    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
            ),
            const SizedBox(height: 16),
            Text(
              'No goals yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF999999),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: goals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final goal = goals[index];
        return _buildGoalCard(
          title: goal['title'],
          progress: goal['progress'],
          duration: goal['duration'],
          totalTime: goal['totalTime'],
          timeSpent: goal['timeSpent'],
          isCompleted: goal['isCompleted'],
          date: goal['date'],
          isDark: isDark,
        );
      },
    );
  }

  Widget _buildGoalCard({
    required String title,
    required String progress,
    required String duration,
    required String totalTime,
    required String timeSpent,
    required bool isCompleted,
    required DateTime date,
    required bool isDark,
  }) {
    final cardColor = isDark
        ? const Color(0xFF2C2C2E)
        : (isCompleted
            ? const Color(0xFF4CAF50).withOpacity(0.05) // Very subtle green for completed
            : const Color(0xFF613EEA).withOpacity(0.04)); // Very subtle purple for active
    final textColor = isDark ? Colors.white : const Color(0xFF141414);
    final subtextColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF999999);
    final completedTextColor = isDark ? const Color(0xFF5E5E60) : const Color(0xFFAAAAAA);

    // Format date and check if overdue
    final formattedDate = _formatGoalDate(date, isCompleted);
    final isOverdue = formattedDate == 'Overdue';
    final dateColor = isOverdue
        ? const Color(0xFFFF5252)
        : (isCompleted ? completedTextColor : subtextColor);

    return Dismissible(
      key: Key(title),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await DeleteConfirmationBottomSheet.show(
          context: context,
          title: 'Delete Goal',
          message: 'Are you sure you want to delete this goal?',
          subtitle: 'The goal will be removed from your list.\nThis action can\'t be undone.',
        ) ?? false;
      },
      background: Container(
        margin: const EdgeInsets.only(left: 80),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFFF5252),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.only(right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 28,
              ),
            ],
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GoalDetailScreen(
                title: title,
                progress: progress,
                duration: duration,
                totalTime: totalTime,
                timeSpent: timeSpent,
                isCompleted: isCompleted,
              ),
            ),
          );

          // If user tapped focus button, switch to focus tab
          if (result == 'focus' && widget.onNavigate != null) {
            widget.onNavigate!(NavItem.focus);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
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
          child: Row(
            children: [
              // Icon/Avatar with gradient
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isCompleted
                        ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                        : [const Color(0xFF613EEA), const Color(0xFF7C5FEE)],
                  ),
                  borderRadius: BorderRadius.circular(12),
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
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with strikethrough if completed
                    Stack(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? completedTextColor : textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isCompleted)
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 10,
                            child: Container(
                              height: 1.5,
                              color: completedTextColor,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: dateColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w500,
                            color: dateColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Progress and time info
                    Row(
                      children: [
                        Icon(
                          Icons.radio_button_checked,
                          size: 14,
                          color: isCompleted ? completedTextColor : subtextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$progress · $totalTime',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: isCompleted ? completedTextColor : subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Duration and time spent
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    duration,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? completedTextColor : textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '($timeSpent)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: isCompleted ? completedTextColor : subtextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
