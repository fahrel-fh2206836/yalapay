import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:yalapay/constants/constants.dart';

class SharedSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const SharedSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
  });

  @override
  _SharedSearchBarState createState() => _SharedSearchBarState();
}

class _SharedSearchBarState extends State<SharedSearchBar> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {}); // Update UI to show/hide the clear button
      widget.onChanged(controller.text);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void clearSearch() {
    controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
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
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: lightPrimary,
                  width: 2,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 170, 170, 170).withOpacity(0.05),
                    const Color.fromARGB(255, 170, 170, 170).withOpacity(0.05),
                  ],
                ),
              ),
            ),
            Center(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  hintText: widget.hintText,
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white),
                          onPressed: clearSearch,
                        )
                      : null,
                  hintStyle: TextStyle(color: Colors.grey[400]),
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
