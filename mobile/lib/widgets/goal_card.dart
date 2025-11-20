/// Goal Card Widget - Display a single goal item
///
/// Features:
/// - Checkbox for completion toggle
/// - Title with strikethrough when completed
/// - Optional description
/// - Edit/Delete menu
/// - Tap anywhere to toggle completion
///
/// Reusable across any screen that needs to display goals
library;

import 'package:flutter/material.dart';
import '../models/goal.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggleComplete,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Custom Checkbox
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: goal.completed
                          ? const Color(0xFF2D4FC6)
                          : const Color(0xFFDDDDDD),
                      width: 2,
                    ),
                    color: goal.completed
                        ? const Color(0xFF2D4FC6)
                        : Colors.transparent,
                  ),
                  child: goal.completed
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 14),

                // Goal content (title + description)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        goal.title,
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: goal.completed
                              ? TextDecoration.lineThrough
                              : null,
                          decorationThickness: 1.5,
                          color: goal.completed
                              ? const Color(0xFF999999)
                              : const Color(0xFF141414),
                          height: 1.375,
                        ),
                      ),

                      // Description
                      if (goal.description != null &&
                          goal.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          goal.description!,
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: goal.completed
                                ? const Color(0xFFBBBBBB)
                                : const Color.fromRGBO(20, 20, 20, 0.6),
                            decoration: goal.completed
                                ? TextDecoration.lineThrough
                                : null,
                            decorationThickness: 1,
                            height: 1.43,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Edit/Delete menu
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: Color(0xFF999999),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            size: 18,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 12),
                          const Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded,
                              size: 18, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Delete',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
