import 'package:flutter/material.dart';

import 'calculator_button.dart';

class ButtonGrid extends StatelessWidget {
  final Function(String) onButtonPressed;

  const ButtonGrid({super.key, required this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              CalculatorButton(
                  value: "AC",
                  color: const Color(0xFFA5A5A5),
                  textColor: Colors.black,
                  onPressed: () => onButtonPressed("AC")),
              CalculatorButton(
                  value: "⌫",
                  color: const Color(0xFFA5A5A5),
                  textColor: Colors.black,
                  onPressed: () => onButtonPressed("⌫")),
              CalculatorButton(
                  value: "%",
                  color: const Color(0xFFA5A5A5),
                  textColor: Colors.black,
                  onPressed: () => onButtonPressed("%")),
              CalculatorButton(
                  value: "÷",
                  color: const Color(0xFFFF9500),
                  textColor: Colors.white,
                  onPressed: () => onButtonPressed("÷")),
            ],
          ),
          Row(
            children: <Widget>[
              CalculatorButton(
                  value: "7",
                  color: const Color(0xFF333333),
                  textColor: Colors.white,
                  onPressed: () => onButtonPressed("7")),
              CalculatorButton(
                  value: "8",
                  color: const Color(0xFF333333),
                  textColor: Colors.white,
                  onPressed: () => onButtonPressed("8")),
              CalculatorButton(
                  value: "9",
                  color: const Color(0xFF333333),
                  textColor: Colors.white,
                  onPressed: () => onButtonPressed("9")),
              CalculatorButton(
                  value: "×",
                  color: const Color(0xFFFF9500),
                  textColor: Colors.white,
                  onPressed: () => onButtonPressed("×")),
            ],
          ),
          Row(
            children: <Widget>[
              CalculatorButton(
                  value: "4",
                  color: const Color(0xFF333333),
                  textColor: Colors.white,
                  onPressed: () => onButtonPressed("4")),
              CalculatorButton(
                  value: "5",
                  color: const Color(0xFF333333),
                  textColor: Colors.white,
                  onPressed: () => onButtonPressed("5")),
              CalculatorButton(
                  value: "6",n                  color: const Color(0xFF333333),
                  textColor: Colors.white,
                  onPressed: () => onButtonPressed("6")),
              CalculatorButton(
                  value: "-",
                  color: const Color(0xFFFF9500),
                  textColor: Colors.white,
                  onPressed: () => onButtonPressed("-")),
            ],
          ),
          Row(
            children: <Widget>[
              CalculatorButton(
                  value: "1",
                  color: const Color(0xFF333333),
                  textColor: Colors.white,
                  onPressed: () => onButtonPressed("1")),
              CalculatorButton(
                  value: "2",
                  color: const Color(0xFF333333),
                  textColor: Colors.white,
                  onPressed: () => onButtonPressed("2")),
              CalculatorButton(
                  value: "3",
                  color: const Color(0xFF333333),
                  textColor: Colors.white,
                  onPressed: () => onButtonPressed("3")),
              CalculatorButton(
                  value: "+",
                  color: const Color(0xFFFF9500),
                  textColor: Colors.white,
                  onPressed: () => onButtonPressed("+")),
            ],
          ),
          Row(
            children: <Widget>[
              CalculatorButton(
                  value: "calculator",
                  color: const Color(0xFF333333),
                  textColor: Colors.white,
                  onPressed: () {},
                  child: const Icon(Icons.calculate, size: 34.0)),
              CalculatorButton(
                  value: "0",
                  color: const Color(0xFF333333),
                  textColor: Colors.white,
                  onPressed: () => onButtonPressed("0")),
              CalculatorButton(
                  value: ".",
                  color: const Color(0xFF333333),
                  textColor: Colors.white,
                  onPressed: () => onButtonPressed(".")),
              CalculatorButton(
                  value: "=",
                  color: const Color(0xFFFF9500),
                  textColor: Colors.white,
                  onPressed: () => onButtonPressed("=")),
            ],
          ),
        ],
      ),
    );
  }
}
