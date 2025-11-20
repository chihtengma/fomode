/// Stats Screen - Display usage statistics
///
/// Features:
/// - Active and completed goals summary
/// - Beautiful bar chart using fl_chart
/// - Weekly/Monthly toggle
library;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'goals_list_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class StatsScreen extends StatefulWidget {
  final Function(NavItem)? onNavigate;

  const StatsScreen({super.key, this.onNavigate});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _selectedPeriod = 'Weekly';
  int _touchedIndex = -1;

  // Weekly data (7 days)
  final List<ChartData> _weeklyData = [
    ChartData(label: '14', hours: 7.2),
    ChartData(label: '15', hours: 5.8),
    ChartData(label: '16', hours: 7.5),
    ChartData(label: '17', hours: 6.8),
    ChartData(label: '18', hours: 6.2),
    ChartData(label: '19', hours: 7.3),
    ChartData(label: '20', hours: 5.1),
  ];

  // Monthly data (4 weeks)
  final List<ChartData> _monthlyData = [
    ChartData(label: 'Week 1', hours: 42.5),
    ChartData(label: 'Week 2', hours: 38.2),
    ChartData(label: 'Week 3', hours: 45.8),
    ChartData(label: 'Week 4', hours: 41.0),
  ];

  List<ChartData> get _currentData {
    return _selectedPeriod == 'Weekly' ? _weeklyData : _monthlyData;
  }

  String get _totalFocusTime {
    return _selectedPeriod == 'Weekly' ? '46.2h' : '167.5h';
  }

  String get _avgFocusTime {
    return _selectedPeriod == 'Weekly' ? '6.6h' : '41.9h';
  }

  String get _totalSessions {
    return _selectedPeriod == 'Weekly' ? '109' : '428';
  }

  int get _currentHighlightIndex {
    return _selectedPeriod == 'Weekly' ? 1 : 3; // Day 15 or Week 4
  }

  double get _maxYValue {
    return _selectedPeriod == 'Weekly' ? 8.0 : 50.0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFAFAFA);
    final textColor = isDark ? Colors.white : const Color(0xFF141414);
    final subtextColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF999999);
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Title
                Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 24),

                // Goals Summary Card
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GoalsListScreen(
                          onNavigate: widget.onNavigate,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF613EEA),
                          Color(0xFF7C5FEE),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF613EEA).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '8',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Active Goals',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1.5,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '156',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Focus Time Header with Period Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Focus Time',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPeriod = _selectedPeriod == 'Weekly' ? 'Monthly' : 'Weekly';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF613EEA).withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: const Color(0xFF613EEA),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _selectedPeriod,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Stats Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        _totalFocusTime,
                        'Total Time',
                        Icons.access_time_rounded,
                        const Color(0xFF4CAF50),
                        isDark,
                        isRotated: false, // Bottom-right accent
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        _avgFocusTime,
                        'Average',
                        Icons.trending_up_rounded,
                        const Color(0xFF2196F3),
                        isDark,
                        isRotated: true, // Bottom-left accent
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        _totalSessions,
                        'Sessions',
                        Icons.play_circle_outline_rounded,
                        const Color(0xFFFF9800),
                        isDark,
                        isRotated: false, // Bottom-right accent
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Bar Chart
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 280,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: _maxYValue,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (group) => const Color(0xFF613EEA),
                                tooltipRoundedRadius: 12,
                                tooltipPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                    '${rod.toY.toStringAsFixed(1)}h',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  );
                                },
                              ),
                              touchCallback: (FlTouchEvent event, barTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      barTouchResponse == null ||
                                      barTouchResponse.spot == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                                });
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 || index >= _currentData.length) {
                                      return const SizedBox.shrink();
                                    }
                                    final isHighlighted = index == _currentHighlightIndex;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        _currentData[index].label,
                                        style: TextStyle(
                                          fontSize: _selectedPeriod == 'Weekly' ? 13 : 11,
                                          fontWeight: FontWeight.w600,
                                          color: isHighlighted
                                              ? const Color(0xFF613EEA)
                                              : subtextColor,
                                        ),
                                      ),
                                    );
                                  },
                                  reservedSize: 30,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: _selectedPeriod == 'Weekly' ? 2 : 10,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '${value.toInt()}h',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: subtextColor,
                                      ),
                                    );
                                  },
                                  reservedSize: 35,
                                ),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: _selectedPeriod == 'Weekly' ? 2 : 10,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.05),
                                  strokeWidth: 1,
                                  dashArray: [5, 5],
                                );
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: _getBarGroups(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
    bool isDark, {
    required bool isRotated,
  }) {
    // Define background and accent colors for each stat
    Color backgroundColor;
    Color accentColor;

    if (color == const Color(0xFF4CAF50)) {
      // Green - Total Time
      backgroundColor = const Color(0xFF4CAF50);
      accentColor = const Color(0xFFFED132);
    } else if (color == const Color(0xFF2196F3)) {
      // Blue - Average
      backgroundColor = const Color(0xFF2D4FC6);
      accentColor = const Color(0xFF66BB6A);
    } else {
      // Orange - Sessions
      backgroundColor = const Color(0xFF273257);
      accentColor = const Color(0xFFFF6641);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Decorative accent element (bottom corner)
            Positioned(
              right: isRotated ? null : 0,
              left: isRotated ? 0 : null,
              bottom: -31,
              child: Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: isRotated
                      ? const BorderRadius.only(
                          topRight: Radius.circular(98.4),
                        )
                      : const BorderRadius.only(
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
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),

                  // Value and label
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    return List.generate(_currentData.length, (index) {
      final isHighlighted = index == _currentHighlightIndex;
      final isTouched = index == _touchedIndex;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: _currentData[index].hours,
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: isHighlighted
                  ? [
                      const Color(0xFF613EEA),
                      const Color(0xFF7C5FEE),
                    ]
                  : [
                      const Color(0xFF613EEA).withOpacity(0.3),
                      const Color(0xFF7C5FEE).withOpacity(0.4),
                    ],
            ),
            width: isTouched ? 28 : 24,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
              bottom: Radius.circular(4),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _maxYValue,
              color: Colors.grey.withOpacity(0.05),
            ),
          ),
        ],
      );
    });
  }
}

class ChartData {
  final String label;
  final double hours;

  ChartData({required this.label, required this.hours});
}
