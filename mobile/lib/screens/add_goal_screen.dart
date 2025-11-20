/// Add Goal Screen - Allows users to create new goals
///
/// Features:
/// - Add goal title
/// - Add goal description
/// - Set duration
/// - Set date
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

class AddGoalScreen extends StatefulWidget {
  final DateTime selectedDate;

  const AddGoalScreen({super.key, required this.selectedDate});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  int _selectedDuration = 25; // in minutes

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _selectedDate = widget.selectedDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF613EEA),
                    onPrimary: Colors.white,
                    surface: Color(0xFF2C2C2E),
                    onSurface: Colors.white,
                    background: Color(0xFF1C1C1E),
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF613EEA),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF141414),
                    background: Color(0xFFFAFAFA),
                  ),
            dialogBackgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF613EEA),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
              headerBackgroundColor: const Color(0xFF613EEA),
              headerForegroundColor: Colors.white,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return isDark ? Colors.white : const Color(0xFF141414);
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF613EEA);
                }
                return Colors.transparent;
              }),
              todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF613EEA);
                }
                return Colors.transparent;
              }),
              todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return const Color(0xFF613EEA);
              }),
              yearForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return isDark ? Colors.white : const Color(0xFF141414);
              }),
              yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF613EEA);
                }
                return Colors.transparent;
              }),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add Goal',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Goal Icon with gradient
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF613EEA), Color(0xFF7C5FEE)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF613EEA)..withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 40),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Title Field
                    Text(
                      'Title',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
                          width: 1.5,
                        ),
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
                      child: TextField(
                        controller: _titleController,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter goal title',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: subtextColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Date Field
                    Text(
                      'Date',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
                            width: 1.5,
                          ),
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
                            Icon(Icons.calendar_today, size: 20, color: subtextColor),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Duration Selection
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Duration',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        // Duration Input Field
                        Container(
                          width: 100,
                          height: 48,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 50,
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '$_selectedDuration',
                                    hintStyle: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: (value) {
                                    final intValue = int.tryParse(value);
                                    if (intValue != null && intValue >= 5 && intValue <= 120) {
                                      setState(() {
                                        _selectedDuration = intValue;
                                      });
                                    }
                                  },
                                  onSubmitted: (value) {
                                    final intValue = int.tryParse(value);
                                    if (intValue != null) {
                                      setState(() {
                                        if (intValue < 5) {
                                          _selectedDuration = 5;
                                        } else if (intValue > 120) {
                                          _selectedDuration = 120;
                                        } else {
                                          _selectedDuration = intValue;
                                        }
                                      });
                                    }
                                  },
                                ),
                              ),
                              Text(
                                'min',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: subtextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Slider with Balloon Popup
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: const Color(0xFF613EEA),
                          inactiveTrackColor: isDark
                              ? const Color(0xFF3A3A3C)
                              : const Color(0xFFE5E5EA),
                          thumbColor: const Color(0xFF613EEA),
                          overlayColor: Colors.transparent,
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 14,
                            elevation: 2,
                          ),
                          valueIndicatorShape: const _BalloonSliderValueIndicatorShape(),
                          valueIndicatorColor: const Color(0xFF613EEA),
                          valueIndicatorTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          showValueIndicator: ShowValueIndicator.always,
                        ),
                        child: Slider(
                          value: _selectedDuration.toDouble(),
                          min: 5,
                          max: 120,
                          divisions: 115,
                          label: '$_selectedDuration',
                          onChanged: (value) {
                            setState(() {
                              _selectedDuration = value.toInt();
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description Field
                    Text(
                      'Description',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
                          width: 1.5,
                        ),
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
                      child: TextField(
                        controller: _descriptionController,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: textColor,
                        ),
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Enter goal description (optional)',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: subtextColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Create Goal Button (Fixed at bottom)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF613EEA), Color(0xFF7C5FEE), Color(0xFF8A6FF0)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF613EEA).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Validate input
                    if (_titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a goal title'),
                          backgroundColor: Color(0xFFFF5252),
                        ),
                      );
                      return;
                    }

                    // TODO: Save goal to backend with _selectedDuration
                    // For now, just close the screen
                    Navigator.of(context).pop();

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Goal created successfully!'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Create Goal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Balloon-shaped value indicator for slider
class _BalloonSliderValueIndicatorShape extends SliderComponentShape {
  const _BalloonSliderValueIndicatorShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(60, 70);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final double scale = activationAnimation.value;

    if (scale == 0.0) return;

    // Balloon parameters
    final double balloonRadius = 28.0 * scale;
    final double tailHeight = 12.0 * scale;
    final Offset balloonCenter = Offset(center.dx, center.dy - balloonRadius - tailHeight - 14);

    // Draw balloon body (circle)
    final Paint balloonPaint = Paint()
      ..color = sliderTheme.valueIndicatorColor ?? const Color(0xFF613EEA)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(balloonCenter, balloonRadius, balloonPaint);

    // Draw balloon tail (triangle/teardrop shape)
    final Path tailPath = Path();
    final double tailWidth = 10.0 * scale;

    tailPath.moveTo(balloonCenter.dx - tailWidth / 2, balloonCenter.dy + balloonRadius - 5);
    tailPath.quadraticBezierTo(
      balloonCenter.dx,
      balloonCenter.dy + balloonRadius + tailHeight,
      balloonCenter.dx + tailWidth / 2,
      balloonCenter.dy + balloonRadius - 5,
    );
    tailPath.close();

    canvas.drawPath(tailPath, balloonPaint);

    // Draw text
    final TextSpan textSpan = TextSpan(
      text: labelPainter.text?.toPlainText() ?? '',
      style: sliderTheme.valueIndicatorTextStyle,
    );

    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: textDirection,
    );

    textPainter.layout();

    final Offset textCenter = Offset(
      balloonCenter.dx - (textPainter.width / 2),
      balloonCenter.dy - (textPainter.height / 2),
    );

    textPainter.paint(canvas, textCenter);
  }
}
