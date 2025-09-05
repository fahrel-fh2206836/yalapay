import 'package:flutter/material.dart';
import 'package:yalapay/constants/constants.dart';

class AddScreensTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final double height;
  final double width;
  final TextInputType type;
  final Color? activeBorderColor;
  final ValueChanged<String>? onChanged;
  final IconButton? suffixIcon;

  const AddScreensTextField({
    super.key,
    required this.controller,
    required this.label,
    this.width = double.infinity,
    this.height = 60,
    this.type = TextInputType.text,
    this.activeBorderColor,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  State<AddScreensTextField> createState() => _AddScreensTextFieldState();
}

class _AddScreensTextFieldState extends State<AddScreensTextField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: TextField(
        keyboardType: widget.type,
        controller: widget.controller,
        style: getTextStyle('small', color: Colors.white),
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.label,
          hintStyle: getTextStyle('small', color: Colors.grey),
          suffixIcon: widget.suffixIcon ??
              (widget.controller.text.isNotEmpty
                  ? IconButton(
                      onPressed: widget.controller.clear,
                      icon: const Icon(Icons.clear, color: Colors.grey),
                    )
                  : null),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 1, color: lightSecondary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(width: 1, color: lightPrimary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: widget.activeBorderColor ?? lightSecondary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
