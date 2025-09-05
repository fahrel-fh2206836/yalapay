import 'package:flutter/material.dart';
import 'package:yalapay/constants/constants.dart';
import 'package:yalapay/widget/edit_screen_fields.dart';
import 'package:yalapay/widget/special_text.dart';

class DetailsRow extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String value;
  final bool special;
  final bool divider;
  final String? count;

  const DetailsRow({
    super.key,
    required this.label,
    this.controller,
    required this.value,
    this.special = false,
    this.divider = true,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: divider
            ? const Border(
                bottom: BorderSide(color: borderColor, width: 1),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 48,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                label,
                style: getTextStyle('smallBold', color: Colors.white),
              ),
            ),
            Expanded(
              child: controller != null
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: EditScreenTextField(
                        label: "~$value~",
                        controller: controller!,
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: special
                          ? specialText(value)
                          : Text(
                              value,
                              style: getTextStyle('small', color: Colors.white),
                            ),
                    ),
            ),
            if (count != null)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  count!,
                  style: getTextStyle('smallBold', color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
