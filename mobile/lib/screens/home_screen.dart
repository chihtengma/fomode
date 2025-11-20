/// Home Screen - Main Screen with modern dashboard design
///
/// Features:
/// - Greeting section with date and user name
/// - Quick action button (Start Studying/Focus)
/// - Stats cards (Today's & Weekly study time)
/// - Goals list section
/// - Pull-to-refresh
/// - Empty state handling
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/goal.dart';
import '../providers/goal_provider.dart';
import '../services/auth_service.dart';
import '../widgets/goal_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/add_edit_goal_dialog.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/profile_avatar.dart';
import 'article_detail_screen.dart';

enum AccentPosition { topLeft, bottomRight }

class HomeScreen extends StatefulWidget {
  final Function(NavItem)? onNavigate;

  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Focus';
  String? _profileImageUrl;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    // Load goals when screen initializes
    // Use addPostFrameCallback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalProvider>().fetchGoals();
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    try {
      final AuthService authService = AuthService();
      final userData = await authService.getCurrentUser();
      
      if (userData != null && mounted) {
        setState(() {
          // Extract first name from full_name or use email prefix
          final fullName = userData['full_name'] as String?;
          if (fullName != null && fullName.isNotEmpty) {
            _userName = fullName.split(' ')[0]; // Get first name
          } else {
            final email = userData['email'] as String?;
            if (email != null) {
              _userName = email.split('@')[0];
              if (_userName.isNotEmpty) {
                _userName = _userName[0].toUpperCase() + _userName.substring(1);
              }
            }
          }
          
          // Get profile image URL
          _profileImageUrl = userData['profile_image_url'] as String?;
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userName = 'Focus';
          _profileImageUrl = null;
          _isLoadingUser = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFAFAFA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<GoalProvider>().fetchGoals(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Header: Greeting + Profile Picture
                  _buildGreetingSection(context),

                  const SizedBox(height: 24),

                  // "Start Studying" CTA Button
                  _buildStartStudyingButton(context),

                  const SizedBox(height: 24),

                  // Stats Cards (Today's & Weekly Study Time)
                  _buildStatsCards(context),

                  const SizedBox(height: 24),

                  // Goals Section Header
                  _buildGoalsSectionHeader(context),

                  const SizedBox(height: 24),

                  // Goals List
                  _buildGoalsList(context),

                  const SizedBox(height: 24),

                  // Focus Tips Section
                  _buildFocusTipsSection(context),

                  const SizedBox(height: 100), // Bottom padding for bottom nav
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build greeting section with date and user name
  Widget _buildGreetingSection(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('MMMM d');
    final formattedDate = dateFormat.format(now);

    // Get ordinal suffix (st, nd, rd, th)
    String getOrdinalSuffix(int day) {
      if (day >= 11 && day <= 13) return 'th';
      switch (day % 10) {
        case 1:
          return 'st';
        case 2:
          return 'nd';
        case 3:
          return 'rd';
        default:
          return 'th';
      }
    }

    final dateWithOrdinal = '$formattedDate${getOrdinalSuffix(now.day)}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Date + Greeting
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateWithOrdinal,
              style: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(20, 20, 20, 0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isLoadingUser ? 'Hello!' : 'Hello $_userName!',
              style: const TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF141414),
                height: 1.33,
              ),
            ),
          ],
        ),

        // Profile Picture
        ProfileAvatar(
          imageUrl: _profileImageUrl,
          name: _userName,
          size: 48,
        ),
      ],
    );
  }

  /// Build "Start Focusing" CTA button
  Widget _buildStartStudyingButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF613EEA), Color(0xFF7C5FEE), Color(0xFF8A6FF0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF613EEA).withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Navigate to Focus screen
          widget.onNavigate?.call(NavItem.focus);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 28, color: Colors.white),
            const SizedBox(width: 16),
            const Text(
              'Start Focusing',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.arrow_forward_rounded, size: 28, color: Colors.white),
          ],
        ),
      ),
    );
  }

  /// Build stats cards section
  Widget _buildStatsCards(BuildContext context) {
    return Row(
      children: [
        // Today's Focus Time Card
        Expanded(
          child: _buildStatCard(
            title: "Today's Study Time",
            value: '0h',
            backgroundColor: const Color(0xFF2D4FC6),
            accentColor: const Color(0xFFFED132),
            isRotated: false,
          ),
        ),
        const SizedBox(width: 16),

        // Weekly Focus Time Card
        Expanded(
          child: _buildStatCard(
            title: 'Weekly Study Time',
            value: '0h',
            backgroundColor: const Color(0xFF273257),
            accentColor: const Color(0xFFFF6641),
            isRotated: true,
          ),
        ),
      ],
    );
  }

  /// Build individual stat card
  Widget _buildStatCard({
    required String title,
    required String value,
    required Color backgroundColor,
    required Color accentColor,
    required bool isRotated,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 102,
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(16)),
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

  /// Build goals section header
  Widget _buildGoalsSectionHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF141414);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Today\'s Goals',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textColor,
            height: 1.375,
          ),
        ),
        // See All link
        GestureDetector(
          onTap: () {
            // Navigate to Goals (Calendar) tab to see Active/Completed view
            widget.onNavigate?.call(NavItem.goals);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'See All',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF666666),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF666666),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build Focus Tips section
  Widget _buildFocusTipsSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF141414);

    // Curated articles about focus and productivity
    final articles = [
      {
        'title': 'Deep Work',
        'description': 'Focus without distraction',
        'readTime': '8 min',
        'backgroundColor': const Color(0xFF613EEA),
        'accentColor': const Color(0xFFFED132),
      },
      {
        'title': 'Flow State',
        'description': 'Boost productivity 500%',
        'readTime': '6 min',
        'backgroundColor': const Color(0xFF2D4FC6),
        'accentColor': const Color(0xFFFF6641),
      },
      {
        'title': 'Pomodoro',
        'description': '25-min focus sessions',
        'readTime': '5 min',
        'backgroundColor': const Color(0xFF7C5FEE),
        'accentColor': const Color(0xFF4CAF50),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          'Focus Tips',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textColor,
            height: 1.375,
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal scrollable articles
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: articles.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final article = articles[index];
              return _buildFocusTipCard(
                context: context,
                title: article['title'] as String,
                description: article['description'] as String,
                readTime: article['readTime'] as String,
                backgroundColor: article['backgroundColor'] as Color,
                accentColor: article['accentColor'] as Color,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build individual focus tip card (stat card style)
  Widget _buildFocusTipCard({
    required BuildContext context,
    required String title,
    required String description,
    required String readTime,
    required Color backgroundColor,
    required Color accentColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 200,
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(16)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Navigate to article detail screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailScreen(
                    title: title,
                    category: title, // Using title as category for now
                    readTime: readTime,
                    accentColor: accentColor,
                  ),
                ),
              );
            },
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
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(98.4)),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Read time badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          readTime,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // Title and description
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build goals list - stacked card style
  Widget _buildGoalsList(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, child) {
        // Show loading indicator
        if (goalProvider.isLoading && goalProvider.goals.isEmpty) {
          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        }

        // Show error view if loading failed
        if (goalProvider.error != null && goalProvider.goals.isEmpty) {
          return SizedBox(
            height: 200,
            child: ErrorView(
              message: goalProvider.error!,
              onRetry: () => goalProvider.fetchGoals(),
            ),
          );
        }

        // Show empty state if no goals
        if (goalProvider.goals.isEmpty) {
          return const SizedBox(
            height: 200,
            child: EmptyState(
              icon: Icons.check_circle_outline,
              title: 'No goals yet',
              message: 'Tap the + button to add your first goal',
            ),
          );
        }

        // Show stacked cards
        return _buildStackedGoalCards(context, goalProvider.goals);
      },
    );
  }

  /// Build stacked goal cards with wallet-style design
  Widget _buildStackedGoalCards(BuildContext context, List<Goal> goals) {
    return _ExpandableStackedCards(goals: goals, onNavigate: widget.onNavigate);
  }

  /// Build the front goal card
  Widget _buildFrontGoalCard({
    required BuildContext context,
    required Goal goal,
    required int totalGoals,
    required int completedGoals,
    required bool isDark,
  }) {
    final textColor = Colors.white;
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
    );

    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$completedGoals/$totalGoals',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                    // Icon or badge
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.flag_rounded, color: Color(0xFF2E7D32), size: 28),
                    ),
                  ],
                ),

                const Spacer(),

                // Goal title
                Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                if (goal.description != null && goal.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    goal.description!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor.withOpacity(0.7),
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build horizontal goal card
  Widget _buildHorizontalGoalCard({
    required BuildContext context,
    required Goal goal,
    required VoidCallback onToggleComplete,
    required VoidCallback onDelete,
    required VoidCallback onEdit,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF141414);
    final subtextColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF666666);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
          width: 1.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggleComplete,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with checkbox and menu
                Row(
                  children: [
                    // Checkbox
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: goal.completed
                              ? const Color(0xFF613EEA)
                              : (isDark ? const Color(0xFF5E5E60) : const Color(0xFFDDDDDD)),
                          width: 2,
                        ),
                        color: goal.completed ? const Color(0xFF613EEA) : Colors.transparent,
                      ),
                      child: goal.completed
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),

                    const Spacer(),

                    // Menu button
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, size: 20, color: subtextColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      offset: const Offset(-10, 8),
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit();
                        } else if (value == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 18),
                              SizedBox(width: 12),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Goal title and description
                Expanded(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          goal.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: goal.completed ? subtextColor : textColor,
                            decoration: goal.completed ? TextDecoration.lineThrough : null,
                            decorationThickness: 2,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (goal.description != null && goal.description!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            goal.description!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: goal.completed ? subtextColor.withOpacity(0.6) : subtextColor,
                              decoration: goal.completed ? TextDecoration.lineThrough : null,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
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

  /// Toggle goal compeltion status
  Future<void> _toggleGoalComplete(Goal goal) async {
    final provider = context.read<GoalProvider>();
    await provider.updateGoal(id: goal.id, completed: !goal.completed);
  }

  /// Delete a goal with confirmation
  Future<void> _deleteGoal(Goal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<GoalProvider>().deleteGoal(goal.id);
    }
  }

  /// Show dialog to add or edit goal
  Future<void> _showAddEditDialog({Goal? goal}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddEditGoalDialog(goal: goal),
    );

    if (result != null && mounted) {
      final provider = context.read<GoalProvider>();

      if (goal == null) {
        // Add new goal
        await provider.createGoal(
          title: result['title'] as String,
          description: result['description'] as String?,
        );
      } else {
        // Update existing goal
        await provider.updateGoal(
          id: goal.id,
          title: result['title'] as String,
          description: result['description'] as String?,
        );
      }
    }
  }
}

/// Expandable Stacked Cards Widget
class _ExpandableStackedCards extends StatefulWidget {
  final List<Goal> goals;
  final Function(NavItem)? onNavigate;

  const _ExpandableStackedCards({required this.goals, this.onNavigate});

  @override
  State<_ExpandableStackedCards> createState() => _ExpandableStackedCardsState();
}

class _ExpandableStackedCardsState extends State<_ExpandableStackedCards> {
  bool _isExpanded = false;
  double _dragOffset = 0.0;

  // Stack colors for the cards - matching app color scheme
  final List<Color> _stackColors = [
    const Color(0xFF613EEA), // Purple (primary brand color)
    const Color(0xFF2D4FC6), // Blue (stat card color)
    const Color(0xFF7C5FEE), // Light purple
    const Color(0xFF273257), // Dark blue
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sort goals: incomplete first, then completed
    // Then reverse so incomplete appears on top visually (since index 0 is bottom)
    final sortedGoals = List<Goal>.from(widget.goals);
    sortedGoals.sort((a, b) {
      // If completion status is different, incomplete comes first
      if (a.completed != b.completed) {
        return a.completed ? 1 : -1;
      }
      // If both have same completion status, maintain original order
      return 0;
    });

    // Reverse the list so index 0 (bottom visually) has completed goals
    // and last index (top visually) has incomplete goals
    final reversedGoals = sortedGoals.reversed.toList();

    final cardCount = reversedGoals.length > 4 ? 4 : reversedGoals.length;

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragOffset += details.delta.dy;
          if (_dragOffset > 50) {
            _isExpanded = true;
          } else if (_dragOffset < -50) {
            _isExpanded = false;
          }
        });
      },
      onVerticalDragEnd: (details) {
        setState(() {
          _dragOffset = 0.0;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _isExpanded ? 300 : 240,
        child: Stack(
          children: [
            // Render cards from bottom to top (reverse order so top card is last)
            for (int i = 0; i < cardCount; i++)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: _isExpanded ? (i * 40.0) : (i * 16.0),
                left: _isExpanded ? 0 : ((cardCount - 1 - i) * 8.0),
                right: _isExpanded ? 0 : ((cardCount - 1 - i) * 8.0),
                child: _buildStackCard(
                  context: context,
                  goal: reversedGoals[i],
                  color: _stackColors[i % _stackColors.length],
                  index: i,
                  isExpanded: _isExpanded,
                  isDark: isDark,
                  totalCards: cardCount,
                  totalGoals: reversedGoals.length,
                  completedGoals: reversedGoals.where((g) => g.completed).length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStackCard({
    required BuildContext context,
    required Goal goal,
    required Color color,
    required int index,
    required bool isExpanded,
    required bool isDark,
    required int totalCards,
    required int totalGoals,
    required int completedGoals,
  }) {
    final textColor = Colors.white;
    final isTopCard = index == totalCards - 1; // The visually top card is the last index

    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show different layouts based on expansion state
            if (isTopCard && !isExpanded) ...[
              // Top card when collapsed: Balanced layout with smooth spacing
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress count and icon (smaller)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$completedGoals/$totalGoals',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor.withOpacity(0.7),
                          height: 1.2,
                        ),
                      ),
                      // Icon badge (smaller)
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.flag_rounded, color: textColor, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Goal title (vertically centered)
                  Text(
                    goal.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ] else if (isExpanded && isTopCard) ...[
              // Top card when expanded: Show full details with checkbox
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Progress count and checkbox
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$completedGoals/$totalGoals',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor.withOpacity(0.7),
                          height: 1.2,
                        ),
                      ),
                      // Completion checkbox
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          color: goal.completed ? Colors.white : Colors.transparent,
                        ),
                        child: goal.completed ? Icon(Icons.check, size: 16, color: color) : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Goal title
                  Text(
                    goal.title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      height: 1.3,
                      decoration: goal.completed ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ] else if (isExpanded) ...[
              // Other cards when expanded: Show title and completion status
              Row(
                children: [
                  // Completion checkbox indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      color: goal.completed ? Colors.white : Colors.transparent,
                    ),
                    child: goal.completed ? Icon(Icons.check, size: 14, color: color) : null,
                  ),
                  const SizedBox(width: 12),
                  // Goal title
                  Expanded(
                    child: Text(
                      goal.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        height: 1.3,
                        decoration: goal.completed ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Back cards when collapsed: Show just title (centered vertically)
              const Spacer(),
              Text(
                goal.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
              ),
              const Spacer(),
            ],
          ],
        ),
      ),
    );
  }
}
