/// Goal provider
///
/// Manages goal state and provides goals to the entire app.
/// Uses changeNotifier to notify UI when data changes.
library;

import 'package:flutter/foundation.dart';
import '../models/goal.dart';
import '../services/goals_api_service.dart';

/// Goal Provider
///
/// This class manages the state of goals in the app.
/// It talks to the API service and notiifes listeners when data changes.
///
/// How it works:
/// 1. Screens/widgets "listen" to this provider
/// 2. When data changes, provider calls notifyListeners()
/// 3. UI automatically rebuilds with new data
class GoalProvider extends ChangeNotifier {
  // Private fields
  final GoalsApiService _apiService;
  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  // Constructor
  GoalProvider({GoalsApiService? apiService})
      : _apiService = apiService ?? GoalsApiService();

  // ============================================
  // Getters (Read-only access to private fields)
  // ============================================

  /// List of all goals
  List<Goal> get goals => _goals;

  /// Loading state
  bool get isLoading => _isLoading;

  /// Error message (null if no error)
  String? get error => _error;

  /// Check if there are any goals
  bool get hasGoals => _goals.isNotEmpty;

  /// Count of total goals
  int get totalGoals => _goals.length;

  /// Count of completed goals
  int get completedGoals => _goals.where((goal) => goal.completed).length;

  /// Count of incomplete goals
  int get incompleteGoals => _goals.where((goal) => !goal.completed).length;

  // ============================================
  // API Methods
  // ============================================

  /// Fetch all goals from backend
  ///
  /// This loads goals and updates the UI.
  Future<void> fetchGoals() async {
    _setLoading(true);
    _clearError();

    try {
      _goals = await _apiService.getGoals();
      notifyListeners(); // Tell UI to rebuild
    } catch (err) {
      _setError('Failed to load goals: $err');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new goal
  ///
  /// Returns the created goal or null if failed
  Future<Goal?> createGoal({
    required String title,
    String? description,
  }) async {
    _clearError();

    try {
      final newGoal = await _apiService.createGoal(
        title: title,
        description: description,
      );

      // Add to local list
      _goals.add(newGoal);
      notifyListeners();

      return newGoal;
    } catch (err) {
      _setError('Failed to create goal: $err');
      return null;
    }
  }

  /// Update an existing goal
  ///
  /// Returns the updated goal or null if failed
  Future<Goal?> updateGoal({
    required int id,
    String? title,
    String? description,
    bool? completed,
  }) async {
    _clearError();

    try {
      final updatedGoal = await _apiService.updateGoal(
        id: id,
        title: title,
        description: description,
        completed: completed,
      );

      // Update in local list
      final index = _goals.indexWhere((goal) => goal.id == id);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
      }

      return updatedGoal;
    } catch (err) {
      _setError('Failed to update goal: $err');
      return null;
    }
  }

  /// Mark a goal as complete
  ///
  /// Convenience method for completing goals.
  Future<bool> completedGoal(int id) async {
    _clearError();

    try {
      final completedGoal = await _apiService.completeGoal(id);

      // Update in local list
      final index = _goals.indexWhere((goal) => goal.id == id);
      if (index != -1) {
        _goals[index] = completedGoal;
        notifyListeners();
        return true;
      }

      return false;
    } catch (err) {
      _setError('Fail to complete goal: $err');
      return false;
    }
  }

  /// Delete a goal
  ///
  /// Returns true if sucessful, false otherwise.
  Future<bool> deleteGoal(int id) async {
    _clearError();

    try {
      await _apiService.deleteGoal(id);

      // Remove from local list
      _goals.removeWhere((goal) => goal.id == id);
      notifyListeners();

      return true;
    } catch (err) {
      _setError('Fail to delete goal: $err');
      return false;
    }
  }

  // ============================================
  // Helper Methods
  // ============================================

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
  }

  /// Dispose resources
  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
