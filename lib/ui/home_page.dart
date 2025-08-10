import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../logic/calculator_logic.dart';
import 'widgets/calculator_button.dart';

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

          final result = await compute(calculateFinalResult, expressionToCalculate);

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
                _expression = _expression.substring(0, _expression.length - 1) +
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(19.0),
              alignment: Alignment.bottomRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      double targetFontSize = 88.0;
                      final textStyle = TextStyle(
                          fontSize: targetFontSize, fontWeight: FontWeight.w300);
                      final textPainter = TextPainter(
                        text: TextSpan(text: _expression, style: textStyle),
                        textDirection: TextDirection.ltr,
                      );
                      textPainter.layout();

                      if (textPainter.width > constraints.maxWidth) {
                        targetFontSize =
                            (constraints.maxWidth / textPainter.width) *
                                targetFontSize;
                        if (!_isFinalResult && targetFontSize < 52.0) {
                          targetFontSize = 52.0;
                        }
                      }

                      if (targetFontSize != _fontSize) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _fontSize = targetFontSize;
                            });
                          }
                        });
                      }

                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: _fontSize, end: _fontSize),
                        duration: const Duration(milliseconds: 150),
                        builder: (context, animatedFontSize, child) {
                          Widget textDisplayWidget = RichText(
                            key: ValueKey(_expression),
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: animatedFontSize,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                              children: [
                                TextSpan(
                                  text: _expression.substring(
                                      0, _cursorPosition),
                                ),
                                if (!_isFinalResult)
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Container(
                                      width: 2.0,
                                      height: animatedFontSize * 0.8,
                                      color: _isCursorVisible
                                          ? Colors.orange
                                          : Colors.transparent,
                                    ),
                                  ),
                                TextSpan(
                                  text:
                                      _expression.substring(_cursorPosition),
                                ),
                              ],
                            ),
                          );

                          if (!_isFinalResult) {
                            textDisplayWidget = SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              reverse: true,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0),
                              child: textDisplayWidget,
                            );
                          }

                          return GestureDetector(
                            onTapUp: (details) {
                              if (_isFinalResult) return;
                              final textSpan = TextSpan(
                                  text: _expression,
                                  style: TextStyle(fontSize: animatedFontSize));
                              final textPainter = TextPainter(
                                  text: textSpan,
                                  textDirection: TextDirection.ltr);
                              textPainter.layout();
                              final position = textPainter
                                  .getPositionForOffset(details.localPosition);
                              setState(() {
                                _cursorPosition = position.offset;
                              });
                            },
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: textDisplayWidget,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  if (_realTimeOutput.isNotEmpty &&
                      _realTimeOutput != _expression)
                    LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        String textToDisplay = _realTimeOutput;
                        final style = const TextStyle(
                          fontSize: 34.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        );

                        final textPainter = TextPainter(
                          text: TextSpan(text: textToDisplay, style: style),
                          maxLines: 1,
                          textDirection: TextDirection.ltr,
                        );
                        textPainter.layout();

                        if (textPainter.width > constraints.maxWidth / 2) {
                          try {
                            final number = double.parse(_realTimeOutput);
                            textToDisplay = number.toStringAsExponential(6);
                          } catch (e) {
                            textToDisplay = _realTimeOutput;
                          }
                        }

                        return Text(
                          textToDisplay,
                          style: style,
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    CalculatorButton(value: "AC", color: const Color(0xFFA5A5A5), textColor: Colors.black, onPressed: () => _buttonPressed("AC")),
                    CalculatorButton(value: "⌫", color: const Color(0xFFA5A5A5), textColor: Colors.black, onPressed: () => _buttonPressed("⌫")),
                    CalculatorButton(value: "%", color: const Color(0xFFA5A5A5), textColor: Colors.black, onPressed: () => _buttonPressed("%")),
                    CalculatorButton(value: "÷", color: const Color(0xFFFF9500), textColor: Colors.white, onPressed: () => _buttonPressed("÷")),
                  ],
                ),
                Row(
                  children: <Widget>[
                    CalculatorButton(value: "7", color: const Color(0xFF333333), textColor: Colors.white, onPressed: () => _buttonPressed("7")),
                    CalculatorButton(value: "8", color: const Color(0xFF333333), textColor: Colors.white, onPressed: () => _buttonPressed("8")),
                    CalculatorButton(value: "9", color: const Color(0xFF333333), textColor: Colors.white, onPressed: () => _buttonPressed("9")),
                    CalculatorButton(value: "×", color: const Color(0xFFFF9500), textColor: Colors.white, onPressed: () => _buttonPressed("×")),
                  ],
                ),
                Row(
                  children: <Widget>[
                    CalculatorButton(value: "4", color: const Color(0xFF333333), textColor: Colors.white, onPressed: () => _buttonPressed("4")),
                    CalculatorButton(value: "5", color: const Color(0xFF333333), textColor: Colors.white, onPressed: () => _buttonPressed("5")),
                    CalculatorButton(value: "6", color: const Color(0xFF333333), textColor: Colors.white, onPressed: () => _buttonPressed("6")),
                    CalculatorButton(value: "-", color: const Color(0xFFFF9500), textColor: Colors.white, onPressed: () => _buttonPressed("-")),
                  ],
                ),
                Row(
                  children: <Widget>[
                    CalculatorButton(value: "1", color: const Color(0xFF333333), textColor: Colors.white, onPressed: () => _buttonPressed("1")),
                    CalculatorButton(value: "2", color: const Color(0xFF333333), textColor: Colors.white, onPressed: () => _buttonPressed("2")),
                    CalculatorButton(value: "3", color: const Color(0xFF333333), textColor: Colors.white, onPressed: () => _buttonPressed("3")),
                    CalculatorButton(value: "+", color: const Color(0xFFFF9500), textColor: Colors.white, onPressed: () => _buttonPressed("+")),
                  ],
                ),
                Row(
                  children: <Widget>[
                    CalculatorButton(value: "calculator", color: const Color(0xFF333333), textColor: Colors.white, onPressed: () {}, child: const Icon(Icons.calculate, size: 34.0)),
                    CalculatorButton(value: "0", color: const Color(0xFF333333), textColor: Colors.white, onPressed: () => _buttonPressed("0")),
                    CalculatorButton(value: ".", color: const Color(0xFF333333), textColor: Colors.white, onPressed: () => _buttonPressed(".")),
                    CalculatorButton(value: "=", color: const Color(0xFFFF9500), textColor: Colors.white, onPressed: () => _buttonPressed("=")),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
