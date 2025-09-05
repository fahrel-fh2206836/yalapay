import 'package:flutter/material.dart';
import 'package:yalapay/constants/constants.dart';

class FilterDropdown extends StatelessWidget {
  final String selectedFilter;
  final List<String> options;
  final ValueChanged<String?> onSelected;

  const FilterDropdown({
    super.key,
    required this.selectedFilter,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: darkTertiary,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: darkTertiary,
          value: selectedFilter,
          items: options
              .map((filter) => DropdownMenuItem(
                    value: filter,
                    child: Text(
                      filter,
                      style: getTextStyle('small', color: Colors.white),
                    ),
                  ))
              .toList(),
          onChanged: onSelected,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        ),
      ),
    );
  }
}
