import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yalapay/constants/constants.dart';

class EditScreenTextField extends ConsumerWidget {
  final String label;
  final TextEditingController controller;
  final double width;
  final TextInputType type;
  final double height;
  final bool centerText;

  const EditScreenTextField({
    super.key,
    required this.label,
    required this.controller,
    this.width = 200,
    this.type = TextInputType.text,
    this.height = 60,
    this.centerText = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: TextField(
          keyboardType: type,
          controller: controller,
          style: getTextStyle('small', color: Colors.white),
          textAlign: centerText ? TextAlign.center : TextAlign.start,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: getTextStyle('small', color: lightSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(width: 1, color: lightPrimary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: lightSecondary,
                width: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
