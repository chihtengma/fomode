import "package:flutter_test/flutter_test.dart";
import "package:fomode/models/goal.dart";

void main() {
  group('Goal Model Tests', () {
    // Group related tests

    test('Create Goal Manually', () {
      // Individual test
      // Arrage - set up test data
      final goal = Goal(
        id: 1,
        userId: 1,
        title: "Solve 10 LeetCode problems",
        description: "Focus on arrays and strings",
        completed: false,
        createdAt: DateTime(2025, 11, 14, 10, 0, 0)
      );

      // Act - perform action (if needed)


      // Assert - check result
      expect(goal.id, 1);
      expect(goal.title, "Solve 10 LeetCode problems");
    });

      // More tests...
  });
}
