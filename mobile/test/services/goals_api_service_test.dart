import 'package:flutter_test/flutter_test.dart';
import 'package:fomode/models/goal.dart';
import 'package:fomode/services/goals_api_service.dart';
import 'package:fomode/services/api_client.dart';

void main() {
  group('GoalsApiService- API Tests', () {
    late GoalsApiService service;

    setUp(() {
      // Create service before each test
      service = GoalsApiService();
    });

    tearDown(() {
      // Cleanup after each test
      service.dispose();
    });

    test('Service extends ApiClient', () {
      expect(service, isA<ApiClient>());
    });

    // ============================================
    // API Integration Tests
    // ============================================
    // NOTE: These tests require backend to be running!
    // Start backend: cd backend && docker-compose up

    test('getGoals() fetches goals from backend', () async {
      // Act
      final goals = await service.getGoals();

      // Assert
      expect(goals, isA<List<Goal>>());
      // NOTE: List might be empty if no goals in database
    }, skip: false); // Set to true if backend is not running

    test('getGoals() with completed filter works', () async {
      // Act - fetch only incomplete goals
      final incompleteGoals = await service.getGoals(completed: false);

      // Assert
      expect(incompleteGoals, isA<List<Goal>>());

      // If there are goals, they should all be incomplete
      for (var goal in incompleteGoals) {
        expect(goal.completed, false);
      }
    }, skip: false);

    test('getGoals() with pagination works', () async {
      // Act - fetch first 5 goals
      final firstPage = await service.getGoals(skip: 0, limit: 5);

      // Assert
      expect(firstPage, isA<List<Goal>>());
      expect(firstPage.length, lessThanOrEqualTo(5));
    }, skip: false);

    test('getTodaysGoals() fetches goals created today', () async {
      // Act
      final todaysGoals = await service.getTodaysGoals();

      // Assert
      expect(todaysGoals, isA<List<Goal>>());

      // All goals should have recent dates (within last 24 hours)
      // This handles timezone differences between client and server
      final now = DateTime.now();
      final oneDayAgo = now.subtract(Duration(days: 1));

      for (var goal in todaysGoals) {
        // Goal should be created within the last 24 hours
        expect(goal.createdAt.isAfter(oneDayAgo), true,
            reason: 'Goal should be created within last 24 hours');
        expect(goal.createdAt.isBefore(now.add(Duration(hours: 1))), true,
            reason: 'Goal should not be in the future');
      }
    }, skip: false);

    test('getGoal() fetches single goal by ID', () async {
      // First get all goals to find a valid ID
      final allGoals = await service.getGoals();

      // Skip test if no goals exist
      if (allGoals.isEmpty) {
        print('⚠️ No goals in database - skipping single goal test');
        return;
      }

      // Act - fetch the first goal by ID
      final goalId = allGoals.first.id;
      final goal = await service.getGoal(goalId);

      // Assert
      expect(goal, isA<Goal>());
      expect(goal.id, goalId);
      expect(goal.title, isNotEmpty);
    }, skip: false);

    test('getGoal() throws exception for invalid ID', () async {
      // Act & Assert
      expect(
        () => service.getGoal(9999), // ID that doesn't exist
        throwsA(isA<ApiException>()),
      );
    }, skip: false);

    // ============================================
    // Error Handling Tests
    // ============================================

    test('ApiException contains error details', () {
      final exception = ApiException(
        statusCode: 404,
        message: 'Goal not found',
      );

      expect(exception.statusCode, 404);
      expect(exception.message, 'Goal not found');
      expect(exception.toString(), contains('404'));
      expect(exception.toString(), contains('Goal not found'));
    });

    // ============================================
    // Create, Update, Delete Tests
    // ============================================

    test('createGoal() creates a new goal', () async {
      // Act - create a goal
      final goal = await service.createGoal(
        title: 'Test Goal from Flutter',
        description: 'This is a test',
      );

      // Assert
      expect(goal, isA<Goal>());
      expect(goal.id, greaterThan(0)); // Should have an ID
      expect(goal.title, 'Test Goal from Flutter');
      expect(goal.description, 'This is a test');
      expect(goal.completed, false); // New goals are incomplete
    }, skip: false);

    test('updateGoal() updates an existing goal', () async {
      // Arrange - create a goal first
      final created = await service.createGoal(title: 'Original Title');

      // Act - update it
      final updated = await service.updateGoal(
        id: created.id,
        title: 'Updated Title',
        completed: true,
      );

      // Assert
      expect(updated.id, created.id); // Same ID
      expect(updated.title, 'Updated Title'); // Title changed
      expect(updated.completed, true); // Now completed

      // Cleanup
      await service.deleteGoal(created.id);
    }, skip: false);

    test('completeGoal() mark goal as complete', () async {
      // Arrange - create a goal
      final created = await service.createGoal(title: 'Goal to Complete');

      // Act - mark as complete
      final completed = await service.completeGoal(created.id);

      // Assert
      expect(completed.id, created.id);
      expect(completed.completed, true); // Now completed!

      // Cleanup
      await service.deleteGoal(created.id);
    }, skip: false);

    test('deleteGoal() removes a goal', () async {
      // Arrange - create a goal
      final created = await service.createGoal(title: "Goal to Delete");

      // Act - delete it
      await service.deleteGoal(created.id);

      // Assert - trying to get it should fail
      expect(
        () => service.getGoal(created.id),
        throwsA(isA<ApiException>()),
      );
    }, skip: false);

    test('Full CRUD workflow', () async {
      // 1. Create
      final created = await service.createGoal(
        title: 'Full CRUD Test',
        description: 'Testing all operations',
      );
      expect(created.title, 'Full CRUD Test');
      expect(created.completed, false);

      // 2. Read
      final fetched = await service.getGoal(created.id);
      expect(fetched.id, created.id);
      expect(fetched.title, 'Full CRUD Test');

      // 3. Update
      final updated =
          await service.updateGoal(id: created.id, title: 'Updated CRUD Test');
      expect(updated.id, created.id);
      expect(updated.title, 'Updated CRUD Test');

      // 4. Complete
      final Goal completed = await service.completeGoal(created.id);
      expect(completed.completed, true);

      // 5. Delete
      await service.deleteGoal(created.id);

      // 6. Verify delete
      expect(() => service.getGoal(created.id), throwsA(isA<ApiException>()));
    }, skip: false);

    // ============================================
    // Additional CRUD Tests After Refactoring
    // ============================================

    test('createGoal() - multiple goals with different data', () async {
      final goals = <Goal>[];

      // Create 3 different goals
      goals.add(await service.createGoal(
        title: 'Goal 1',
        description: 'First test goal',
      ));

      goals.add(await service.createGoal(
        title: 'Goal 2',
      )); // No description

      goals.add(await service.createGoal(
        title: 'Goal 3',
        description: 'Third test goal',
      ));

      // Assert all created successfully
      for (var goal in goals) {
        expect(goal.id, greaterThan(0));
        expect(goal.completed, false);
      }

      // Cleanup
      for (var goal in goals) {
        await service.deleteGoal(goal.id);
      }
    }, skip: false);

    test('updateGoal() - partial updates work correctly', () async {
      // Create a goal
      final created = await service.createGoal(
        title: 'Original',
        description: 'Original description',
      );

      // Update only title
      final updatedTitle = await service.updateGoal(
        id: created.id,
        title: 'New Title',
      );
      expect(updatedTitle.title, 'New Title');
      expect(updatedTitle.description, 'Original description'); // Unchanged

      // Update only description
      final updatedDesc = await service.updateGoal(
        id: created.id,
        description: 'New Description',
      );
      expect(updatedDesc.description, 'New Description');

      // Update only completed status
      final updatedCompleted = await service.updateGoal(
        id: created.id,
        completed: true,
      );
      expect(updatedCompleted.completed, true);

      // Cleanup
      await service.deleteGoal(created.id);
    }, skip: false);

    test('getGoals() - filtering and pagination work', () async {
      // Create some test goals
      final goal1 = await service.createGoal(title: 'Incomplete 1');
      final goal2 = await service.createGoal(title: 'Incomplete 2');
      final goal3 = await service.createGoal(title: 'Complete 1');
      await service.completeGoal(goal3.id);

      // Test: Get all goals
      final allGoals = await service.getGoals();
      expect(allGoals.length, greaterThanOrEqualTo(3));

      // Test: Get only incomplete goals
      final incompleteGoals = await service.getGoals(completed: false);
      for (var goal in incompleteGoals) {
        expect(goal.completed, false);
      }

      // Test: Get only completed goals
      final completedGoals = await service.getGoals(completed: true);
      for (var goal in completedGoals) {
        expect(goal.completed, true);
      }

      // Test: Pagination (limit)
      final limitedGoals = await service.getGoals(limit: 2);
      expect(limitedGoals.length, lessThanOrEqualTo(2));

      // Cleanup
      await service.deleteGoal(goal1.id);
      await service.deleteGoal(goal2.id);
      await service.deleteGoal(goal3.id);
    }, skip: false);

    test('getTodaysGoals() - only returns today\'s goals', () async {
      // Create a goal (will have today's date)
      final todayGoal = await service.createGoal(
        title: 'Today\'s Goal',
      );

      // Get today's goals
      final todaysGoals = await service.getTodaysGoals();

      // Should include the goal we just created
      final createdGoalInList = todaysGoals.any((g) => g.id == todayGoal.id);
      expect(createdGoalInList, true);

      // All should be recent (within last 24 hours)
      // This handles timezone differences between client and server
      final now = DateTime.now();
      final oneDayAgo = now.subtract(Duration(days: 1));

      for (var goal in todaysGoals) {
        expect(goal.createdAt.isAfter(oneDayAgo), true,
            reason: 'Goal ${goal.id} should be created within last 24 hours');
      }

      // Cleanup
      await service.deleteGoal(todayGoal.id);
    }, skip: false);

    test('completeGoal() vs updateGoal() - both methods work', () async {
      // Create two goals
      final goal1 = await service.createGoal(title: 'Complete via completeGoal()');
      final goal2 = await service.createGoal(title: 'Complete via updateGoal()');

      // Method 1: Use completeGoal()
      final completed1 = await service.completeGoal(goal1.id);
      expect(completed1.completed, true);

      // Method 2: Use updateGoal()
      final completed2 = await service.updateGoal(
        id: goal2.id,
        completed: true,
      );
      expect(completed2.completed, true);

      // Both should be completed
      final fetchedGoal1 = await service.getGoal(goal1.id);
      final fetchedGoal2 = await service.getGoal(goal2.id);
      expect(fetchedGoal1.completed, true);
      expect(fetchedGoal2.completed, true);

      // Cleanup
      await service.deleteGoal(goal1.id);
      await service.deleteGoal(goal2.id);
    }, skip: false);

    test('deleteGoal() - cannot fetch deleted goal', () async {
      // Create and delete a goal
      final created = await service.createGoal(title: 'To be deleted');
      final goalId = created.id;

      await service.deleteGoal(goalId);

      // Try to fetch - should throw error
      expect(
        () => service.getGoal(goalId),
        throwsA(
          predicate((e) =>
              e is ApiException &&
              (e.statusCode == 404 || e.message.contains('404'))),
        ),
      );
    }, skip: false);

    test('Stress test - create, update, delete 10 goals', () async {
      final goalIds = <int>[];

      // Create 10 goals
      for (var i = 1; i <= 10; i++) {
        final goal = await service.createGoal(
          title: 'Stress Test Goal $i',
          description: 'Testing goal number $i',
        );
        goalIds.add(goal.id);
        expect(goal.title, 'Stress Test Goal $i');
      }

      // Update all to completed
      for (var id in goalIds) {
        final updated = await service.completeGoal(id);
        expect(updated.completed, true);
      }

      // Delete all
      for (var id in goalIds) {
        await service.deleteGoal(id);
      }

      // Verify all deleted
      for (var id in goalIds) {
        expect(
          () => service.getGoal(id),
          throwsA(isA<ApiException>()),
        );
      }
    }, skip: false);

    test('Edge case - create goal with very long title', () async {
      // Create goal with 200 character title (max length)
      final longTitle = 'A' * 200;
      final goal = await service.createGoal(title: longTitle);

      expect(goal.title, longTitle);
      expect(goal.title.length, 200);

      // Cleanup
      await service.deleteGoal(goal.id);
    }, skip: false);

    test('Edge case - create goal with empty description', () async {
      final goal = await service.createGoal(
        title: 'No description goal',
        description: null,
      );

      expect(goal.title, 'No description goal');
      expect(goal.description, null);

      // Cleanup
      await service.deleteGoal(goal.id);
    }, skip: false);
  });
}
