import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:yalapay/constants/constants.dart';

class FrostedGlassBox extends StatelessWidget {
  final double boxWidth;
  final double? boxHeight;
  final Widget boxChild;
  final bool isCurved;

  const FrostedGlassBox({
    super.key,
    required this.boxWidth,
    this.boxHeight,
    required this.boxChild,
    this.isCurved = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(isCurved ? 15 : 0),
      child: Container(
        width: boxWidth,
        height: boxHeight,
        color: Colors.transparent,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      const Color.fromARGB(255, 198, 198, 198).withOpacity(0.3),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 118, 118, 118).withOpacity(0.1),
                    const Color.fromARGB(255, 118, 118, 118).withOpacity(0.1),
                  ],
                ),
              ),
              child: boxChild,
            ),
          ],
        ),
      ),
    );
  }
}

class FrostedGlassTextField extends StatefulWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String hintText;
  final Icon prefixIcon;
  final IconButton? suffixIcon;
  final TextInputType keyboardType;
  final TextStyle? hintTextStyle;

  const FrostedGlassTextField({
    super.key,
    required this.controller,
    this.obscureText = false,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.hintTextStyle,
  });

  @override
  _FrostedGlassTextFieldState createState() => _FrostedGlassTextFieldState();
}

class _FrostedGlassTextFieldState extends State<FrostedGlassTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isFocused = _focusNode.hasFocus;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 60,
        color: Colors.transparent,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isFocused
                      ? lightSecondary.withOpacity(0.8)
                      : const Color.fromARGB(255, 198, 198, 198)
                          .withOpacity(0.1),
                  width: isFocused ? 2.0 : 1.0,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 170, 170, 170).withOpacity(0.05),
                    const Color.fromARGB(255, 170, 170, 170).withOpacity(0.05),
                  ],
                ),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5),
                          blurRadius: 8.0,
                          spreadRadius: 1.0,
                        ),
                      ]
                    : [],
              ),
            ),
            Center(
              child: TextField(
                focusNode: _focusNode,
                controller: widget.controller,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  hintText: widget.hintText,
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  hintStyle: widget.hintTextStyle ??
                      TextStyle(fontSize: 14.0, color: Colors.grey[400]),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
