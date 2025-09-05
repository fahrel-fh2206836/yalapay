import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String type;
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.type,
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black.withOpacity(0.8),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      content: Text(
        content,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white70,
        ),
      ),
      actions: [
        TextButton(
          child: const Text(
            'Cancel',
            style: TextStyle(fontSize: 14),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Confirm'),
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$type details have been updated.'),
                duration: const Duration(seconds: 3),
              ),
            );
          },
        ),
      ],
    );
  }
}
