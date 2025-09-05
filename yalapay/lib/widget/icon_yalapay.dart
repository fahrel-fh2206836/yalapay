import 'package:flutter/material.dart';
import 'package:yalapay/constants/constants.dart';

class YalapayIcon extends StatelessWidget {
  const YalapayIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [lightSecondary, Color.fromARGB(255, 219, 143, 219)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          "assets/images/yalapay_logo_normal.png",
          width: 28,
        ),
      ),
    );
  }
}
