/// Article Detail Screen - Displays focus tips and productivity articles
///
/// Features:
/// - Full article content with rich formatting
/// - Source attribution and author credits
/// - Beautiful typography
/// - Theme-aware design
///
/// Content Attribution:
/// - Deep Work: Based on research by Cal Newport (Author of "Deep Work: Rules for Focused Success in a Distracted World")
/// - Flow State: Based on research by Mihaly Csikszentmihalyi (Psychologist and author of "Flow")
/// - Pomodoro: Based on the Pomodoro Technique by Francesco Cirillo
library;

import 'package:flutter/material.dart';

class ArticleDetailScreen extends StatelessWidget {
  final String title;
  final String category;
  final String readTime;
  final Color accentColor;

  const ArticleDetailScreen({
    super.key,
    required this.title,
    required this.category,
    required this.readTime,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFAFAFA);
    final textColor = isDark ? Colors.white : const Color(0xFF141414);
    final subtextColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF666666);

    // Get article content based on category
    final content = _getArticleContent(category);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Hero Header with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor,
                    accentColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Custom App Bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Back button
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const Spacer(),
                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Read time
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                readTime,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Title in header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Article content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Content sections
                    ...content.map((section) {
                      if (section['type'] == 'heading') {
                        return Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  section['text'] as String,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (section['type'] == 'subheading') {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 20,
                                color: accentColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  section['text'] as String,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: accentColor,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (section['type'] == 'paragraph') {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            section['text'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: textColor,
                              height: 1.6,
                            ),
                          ),
                        );
                      } else if (section['type'] == 'bullet') {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12, left: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(top: 8, right: 12),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  section['text'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: textColor,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (section['type'] == 'quote') {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: accentColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            section['text'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),

                    const SizedBox(height: 40),

                    // Source Attribution
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 20,
                                color: accentColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'About This Article',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getSourceAttribution(category),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: subtextColor,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 16,
                                  color: accentColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Curated by Fomode',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSourceAttribution(String category) {
    switch (category) {
      case 'Deep Work':
        return 'This article is based on research and concepts from "Deep Work: Rules for Focused Success in a Distracted World" by Cal Newport, a computer science professor at Georgetown University. The content has been adapted and curated for educational purposes.';
      case 'Flow State':
        return 'This article draws from the groundbreaking work of Mihaly Csikszentmihalyi, a Hungarian-American psychologist who pioneered research on flow states. His book "Flow: The Psychology of Optimal Experience" is the foundational source for this content.';
      case 'Pomodoro':
        return 'The Pomodoro Technique was developed by Francesco Cirillo in the late 1980s. This article explains the technique for educational purposes, helping you implement this time management method in your daily routine.';
      default:
        return 'This article has been curated from various productivity research sources for educational purposes.';
    }
  }

  List<Map<String, String>> _getArticleContent(String category) {
    switch (category) {
      case 'Deep Work':
        return [
          {
            'type': 'paragraph',
            'text':
                'Deep work is the ability to focus without distraction on a cognitively demanding task. It\'s a skill that allows you to quickly master complicated information and produce better results in less time.',
          },
          {
            'type': 'heading',
            'text': 'What is Deep Work?',
          },
          {
            'type': 'paragraph',
            'text':
                'Coined by computer science professor Cal Newport, deep work describes professional activities performed in a state of distraction-free concentration that push your cognitive capabilities to their limit. These efforts create new value, improve your skill, and are hard to replicate.',
          },
          {
            'type': 'quote',
            'text':
                '"Deep work is the ability to focus without distraction on a cognitively demanding task." - Cal Newport',
          },
          {
            'type': 'heading',
            'text': 'Why Deep Work Matters',
          },
          {
            'type': 'paragraph',
            'text':
                'In our increasingly distracted world, the ability to do deep work is becoming simultaneously more rare and more valuable. Those who cultivate this skill will thrive professionally.',
          },
          {
            'type': 'subheading',
            'text': 'Key Benefits:',
          },
          {
            'type': 'bullet',
            'text': 'Achieve up to 500% more productivity in your work sessions',
          },
          {
            'type': 'bullet',
            'text': 'Master complex skills and information faster',
          },
          {
            'type': 'bullet',
            'text': 'Produce higher quality work in less time',
          },
          {
            'type': 'bullet',
            'text': 'Experience greater professional satisfaction',
          },
          {
            'type': 'heading',
            'text': 'How to Practice Deep Work',
          },
          {
            'type': 'subheading',
            'text': '1. Schedule Deep Work Sessions',
          },
          {
            'type': 'paragraph',
            'text':
                'Set aside specific blocks of time (1-4 hours) dedicated to deep work. Start with shorter sessions if you\'re new to this practice.',
          },
          {
            'type': 'subheading',
            'text': '2. Eliminate Distractions',
          },
          {
            'type': 'paragraph',
            'text':
                'Turn off notifications, close unnecessary apps, and create a distraction-free environment. It takes 15-20 minutes to reach peak concentration, and every distraction resets this clock.',
          },
          {
            'type': 'subheading',
            'text': '3. Take Regular Breaks',
          },
          {
            'type': 'paragraph',
            'text':
                'The average person can only sustain deep work for about 4 hours per day. Take breaks to recharge and maintain peak performance.',
          },
          {
            'type': 'paragraph',
            'text':
                'Note: This article is for educational purposes only. For the complete methodology and research, please refer to Cal Newport\'s book "Deep Work: Rules for Focused Success in a Distracted World".',
          },
        ];

      case 'Flow State':
        return [
          {
            'type': 'paragraph',
            'text':
                'Flow state is a mental state where you\'re completely immersed in an activity, losing track of time and achieving peak performance. It\'s the secret to exceptional productivity and creativity.',
          },
          {
            'type': 'heading',
            'text': 'Understanding Flow State',
          },
          {
            'type': 'paragraph',
            'text':
                'When you\'re in flow state, you experience effortless concentration, loss of self-consciousness, and heightened productivity. Time seems to fly by, and you produce your best work.',
          },
          {
            'type': 'quote',
            'text':
                '"In flow, we are completely absorbed in what we are doing. Nothing else seems to matter." - Mihaly Csikszentmihalyi',
          },
          {
            'type': 'heading',
            'text': 'The Science Behind Flow',
          },
          {
            'type': 'paragraph',
            'text':
                'Research shows that people in flow state can be up to 500% more productive. Your brain releases neurochemicals that enhance focus, pattern recognition, and lateral thinking.',
          },
          {
            'type': 'heading',
            'text': '5 Ways to Achieve Flow State',
          },
          {
            'type': 'subheading',
            'text': '1. Choose the Right Challenge Level',
          },
          {
            'type': 'paragraph',
            'text':
                'Flow occurs when the task difficulty matches your skill level. Too easy and you\'re bored; too hard and you\'re anxious. Find the sweet spot.',
          },
          {
            'type': 'subheading',
            'text': '2. Set Clear Goals',
          },
          {
            'type': 'paragraph',
            'text':
                'Know exactly what you want to accomplish in your session. Clear goals provide direction and help maintain focus.',
          },
          {
            'type': 'subheading',
            'text': '3. Eliminate All Distractions',
          },
          {
            'type': 'paragraph',
            'text':
                'Turn off notifications, close unnecessary tabs, and create a dedicated workspace. Even small distractions can break your flow.',
          },
          {
            'type': 'subheading',
            'text': '4. Get Immediate Feedback',
          },
          {
            'type': 'paragraph',
            'text':
                'Flow thrives on immediate feedback. Choose tasks where you can see progress and results quickly.',
          },
          {
            'type': 'subheading',
            'text': '5. Practice Regularly',
          },
          {
            'type': 'paragraph',
            'text':
                'Like any skill, entering flow state becomes easier with practice. The more you do it, the faster you can access this state.',
          },
          {
            'type': 'heading',
            'text': 'Sustaining Flow',
          },
          {
            'type': 'bullet',
            'text': 'Work in 90-minute blocks followed by short breaks',
          },
          {
            'type': 'bullet',
            'text': 'Maintain physical and mental energy with proper rest',
          },
          {
            'type': 'bullet',
            'text': 'Stay hydrated and take care of basic needs',
          },
          {
            'type': 'bullet',
            'text': 'Limit flow sessions to 4 hours per day maximum',
          },
          {
            'type': 'paragraph',
            'text':
                'Note: This article is for educational purposes only. For the complete research and methodology, please refer to Mihaly Csikszentmihalyi\'s work on flow psychology.',
          },
        ];

      case 'Pomodoro':
        return [
          {
            'type': 'paragraph',
            'text':
                'The Pomodoro Technique is a simple yet powerful time management method that uses timed intervals to boost focus and productivity. It\'s perfect for anyone who struggles with distractions.',
          },
          {
            'type': 'heading',
            'text': 'What is the Pomodoro Technique?',
          },
          {
            'type': 'paragraph',
            'text':
                'Developed by Francesco Cirillo in the late 1980s, the Pomodoro Technique breaks work into 25-minute focused sessions (called "pomodoros") separated by short breaks.',
          },
          {
            'type': 'heading',
            'text': 'How It Works',
          },
          {
            'type': 'subheading',
            'text': 'The Basic Process:',
          },
          {
            'type': 'bullet',
            'text': 'Choose a task to work on',
          },
          {
            'type': 'bullet',
            'text': 'Set a timer for 25 minutes',
          },
          {
            'type': 'bullet',
            'text': 'Work with full focus until the timer rings',
          },
          {
            'type': 'bullet',
            'text': 'Take a 5-minute break',
          },
          {
            'type': 'bullet',
            'text': 'After 4 pomodoros, take a longer 15-30 minute break',
          },
          {
            'type': 'quote',
            'text':
                '"The Pomodoro Technique teaches you to work with time, instead of struggling against it." - Francesco Cirillo',
          },
          {
            'type': 'heading',
            'text': 'Why 25 Minutes?',
          },
          {
            'type': 'paragraph',
            'text':
                'Twenty-five minutes is long enough to make meaningful progress but short enough to maintain intense focus. This duration prevents mental fatigue and keeps you fresh throughout the day.',
          },
          {
            'type': 'heading',
            'text': 'Benefits of Pomodoro',
          },
          {
            'type': 'bullet',
            'text': 'Improves focus and concentration',
          },
          {
            'type': 'bullet',
            'text': 'Reduces mental fatigue',
          },
          {
            'type': 'bullet',
            'text': 'Increases accountability and motivation',
          },
          {
            'type': 'bullet',
            'text': 'Helps track how you spend your time',
          },
          {
            'type': 'bullet',
            'text': 'Reduces anxiety about large tasks',
          },
          {
            'type': 'heading',
            'text': 'Tips for Success',
          },
          {
            'type': 'subheading',
            'text': '1. Plan Your Pomodoros',
          },
          {
            'type': 'paragraph',
            'text':
                'At the start of your day, estimate how many pomodoros each task will take. This helps with time management and prioritization.',
          },
          {
            'type': 'subheading',
            'text': '2. Protect Your Pomodoro',
          },
          {
            'type': 'paragraph',
            'text':
                'Once you start a pomodoro, commit to it fully. If an interruption comes up, either handle it quickly or note it for your break.',
          },
          {
            'type': 'subheading',
            'text': '3. Use Your Breaks Wisely',
          },
          {
            'type': 'paragraph',
            'text':
                'Stand up, stretch, get water, or take a short walk. Avoid checking email or social media during breaks - give your mind a true rest.',
          },
          {
            'type': 'subheading',
            'text': '4. Adapt to Your Needs',
          },
          {
            'type': 'paragraph',
            'text':
                'While 25 minutes is standard, you can adjust the duration based on your task and concentration ability. Some people prefer 50-minute sessions with 10-minute breaks.',
          },
          {
            'type': 'heading',
            'text': '2025 Adaptation',
          },
          {
            'type': 'paragraph',
            'text':
                'Recent studies suggest a 75 minutes on / 33 minutes off pattern for deep work sessions. Experiment to find what works best for you!',
          },
          {
            'type': 'paragraph',
            'text':
                'Note: This article is for educational purposes only. The Pomodoro Technique® is a registered trademark of Francesco Cirillo.',
          },
        ];

      default:
        return [
          {
            'type': 'paragraph',
            'text': 'Article content not available.',
          },
        ];
    }
  }
}
