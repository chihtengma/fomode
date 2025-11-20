/// Calendar Screen - Monthly calendar view with goals
///
/// Features:
/// - Full month calendar view
/// - Task categories with color coding
/// - Goals list for selected day
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'goal_detail_screen.dart';
import 'add_goal_screen.dart';
import '../widgets/delete_confirmation_bottom_sheet.dart';
import '../widgets/bottom_nav_bar.dart';

class CalendarScreen extends StatefulWidget {
  final Function(NavItem)? onNavigate;

  const CalendarScreen({super.key, this.onNavigate});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  List<DateTime?> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    // Get the weekday of the first day (1 = Monday, 7 = Sunday)
    final firstWeekday = firstDay.weekday;

    List<DateTime?> days = [];

    // Add empty cells for days before the first day of the month
    // If firstWeekday is 1 (Monday), add 0 empty cells
    // If firstWeekday is 7 (Sunday), add 6 empty cells
    for (int i = 1; i < firstWeekday; i++) {
      days.add(null);
    }

    // Add all days of the month
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    return days;
  }

  String _getGoalsSectionTitle() {
    final today = DateTime.now();
    final isToday = _selectedDate.day == today.day &&
        _selectedDate.month == today.month &&
        _selectedDate.year == today.year;

    if (isToday) {
      return "Today's Goals";
    } else {
      // Format: "Monday, Nov 17's Goals"
      return DateFormat('EEEE, MMM d').format(_selectedDate) + "'s Goals";
    }
  }

  // Mock data - replace with actual API data
  List<Map<String, dynamic>> _getGoalsForSelectedDate() {
    final today = DateTime.now();
    final isToday = _selectedDate.day == today.day &&
        _selectedDate.month == today.month &&
        _selectedDate.year == today.year;

    // Only show goals for today (mock data)
    if (isToday) {
      return [
        {
          'title': 'Market Research & Analysis',
          'progress': '7/7',
          'duration': '175 mins',
          'totalTime': '175/175 mins',
          'timeSpent': '2h 55m',
          'isCompleted': true,
        },
        {
          'title': 'Complete project proposal',
          'progress': '3/5',
          'duration': '90 mins',
          'totalTime': '60/90 mins',
          'timeSpent': '1h 0m',
          'isCompleted': false,
        },
        {
          'title': 'Team meeting preparation',
          'progress': '0/3',
          'duration': '45 mins',
          'totalTime': '0/45 mins',
          'timeSpent': '0m',
          'isCompleted': false,
        },
      ];
    }

    // Empty for other days
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFAFAFA);
    final textColor = isDark ? Colors.white : const Color(0xFF141414);

    final monthDays = _getDaysInMonth(_currentMonth);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Title - Current Month
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat('MMMM yyyy').format(_currentMonth),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Calendar Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
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
                  children: [
                    // Day names header (Mon, Tue, Wed, etc.)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDayHeader('Mon'),
                        _buildDayHeader('Tue'),
                        _buildDayHeader('Wed'),
                        _buildDayHeader('Thu'),
                        _buildDayHeader('Fri'),
                        _buildDayHeader('Sat'),
                        _buildDayHeader('Sun'),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Month Calendar
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        childAspectRatio: 1,
                      ),
                      itemCount: monthDays.length,
                      itemBuilder: (context, index) {
                        final day = monthDays[index];

                        // If day is null (empty cell), return empty container
                        if (day == null) {
                          return Container();
                        }

                        final isSelected = day.day == _selectedDate.day &&
                            day.month == _selectedDate.month &&
                            day.year == _selectedDate.year;
                        final isToday = day.day == DateTime.now().day &&
                            day.month == DateTime.now().month &&
                            day.year == DateTime.now().year;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = day;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF613EEA) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${day.day.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white : const Color(0xFF141414)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Progress Summary Cards - Horizontal Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Progress Card
                  Expanded(
                    child: _buildStatCard(
                      title: 'Progress',
                      value: '38%',
                      backgroundColor: const Color(0xFF613EEA),
                      accentColor: const Color(0xFFFED132),
                      isRotated: false,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Worked Minutes Card
                  Expanded(
                    child: _buildStatCard(
                      title: 'Worked',
                      value: '125m',
                      backgroundColor: const Color(0xFF2D4FC6),
                      accentColor: const Color(0xFFFF6641),
                      isRotated: true,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Goals Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getGoalsSectionTitle(),
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddGoalScreen(
                                  selectedDate: _selectedDate,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF613EEA),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _buildGoalsList(isDark),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildDayHeader(String day) {
    return Expanded(
      child: Center(
        child: Text(
          day,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
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
    required bool isRotated,
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
                  borderRadius: isRotated
                      ? const BorderRadius.only(bottomLeft: Radius.circular(98.4))
                      : const BorderRadius.only(topLeft: Radius.circular(98.4)),
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

  Widget _buildGoalsList(bool isDark) {
    final goals = _getGoalsForSelectedDate();

    if (goals.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return ListView.separated(
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
          isDark: isDark,
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF141414);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Clipboard Icon (smaller)
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: isDark ? const Color(0xFF8E8E93) : const Color(0xFFCCCCCC),
          ),
          const SizedBox(height: 16),
          Text(
            'No Goals Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to add goals',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF999999),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard({
    required String title,
    required String progress,
    required String duration,
    required String totalTime,
    required String timeSpent,
    required bool isCompleted,
    required bool isDark,
  }) {
    // Subtle background colors based on completion status
    final cardColor = isDark
        ? const Color(0xFF2C2C2E)
        : (isCompleted
            ? const Color(0xFF4CAF50).withOpacity(0.05) // Very subtle green for completed
            : const Color(0xFF613EEA).withOpacity(0.04)); // Very subtle purple for incomplete
    final textColor = isDark ? Colors.white : const Color(0xFF141414);
    final subtextColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF999999);

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
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Progress and time info
                    Row(
                      children: [
                        Icon(
                          Icons.radio_button_checked,
                          size: 14,
                          color: subtextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$progress · $totalTime',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: subtextColor,
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
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '($timeSpent)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: subtextColor,
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
