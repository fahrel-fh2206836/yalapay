import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:yalapay/constants/constants.dart';

Widget blurredGradientBackground(BuildContext context) {
  return Stack(
    children: [
      Align(
        alignment: const AlignmentDirectional(20, -1.2),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: darkSecondary,
          ),
        ),
      ),
      Align(
        alignment: const AlignmentDirectional(-2.7, -1.2),
        child: Container(
          height: MediaQuery.of(context).size.width / 1.3,
          width: MediaQuery.of(context).size.width / 1.3,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromARGB(255, 85, 33, 170),
          ),
        ),
      ),
      Align(
        alignment: const AlignmentDirectional(2.7, -1.2),
        child: Container(
          height: MediaQuery.of(context).size.width / 1.3,
          width: MediaQuery.of(context).size.width / 1.3,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromARGB(255, 130, 16, 130),
          ),
        ),
      ),
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
        child: Container(),
      ),
    ],
  );
}

class BackgroundGradient extends StatelessWidget {
  final Widget child;
  final List<Color> colors;

  const BackgroundGradient({
    required this.child,
    required this.colors,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
        ),
        child: child,
      ),
    );
  }
}
