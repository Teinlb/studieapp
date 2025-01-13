import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studieapp/theme/app_theme.dart';

class PlanningDialog extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final String submitText;
  final bool isSubmitEnabled;

  const PlanningDialog({
    super.key,
    required this.title,
    required this.children,
    required this.onCancel,
    required this.onSubmit,
    this.submitText = 'Toevoegen',
    this.isSubmitEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ...children,
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: Text(
                    'Annuleren',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: isSubmitEnabled ? onSubmit : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(submitText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable date picker widget
class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime) onDateSelected;
  final String hintText;

  const DatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.hintText = 'Selecteer datum',
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: firstDate ?? DateTime.now(),
          lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: AppTheme.accentOrange,
                      onPrimary: Colors.black,
                      surface: AppTheme.secondaryBlue,
                      onSurface: AppTheme.textPrimary,
                    ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.secondaryBlue,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppTheme.accentOrange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                      : hintText,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
