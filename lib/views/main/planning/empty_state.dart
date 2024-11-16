import 'package:flutter/material.dart';
import 'package:studieapp/theme/app_theme.dart';

Widget buildEmptyState(String title, String subtitle) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.assignment_outlined,
          size: 64,
          color: AppTheme.textTertiary,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: AppTheme.getOrbitronStyle(
            size: 20,
            weight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: AppTheme.getOrbitronStyle(
            size: 16,
            color: AppTheme.textTertiary,
          ),
        ),
      ],
    ),
  );
}
