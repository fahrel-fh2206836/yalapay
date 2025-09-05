import 'package:flutter/material.dart';
import 'package:yalapay/constants/constants.dart';

class ConfirmDeleteDialog<T> extends StatelessWidget {
  final String title;
  final String message;
  final T itemToDelete;
  final Function(T) deleteFunction;

  const ConfirmDeleteDialog({
    super.key,
    required this.title,
    required this.message,
    required this.itemToDelete,
    required this.deleteFunction,
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
        message,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white70,
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            'Cancel',
            style: getTextStyle('medium', color: lightPrimary),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            'Confirm',
            style: getTextStyle('medium', color: lightPrimary),
          ),
          onPressed: () async {
            await deleteFunction(itemToDelete);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title has been deleted.'),
                duration: const Duration(seconds: 3),
              ),
            );
          },
        ),
      ],
    );
  }
}
