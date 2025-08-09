import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
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

  void _updateRealTimeOutput() {
    try {
      String finalExpression = _expression.replaceAll("×", "*").replaceAll("÷", "/").replaceAll("%", "/100");
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
                  _realTimeOutput = "Error";
                  return;
                }
                break;
            }
          }
          String resultString = result.toString();
          if (resultString.endsWith(".0")) {
            resultString = resultString.substring(0, resultString.length - 2);
          }
          _realTimeOutput = resultString;
        } else {
          _realTimeOutput = "";
        }
      } else {
        _realTimeOutput = "";
      }
    } catch (e) {
      _realTimeOutput = "Error";
    }
  }

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "AC") {
        _output = "0";
        _expression = "";
        _currentNumber = "";
        _num1 = 0.0;
        _operand = "";
        _isNewNumber = true;
        _cursorPosition = 0;
      } else if (buttonText == "C") {
        _output = "0";
        _expression = "";
        _currentNumber = "";
        _isNewNumber = true;
        _cursorPosition = 0;
      } else if (buttonText == "⌫") {
        if (_cursorPosition > 0) {
          _expression = _expression.substring(0, _cursorPosition - 1) +
              _expression.substring(_cursorPosition);
          _cursorPosition--;
        }
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
          _updateRealTimeOutput();
        }
      } else if (buttonText == ".") {
        if (!_currentNumber.contains(".")) {
          if (_isNewNumber) {
            _currentNumber = "0.";
            _isNewNumber = false;
            _expression = "0.";
          } else {
            _currentNumber += ".";
            _expression += ".";
          }
          _output = _currentNumber;
        }
      } else if (buttonText == "=") {
        try {
          String finalExpression = _expression.replaceAll("×", "*").replaceAll("÷", "/");
          // Remove trailing operators
          while (finalExpression.isNotEmpty && "+-*/".contains(finalExpression.substring(finalExpression.length - 1))) {
            finalExpression = finalExpression.substring(0, finalExpression.length - 1);
          }

          if (finalExpression.isEmpty) {
            _output = _currentNumber.isNotEmpty ? _currentNumber : "0";
            _expression = _output;
            _currentNumber = _output;
            _operand = "";
            _isNewNumber = true;
            _cursorPosition = _expression.length;
            return;
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
                    _output = "Error";
                    _expression = "Error";
                    _num1 = 0.0;
                    _currentNumber = "";
                    _operand = "";
                    _isNewNumber = true;
                    return;
                  }
                  break;
              }
            }
            _output = result.toString();
            if (_output.endsWith(".0")) {
              _output = _output.substring(0, _output.length - 2);
            }
            _expression = _output;
            _currentNumber = _output;
            _operand = "";
            _isNewNumber = true;
            _cursorPosition = _expression.length;
          }
        } catch (e) {
          _output = "Error";
          _expression = "Error";
          _num1 = 0.0;
          _currentNumber = "";
          _operand = "";
          _isNewNumber = true;
          _cursorPosition = _expression.length;
        }
      } else if (buttonText == "+" ||
          buttonText == "-" ||
          buttonText == "×" ||
          buttonText == "÷") {
        if (_expression.isNotEmpty) {
          if (_expression.endsWith("+") ||
              _expression.endsWith("-") ||
              _expression.endsWith("×") ||
              _expression.endsWith("÷")) {
            _expression = _expression.substring(0, _expression.length - 1) + buttonText;
          } else {
            _expression += buttonText;
          }
        } else if (_currentNumber.isNotEmpty) {
          _expression = _currentNumber + buttonText;
        } else {
          _expression = _output + buttonText;
        }

        _num1 = double.parse(_output);
        _operand = buttonText;
        _isNewNumber = true;
        _currentNumber = "";
        _selectedOperator = buttonText;
        _cursorPosition = _expression.length;
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
        _cursorPosition++;
        _output = _currentNumber;
        _selectedOperator = "";
      }
    });
    _updateRealTimeOutput();
  }

  Widget _buildButton(String buttonValue, Color buttonColor, Color textColor,
      {Widget? child}) {
    Color currentButtonColor = buttonColor;
    Color currentTextColor = textColor;

    if (buttonValue == _selectedOperator) {
      currentButtonColor = textColor;
      currentTextColor = buttonColor;
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(7.5),
        child: ElevatedButton(
          onPressed: () => _buttonPressed(buttonValue),
          style: ElevatedButton.styleFrom(
            backgroundColor: currentButtonColor,
            foregroundColor: currentTextColor,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(19),
            minimumSize: const Size(78, 78),
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
    );
  }

  Widget _buildZeroButton(String buttonValue, Color buttonColor, Color textColor,
      {Widget? child}) {
    return Expanded(
      flex: 2,
      child: Container(
        margin: const EdgeInsets.all(7.5),
        child: ElevatedButton(
          onPressed: () => _buttonPressed(buttonValue),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(49.0),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 29, vertical: 19),
            minimumSize: const Size(168, 78),
          ),
          child: child ??
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  buttonValue,
                  style: const TextStyle(
                    fontSize: 34.0,
                    fontWeight: FontWeight.w500,
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
                    builder: (BuildContext context, BoxConstraints constraints) {
                      double fontSize = 88.0;
                      final textStyle = TextStyle(fontSize: fontSize, fontWeight: FontWeight.w300);
                      final textPainter = TextPainter(
                        text: TextSpan(text: _expression, style: textStyle),
                        textDirection: TextDirection.ltr,
                      );
                      textPainter.layout();

                      if (textPainter.width > constraints.maxWidth) {
                        fontSize = (constraints.maxWidth / textPainter.width) * fontSize;
                        if (fontSize < 34.0) {
                          fontSize = 34.0;
                        }
                      }

                      return GestureDetector(
                        onTapUp: (details) {
                          final textSpan =
                              TextSpan(text: _expression, style: TextStyle(fontSize: fontSize));
                          final textPainter = TextPainter(
                              text: textSpan, textDirection: TextDirection.ltr);
                          textPainter.layout();
                          final position =
                              textPainter.getPositionForOffset(details.localPosition);
                          setState(() {
                            _cursorPosition = position.offset;
                          });
                        },
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                              children: [
                                TextSpan(
                                  text: _expression.substring(0, _cursorPosition),
                                ),
                                TextSpan(
                                  text: "|",
                                  style: TextStyle(color: _isCursorVisible ? Colors.orange : Colors.transparent),
                                ),
                                TextSpan(
                                  text: _expression.substring(_cursorPosition),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (_realTimeOutput.isNotEmpty && _realTimeOutput != _expression)
                    LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        String textToDisplay = _realTimeOutput;
                        final style = const TextStyle(
                          fontSize: 34.0,
                          fontWeight: FontWeight.w300,
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
                    _buildButton("AC", const Color(0xFFA5A5A5), Colors.black),
                    _buildButton("⌫", const Color(0xFFA5A5A5), Colors.black),
                    _buildButton("%", const Color(0xFFA5A5A5), Colors.black),
                    _buildButton("÷", const Color(0xFFFF9500), Colors.white),
                  ],
                ),
                Row(
                  children: <Widget>[
                    _buildButton("7", const Color(0xFF333333), Colors.white),
                    _buildButton("8", const Color(0xFF333333), Colors.white),
                    _buildButton("9", const Color(0xFF333333), Colors.white),
                    _buildButton("×", const Color(0xFFFF9500), Colors.white),
                  ],
                ),
                Row(
                  children: <Widget>[
                    _buildButton("4", const Color(0xFF333333), Colors.white),
                    _buildButton("5", const Color(0xFF333333), Colors.white),
                    _buildButton("6", const Color(0xFF333333), Colors.white),
                    _buildButton("-", const Color(0xFFFF9500), Colors.white),
                  ],
                ),
                Row(
                  children: <Widget>[
                    _buildButton("1", const Color(0xFF333333), Colors.white),
                    _buildButton("2", const Color(0xFF333333), Colors.white),
                    _buildButton("3", const Color(0xFF333333), Colors.white),
                    _buildButton("+", const Color(0xFFFF9500), Colors.white),
                  ],
                ),
                Row(
                  children: <Widget>[
                    _buildZeroButton("0", const Color(0xFF333333), Colors.white),
                    _buildButton(".", const Color(0xFF333333), Colors.white),
                    _buildButton("=", const Color(0xFFFF9500), Colors.white),
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