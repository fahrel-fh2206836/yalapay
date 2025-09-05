import 'package:flutter/material.dart';
import 'package:yalapay/constants/constants.dart';

Container iconContainer(IconData icon,
    {Color iconColor = Colors.white, Color? backgroundColor = lightPrimary}) {
  return Container(
    height: 30,
    width: 30,
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(
      icon,
      color: iconColor,
    ),
  );
}
