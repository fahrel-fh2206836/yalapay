import 'package:flutter/material.dart';
import 'package:yalapay/constants/constants.dart';

class SectionTitleWithIcon extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const SectionTitleWithIcon({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8, height: 8),
            Text(
              title,
              style: getTextStyle("mediumBold", color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
