import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(const CalculatorApp());
}

String _calculateFinalResult(String expression) {
  try {
    String finalExpression = expression.replaceAll("×", "*").replaceAll("÷", "/");
    while (finalExpression.isNotEmpty &&
        "+-*/".contains(finalExpression.substring(finalExpression.length - 1))) {
      finalExpression =
          finalExpression.substring(0, finalExpression.length - 1);
    }

    if (finalExpression.isEmpty) {
      return "";
    }

    List<String> parts = finalExpression.split(RegExp(r'[+\-*/]'));
    List<String> operators =
        finalExpression.replaceAll(RegExp(r'[0-9.]'), '').split('');

    if (parts.isNotEmpty) {
      double result = double.parse(parts[0]);
      for (int i = 0; i < operators.length; i++) {
        double nextNum = double.parse(parts[i + 1]);
        switch (operators[i]) {
          case "+":
            result += nextNum;
            break;
          case "-":
            result -= nextNum;
            break;
          case "*":
            result *= nextNum;
            break;
          case "/":
            if (nextNum != 0) {
              result /= nextNum;
            } else {
              return "Error";
            }
            break;
        }
      }
      String output = result.toString();
      if (output.endsWith(".0")) {
        output = output.substring(0, output.length - 2);
      }
      return output;
    }
    return "";
  } catch (e) {
    return "Error";
  }
}

String _calculateRealTimeResult(String expression) {
  try {
    String finalExpression = expression
        .replaceAll("×", "*")
        .replaceAll("÷", "/")
        .replaceAll("%", "/100");
    if (finalExpression.isNotEmpty &&
        !'+-*/'.contains(finalExpression.substring(finalExpression.length - 1)) &&
        finalExpression.contains(RegExp(r'[+\-*/]'))) {
      List<String> parts = finalExpression.split(RegExp(r'[+\-*/]'));
      List<String> operators =
          finalExpression.replaceAll(RegExp(r'[0-9.]'), '').split('');

      if (parts.length > 1) {
        double result = double.parse(parts[0]);
        for (int i = 0; i < operators.length; i++) {
          if (operators[i] == "/100") {
            result /= 100;
            continue;
          }
          if (parts[i + 1].isEmpty) continue;
          double nextNum = double.parse(parts[i + 1]);
          switch (operators[i]) {
            case "+":
              result += nextNum;
              break;
            case "-":
              result -= nextNum;
              break;
            case "*":
              result *= nextNum;
              break;
            case "/":
              if (nextNum != 0) {
                result /= nextNum;
              } else {
                return "Error";
              }
              break;
          }
        }
        String resultString = result.toString();
        if (resultString.endsWith(".0")) {
          resultString = resultString.substring(0, resultString.length - 2);
        }
        return resultString;
      }
    }
    return "";
  } catch (e) {
    return "Error";
  }
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Helvetica Neue',
      ),
      home: const CalculatorHomePage(),
    );
  }
}

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
  String _pressedButton = "";
  bool _isVibrationEnabled = true;

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
    final result = await compute(_calculateRealTimeResult, _expression);
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
      setState(() {
        _pressedButton = buttonText;
      });
      if (_isVibrationEnabled) {
        Vibration.vibrate(duration: 50);
      }
      
      setState(() {
        _pressedButton = "";
      });

      if (buttonText == "=") {
        if (_expression.isNotEmpty && !_isFinalResult) {
          final expressionToCalculate = _expression;
          setState(() {
            _isFinalResult = true;
            _realTimeOutput = "";
          });

          final result =
              await compute(_calculateFinalResult, expressionToCalculate);

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

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Settings"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SwitchListTile(
                title: const Text("Vibration"),
                value: _isVibrationEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _isVibrationEnabled = value;
                  });
                },
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Done"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton(String buttonValue,
      {bool isOperator = false, Widget? child}) {
    bool isPressed = _pressedButton == buttonValue;
    double scale = isPressed ? 0.85 : 1.0;
    Matrix4 transform =
        isPressed ? (Matrix4.identity()..scale(scale)) : Matrix4.identity();

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: transform,
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(4, 4),
              ),
            ],
            borderRadius: BorderRadius.circular(50),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  gradient: isOperator
                      ? const LinearGradient(
                          colors: [Color(0xFFFF9500), Color(0xFFFFB900)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [
                            const Color(0xFF333333).withOpacity(0.6),
                            const Color(0xFF1C1C1C).withOpacity(0.6)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () => _buttonPressed(buttonValue),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(19),
                    minimumSize: const Size(78, 78),
                    shadowColor: Colors.transparent,
                  ),
                  child: child ??
                      Text(
                        buttonValue,
                        style: const TextStyle(
                          fontSize: 34.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
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
                    _buildButton("AC"),
                    _buildButton("⌫"),
                    _buildButton("%"),
                    _buildButton("÷", isOperator: true),
                  ],
                ),
                Row(
                  children: <Widget>[
                    _buildButton("7"),
                    _buildButton("8"),
                    _buildButton("9"),
                    _buildButton("×", isOperator: true),
                  ],
                ),
                Row(
                  children: <Widget>[
                    _buildButton("4"),
                    _buildButton("5"),
                    _buildButton("6"),
                    _buildButton("-", isOperator: true),
                  ],
                ),
                Row(
                  children: <Widget>[
                    _buildButton("1"),
                    _buildButton("2"),
                    _buildButton("3"),
                    _buildButton("+", isOperator: true),
                  ],
                ),
                Row(
                  children: <Widget>[
                    _buildButton("0"),
                    _buildButton("."),
                    _buildButton("=", isOperator: true),
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
