/// Add/Edit Goal Dialog Widget - Shows a form to create or update a goal
///
/// Features:
/// - Title input field (required)
/// - Description input field( required)
/// - Validation (title cannot be empty)
/// - Works for both add and edit modes
///
/// Returns the goal data when user taps Add/Save, or null when cancelled
library;

import 'package:flutter/material.dart';
import '../models/goal.dart';

class AddEditGoalDialog extends StatefulWidget {
  final Goal? goal; // If null, we're adding. If not null, we're editing.

  const AddEditGoalDialog({
    super.key,
    this.goal,
  });

  @override
  State<AddEditGoalDialog> createState() => _AddEditGoalDialogState();
}

class _AddEditGoalDialogState extends State<AddEditGoalDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing goal data (if editing)
    _titleController = TextEditingController(text: widget.goal?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.goal?.description ?? '');
  }

  @override
  void dispose() {
    // Clean up controllers when dialog is closed
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we're adding or editing based on whether goal exists
    final isEditing = widget.goal != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Goal' : 'Add Goal'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'E.g., Solve 10 LeetCode problems',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Descrption field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'E.g., Focus on arrays and strings',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),

        // Add/Save button
        FilledButton(
          onPressed: _handleSubmit,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  /// Handle form submission
  void _handleSubmit() {
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get trimmed values
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    // Return the goal data to the caller
    Navigator.pop(context, {
      'title': title,
      'description': description.isEmpty ? null : description
    });
  }
}
