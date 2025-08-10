import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  final String value;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;
  final Widget? child;

  const CalculatorButton({
    super.key,
    required this.value,
    required this.color,
    required this.textColor,
    required this.onPressed,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(7.5),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(19),
            minimumSize: const Size(78, 78),
          ),
          child: child ??
              Text(
                value,
                style: const TextStyle(
                  fontSize: 34.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
        ),
      ),
    );
  }
}
