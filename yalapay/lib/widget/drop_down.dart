import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DropDown extends ConsumerWidget {
  final List<String> list;
  final TextEditingController controller;
  final String label;
  final double menuHeight;
  final double height;
  final double width;
  final Color color;

  const DropDown(
      {super.key,
      required this.controller,
      required this.list,
      required this.label,
      required this.menuHeight,
      this.height = 40,
      this.width = 130,
      this.color = Colors.black});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownMenu(
      textStyle: TextStyle(color: color),
      width: width,
      menuHeight: menuHeight,
      hintText: label,
      controller: controller,
      dropdownMenuEntries: list
          .map<DropdownMenuEntry<String>>(
              (String status) => DropdownMenuEntry<String>(
                    value: status,
                    label: status,
                  ))
          .toList(),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        constraints: BoxConstraints.tight(
          Size.fromHeight(height),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
