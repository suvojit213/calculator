import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../logic/calculator_logic.dart';
import 'widgets/button_grid.dart';
import 'widgets/display_screen.dart';

class CalculatorHomePage extends StatefulWidget {
  const CalculatorHomePage({super.key});

  @override
  State<CalculatorHomePage> createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  String _output = "0";
  String _expression = "";
  String _currentNumber = "";
  double _num1 = 0.0;
  String _operand = "";
  bool _isNewNumber = true;
  String _selectedOperator = "";
  int _cursorPosition = 0;
  String _realTimeOutput = "";
  bool _isCursorVisible = true;
  Timer? _cursorTimer;
  double _fontSize = 88.0;
  bool _isFinalResult = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _isCursorVisible = !_isCursorVisible;
      });
    });
  }

  @override
  void dispose() {
    _cursorTimer?.cancel();
    super.dispose();
  }

  Future<void> _updateRealTimeOutput() async {
    if (_expression.isEmpty || _isFinalResult) {
      setState(() {
        _realTimeOutput = "";
      });
      return;
    }
    final result = await compute(calculateRealTimeResult, _expression);
    if (mounted) {
      setState(() {
        _realTimeOutput = result;
      });
    }
  }

  Future<void> _buttonPressed(String buttonText) async {
    if (_isProcessing) return;

    try {
      _isProcessing = true;
      if (buttonText == "=") {
        if (_expression.isNotEmpty && !_isFinalResult) {
          final expressionToCalculate = _expression;
          setState(() {
            _isFinalResult = true;
            _realTimeOutput = "";
          });

          final result =
              await compute(calculateFinalResult, expressionToCalculate);

          setState(() {
            if (result.isEmpty) {
              _output = _currentNumber.isNotEmpty ? _currentNumber : "0";
              _expression = _output;
            } else {
              _output = result;
              _expression = result;
            }
            _currentNumber = _expression;
            _operand = "";
            _isNewNumber = true;
            _cursorPosition = _expression.length;
          });
        }
      } else {
        setState(() {
          if (buttonText == "AC") {
            _output = "0";
            _expression = "";
            _currentNumber = "";
            _num1 = 0.0;
            _operand = "";
            _isNewNumber = true;
            _cursorPosition = 0;
            _isFinalResult = false;
          } else if (buttonText == "C") {
            _output = "0";
            _expression = "";
            _currentNumber = "";
            _isNewNumber = true;
            _cursorPosition = 0;
            _isFinalResult = false;
          } else if (buttonText == "⌫") {
            if (_expression.isNotEmpty && !_isFinalResult) {
              if (_cursorPosition > 0) {
                _expression = _expression.substring(0, _cursorPosition - 1) +
                    _expression.substring(_cursorPosition);
                _cursorPosition--;
              }
            }
            _isFinalResult = false;
          } else if (buttonText == "+/-") {
            if (_currentNumber.isNotEmpty && _currentNumber != "0") {
              if (_currentNumber.startsWith("-")) {
                _currentNumber = _currentNumber.substring(1);
              } else {
                _currentNumber = "-" + _currentNumber;
              }
              _expression = _expression.replaceFirst(
                  RegExp(r'\b' + _currentNumber.replaceAll("-", "") + r'\b'),
                  _currentNumber);
              _output = _currentNumber;
            }
          } else if (buttonText == "%") {
            if (_currentNumber.isNotEmpty) {
              _expression += buttonText;
              _cursorPosition = _expression.length;
            }
            _isFinalResult = false;
          } else if (buttonText == ".") {
            if (_isFinalResult) {
              _expression = "0.";
              _currentNumber = "0.";
              _output = "0.";
              _isFinalResult = false;
            } else if (!_currentNumber.contains(".")) {
              if (_isNewNumber) {
                _currentNumber = "0.";
                _expression += "0.";
              } else {
                _currentNumber += ".";
                _expression += ".";
              }
              _output = _currentNumber;
            }
            _isNewNumber = false;
            _cursorPosition = _expression.length;
          } else if (buttonText == "+" ||
              buttonText == "-" ||
              buttonText == "×" ||
              buttonText == "÷") {
            if (_isFinalResult) {
              _expression = _output;
              _isFinalResult = false;
            }
            if (_expression.isNotEmpty) {
              if (_expression.endsWith("+") ||
                  _expression.endsWith("-") ||
                  _expression.endsWith("×") ||
                  _expression.endsWith("÷")) {
                _expression =
                    _expression.substring(0, _expression.length - 1) +
                        buttonText;
              } else {
                _expression += buttonText;
              }
            } else {
              _expression = _output + buttonText;
            }
            _isNewNumber = true;
            _currentNumber = "";
            _selectedOperator = buttonText;
            _cursorPosition = _expression.length;
          } else {
            if (_isFinalResult) {
              _expression = buttonText;
              _currentNumber = buttonText;
              _output = buttonText;
              _isFinalResult = false;
            } else {
              if (_isNewNumber) {
                _currentNumber = buttonText;
                _isNewNumber = false;
              } else {
                _currentNumber += buttonText;
              }
              if (_operand.isNotEmpty && _isNewNumber) {
                _expression += buttonText;
              } else {
                _expression = _expression.substring(0, _cursorPosition) +
                    buttonText +
                    _expression.substring(_cursorPosition);
              }
              _output = _currentNumber;
            }
            _cursorPosition = _expression.length;
            _selectedOperator = "";
          }
        });
      }
      await _updateRealTimeOutput();
    } finally {
      _isProcessing = false;
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_isFinalResult) return;
    final textSpan =
        TextSpan(text: _expression, style: TextStyle(fontSize: _fontSize));
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    final position = textPainter.getPositionForOffset(details.localPosition);
    setState(() {
      _cursorPosition = position.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          DisplayScreen(
            expression: _expression,
            cursorPosition: _cursorPosition,
            isCursorVisible: _isCursorVisible,
            isFinalResult: _isFinalResult,
            fontSize: _fontSize,
            realTimeOutput: _realTimeOutput,
            onTapUp: _onTapUp,
          ),
          ButtonGrid(onButtonPressed: _buttonPressed),
        ],
      ),
    );
  }
}