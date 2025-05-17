// ملف: custombuttton.dart
import 'package:flutter/material.dart';

class CustomButtonCategory extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;

  const CustomButtonCategory({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = Colors.black,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  State<CustomButtonCategory> createState() => _CustomButtonCategoryState();
}

class _CustomButtonCategoryState extends State<CustomButtonCategory> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: widget.color,
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(10),
            boxShadow: _isHovering
                ? [
                    const BoxShadow(
                      color: Colors.white24,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              color: widget.textColor,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
