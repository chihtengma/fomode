/// Goals API Service
///
/// Handles all goal-related API endpoints.
/// Extends ApiClient to use shared HTTP functionality.
library;

import 'dart:convert';
import '../models/goal.dart';
import '../utils/constants.dart';
import 'api_client.dart';

/// Goals API Service
///
/// Provides methods for CRUD operations on goals:
/// - Get all goals
/// - Get single goal
/// - Create goal
/// - Update goal
/// - Delete goal
/// - Complete goal
class GoalsApiService extends ApiClient {
  /// Constructor
  GoalsApiService({super.baseUrl, super.client});

  // ============================================
  // Goals Endpoints
  // ============================================

  /// Get all goals
  ///
  /// Fetches goals from backend with optional filtering.
  ///
  /// Parameters:
  ///   skip: Number of goals to skip (pagination)
  ///   limit: Max number of goals to return
  ///   completed: Filter by completion status (null = all)
  ///
  /// Returns: List of Goal objects
  ///
  /// Example:
  ///   var goals = await service.getGoals(completed: false);
  Future<List<Goal>> getGoals({
    int skip = 0,
    int limit = 50,
    bool? completed,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };

      if (completed != null) {
        queryParams['completed'] = completed.toString();
      }

      // Build URI: http://localhost:800/goals?skip=0&limit=50
      final uri =
          buildUri(AppConstants.goalsEndpoint, queryParams: queryParams);

      // Make GET request
      final response = await client
          .get(uri, headers: getHeaders())
          .timeout(AppConstants.requestTimeout);

      // Check for errors
      handleError(response);

      // Parse response body
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> goalsJson = data['goals'] as List<dynamic>;

      // Convert JSOn to Goal objects
      return goalsJson
          .map((json) => Goal.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (err) {
      throw ApiException(message: "Failed to fetch goals: $err");
    }
  }

  /// Get single goal by ID
  ///
  /// Parameters:
  ///   id: Goal ID to fetch
  /// returns: Goal object
  ///
  /// Throws: ApiException if goal not found (404)
  Future<Goal> getGoal(int id) async {
    try {
      final uri = buildUri(AppConstants.goalsEndpoint, path: '/$id');

      final response = await client
          .get(uri, headers: getHeaders())
          .timeout(AppConstants.requestTimeout);

      handleError(response);

      return Goal.fromJson(json.decode(response.body));
    } catch (err) {
      throw ApiException(message: "Failed to fetch goal: $id $err");
    }
  }

  /// Get today's goals
  ///
  /// Fetches goals created today only.
  ///
  /// Returns: List of Goal objects created today
  Future<List<Goal>> getTodaysGoals() async {
    try {
      final uri = buildUri(AppConstants.goalsEndpoint, path: '/today/list');

      final response = await client
          .get(uri, headers: getHeaders())
          .timeout(AppConstants.requestTimeout);

      handleError(response);

      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> goalsJson = data['goals'] as List<dynamic>;

      return goalsJson
          .map((goal) => Goal.fromJson(goal as Map<String, dynamic>))
          .toList();
    } catch (err) {
      throw ApiException(message: 'Failed to fetch today\'s goals: $err');
    }
  }

  /// Create a new goal
  ///
  /// Sends a POST request to create a goal in the backend.
  ///
  /// Parameters:
  ///   title: Goal title (required)
  ///   description: Goal description (optional)
  ///
  /// Returns: The newly created Goal object with ID assigned by backend
  ///
  /// Example:
  ///   var goal = await service.createGoal(
  ///     title: 'Solve 10 LeetCode problems',
  ///     description: 'Focus on arrays',
  ///   );
  Future<Goal> createGoal({required String title, String? description}) async {
    try {
      final uri = buildUri(AppConstants.goalsEndpoint, path: '/');

      // Build request body
      final body = {
        'title': title,
        if (description != null) 'description': description,
      };

      // Make POST request
      final response = await client
          .post(
            uri,
            headers: getHeaders(),
            body: json.encode(body),
          )
          .timeout(AppConstants.requestTimeout);

      handleError(response);

      // Parse and return the created goal
      return Goal.fromJson(json.decode(response.body));
    } catch (err) {
      throw ApiException(message: 'Failed to create goal: $err');
    }
  }

  /// Update an existing goal
  ///
  /// Sends a PUT request to update a goal.
  /// All parameters are optional - only provide what needs to update.
  ///
  /// Parameters:
  ///   id: Goal ID to update (required)
  ///   title: New title (optional)
  ///   description: new description (optional)
  ///   completed: New completion status (optional)
  ///
  /// Returns: The updated Goal object
  ///
  /// Example:
  ///   var goal = await service.updateGoal(id: 1, completed: true);
  Future<Goal> updateGoal({
    required int id,
    String? title,
    String? description,
    bool? completed,
  }) async {
    try {
      final uri = buildUri(AppConstants.goalsEndpoint, path: '/$id');

      // Build request body - only includes fields that are provided
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (completed != null) body['completed'] = completed;

      // Make PUT request
      final response = await client
          .put(uri, headers: getHeaders(), body: json.encode(body))
          .timeout(AppConstants.requestTimeout);

      handleError(response);

      return Goal.fromJson(json.decode(response.body));
    } catch (err) {
      throw ApiException(message: 'Failed to update goal $id: err');
    }
  }

  /// Mark a goal as complete
  ///
  /// Convenience method that calls the backend's complete endpoint.
  /// This is a shortcut for updateGoal(id: id, completed: true).
  ///
  /// Parameters:
  ///   id: Goal ID to mark as complete
  ///
  /// Returns: The updated Goal object with completed = true
  ///
  /// Example:
  ///   var goal = await service.completeGoal(1);
  Future<Goal> completeGoal(int id) async {
    try {
      final uri = buildUri(AppConstants.goalsEndpoint, path: '/$id/complete');

      // Make PUT request (no body needed)
      final response = await client
          .post(uri, headers: getHeaders())
          .timeout(AppConstants.requestTimeout);

      handleError(response);

      return Goal.fromJson(json.decode(response.body));
    } catch (err) {
      throw ApiException(message: 'Failed to complete goal $id: $err');
    }
  }

  /// Delete a goal
  ///
  /// Permanently delte a goal from the backend.
  /// This action cannot be undone!
  ///
  /// Parameters:
  ///   id: Goal ID to delete
  ///
  /// Returns: Nothing (Future&lt;void>)
  ///
  /// Example:
  ///   await service.deleteGoal(1);
  Future<void> deleteGoal(int id) async {
    try {
      final uri = buildUri(AppConstants.goalsEndpoint, path: '/$id');

      // Make DELETE request
      final response = await client
          .delete(uri, headers: getHeaders())
          .timeout(AppConstants.requestTimeout);

      handleError(response);

      // No response bodt for 204 No Content
      // Just return if successful
    } catch (err) {
      throw ApiException(message: 'Failed to delete goal $id: $err');
    }
  }

  /// Dispose resources
  ///
  /// Clean up HTTP client when done.
  /// Inherited from ApiClient but made explicit here.
  @override
  void dispose() {
    super.dispose();
  }
}
