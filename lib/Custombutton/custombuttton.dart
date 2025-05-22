import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String? text;
  final Color? color;
  final Color? textColor;
  final Icon? icon;
  final Color? borderColor;
  final double? borderWidth;
  final Image? image;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final double? fontSize;

  const CustomButton({
    super.key,
    required this.text,
    required this.color,
    required this.textColor,
    this.icon,
    this.borderColor,
    this.borderWidth,
    this.image,
    this.onPressed,
    this.isOutlined = false,
    this.fontSize,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    final bool hasText = widget.text != null && widget.text!.isNotEmpty;

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          widget.icon!,
          if (hasText) const SizedBox(width: 8),
        ],
        if (widget.image != null) ...[
          widget.image!,
          if (hasText) const SizedBox(width: 8),
        ],
        if (hasText)
          Text(
            widget.text!,
            style: TextStyle(
              color: widget.isOutlined ? widget.color : widget.textColor,
              fontSize: 18,
            ),
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(12),
      child: widget.isOutlined
          ? OutlinedButton(
              onPressed: widget.onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: widget.borderColor ?? widget.color ?? Colors.white,
                  width: widget.borderWidth ?? 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: hasText
                    ? const Size(double.infinity, 60)
                    : const Size(60, 60),
                backgroundColor: widget.color,
              ),
              child: content,
            )
          : ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                foregroundColor: widget.textColor,
                minimumSize: hasText
                    ? const Size(double.infinity, 60)
                    : const Size(70, 70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: widget.borderColor ?? Colors.white,
                    width: widget.borderWidth ?? 1,
                  ),
                ),
                textStyle:  TextStyle(fontSize: widget.fontSize ?? 10),

              ),
              child: content,
            ),
    );
  }
}
