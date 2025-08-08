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
        brightness: Brightness.dark, // Dark theme for iOS-like calculator
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Helvetica Neue', // A common iOS-like font
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
  String _output = "0"; // This will hold the result of the calculation
  String _expression = ""; // This will hold the full expression
  String _currentNumber = "";
  double _num1 = 0.0;
  String _operand = "";
  bool _isNewNumber = true;
  String _selectedOperator = ""; // New state variable for selected operator
  bool _isEditing = false;
  int _cursorPosition = 0;

  void _buttonPressed(String buttonText) {
    setState(() {
      _selectedOperator = ""; // Clear selected operator by default
    });

    if (buttonText == "AC") {
      _output = "0";
      _expression = "";
      _currentNumber = "";
      _num1 = 0.0;
      _operand = "";
      _isNewNumber = true;
    } else if (buttonText == "C") {
      _output = "0";
      _expression = ""; // Clear expression on 'C'
      _currentNumber = "";
      _isNewNumber = true;
    } else if (buttonText == "⌫") {
      if (_isEditing) {
        if (_cursorPosition > 0) {
          setState(() {
            _expression = _expression.substring(0, _cursorPosition - 1) + _expression.substring(_cursorPosition);
            _cursorPosition--;
          });
        }
      } else {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          if (_currentNumber.isNotEmpty) {
            _currentNumber = _currentNumber.substring(0, _currentNumber.length - 1);
            _output = _currentNumber;
          }
        }
      }
    } else if (buttonText == "+/-") {
      if (_currentNumber.isNotEmpty && _currentNumber != "0") {
        if (_currentNumber.startsWith("-")) {
          _currentNumber = _currentNumber.substring(1);
        } else {
          _currentNumber = "-" + _currentNumber;
        }
        // Update expression with the new signed number
        // This part needs to be smarter to replace the correct number in the expression
        // For now, a simple replacement might not be accurate if the number appears multiple times
        _expression = _expression.replaceFirst(RegExp(r'\b' + _currentNumber.replaceAll("-", "") + r'\b'), _currentNumber); // Basic replacement
        _output = _currentNumber;
      }
    } else if (buttonText == "%") {
      if (_currentNumber.isNotEmpty) {
        double value = double.parse(_currentNumber);
        _currentNumber = (value / 100).toString();
        // Update expression with the percentage
        _expression = _expression.replaceFirst(RegExp(r'\b' + (value * 100).toString() + r'\b'), _currentNumber); // Basic replacement
        _output = _currentNumber;
      }
    } else if (buttonText == ".") {
      if (!_currentNumber.contains(".")) {
        if (_isNewNumber) {
          _currentNumber = "0.";
          _isNewNumber = false;
          _expression = "0."; // Start expression with "0."
        } else {
          _currentNumber += ".";
          _expression += "."; // Append to expression
        }
        _output = _currentNumber;
      }
    } else if (buttonText == "=") {
      try {
        // Replace × with * and ÷ with / for evaluation
        String finalExpression = _expression.replaceAll("×", "*").replaceAll("÷", "/");
        // Evaluate the expression (simple approach, consider a math expression parser for complex cases)
        // This is a very basic evaluation and might not handle operator precedence correctly.
        // For a robust solution, a proper expression parser library should be used.
        List<String> parts = finalExpression.split(RegExp(r'[+\-*/]'));
        List<String> operators = finalExpression.replaceAll(RegExp(r'[0-9.]'), '').split('');

        if (parts.length > 0) {
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
          _expression = _output; // After '=', expression becomes the result
          _currentNumber = _output;
          _operand = "";
          _isNewNumber = true;
        }
      } catch (e) {
        _output = "Error";
        _expression = "Error";
        _num1 = 0.0;
        _currentNumber = "";
        _operand = "";
        _isNewNumber = true;
      }
    } else if (buttonText == "+" || buttonText == "-" || buttonText == "×" || buttonText == "÷") {
      if (_currentNumber.isNotEmpty || _expression.isNotEmpty) {
        if (_isNewNumber && _expression.isNotEmpty && (_expression.endsWith("+") || _expression.endsWith("-") || _expression.endsWith("×") || _expression.endsWith("÷"))) {
          // Replace last operator if a new one is pressed immediately after another operator
          _expression = _expression.substring(0, _expression.length - 1) + buttonText;
        } else if (_currentNumber.isNotEmpty) {
          _expression += buttonText; // Append operator to expression
        }
        _num1 = double.parse(_currentNumber.isEmpty ? _output : _currentNumber); // Use _output if _currentNumber is empty (e.g., after a calculation)
        _operand = buttonText;
        _isNewNumber = true;
        _currentNumber = ""; // Clear current number after operator
        setState(() {
          _selectedOperator = buttonText; // Set selected operator
        });
      }
    } else {
      if (_isEditing) {
        setState(() {
          _expression = _expression.substring(0, _cursorPosition) + buttonText + _expression.substring(_cursorPosition);
          _cursorPosition++;
        });
      } else {
        if (_isNewNumber) {
          _currentNumber = buttonText;
          if (_expression.isEmpty || _expression == _output) { // If starting a new calculation or after '=' pressed
            _expression = buttonText; // Start new expression
          } else if (_expression.endsWith("+") || _expression.endsWith("-") || _expression.endsWith("×") || _expression.endsWith("÷")) {
            _expression += buttonText; // Append to expression after an operator
          } else {
            _expression = buttonText; // Overwrite if not an operator or empty
          }
          _isNewNumber = false;
        } else {
          _currentNumber += buttonText;
          _expression += buttonText; // Append to expression
        }
        _output = _currentNumber;
      }
    }

    setState(() {
      // No longer limiting _output length here, as _expression is the primary display
      // If _expression gets too long, consider using a FittedBox or scrolling text
    });
  }

  Widget _buildButton(String buttonValue, Color buttonColor, Color textColor, {Widget? child}) {
    Color currentButtonColor = buttonColor;
    Color currentTextColor = textColor;

    if (buttonValue == _selectedOperator) {
      currentButtonColor = textColor; // Swap colors for highlight
      currentTextColor = buttonColor; // Swap colors for highlight
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(7.5), // Slightly reduced margin
        child: ElevatedButton(
          onPressed: () => _buttonPressed(buttonValue),
          style: ElevatedButton.styleFrom(
            backgroundColor: currentButtonColor,
            foregroundColor: currentTextColor,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(19), // Slightly reduced padding
            minimumSize: const Size(78, 78), // Slightly smaller buttons
          ),
          child: child ?? Text(
            buttonValue,
            style: const TextStyle(
              fontSize: 34.0, // Slightly smaller font for buttons
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZeroButton(String buttonValue, Color buttonColor, Color textColor, {Widget? child}) {
    return Expanded(
      flex: 2,
      child: Container(
        margin: const EdgeInsets.all(7.5), // Slightly reduced margin
        child: ElevatedButton(
          onPressed: () => _buttonPressed(buttonValue),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(49.0), // Adjusted for smaller size
            ),
            padding: const EdgeInsets.symmetric(horizontal: 29, vertical: 19), // Slightly reduced padding
            minimumSize: const Size(168, 78), // Adjusted for smaller size
          ),
          child: child ?? Align(
            alignment: Alignment.centerLeft,
            child: Text(
              buttonValue,
              style: const TextStyle(
                fontSize: 34.0, // Slightly smaller font for buttons
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
              padding: const EdgeInsets.all(19.0), // Slightly reduced padding
              alignment: Alignment.bottomRight,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300), // Animation duration
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    if (_expression.isEmpty) {
                      // Display _output (the result) in a fixed, smaller size
                      return Text(
                        _output,
                        key: ValueKey<String>(_output), // Key for AnimatedSwitcher
                        style: const TextStyle(
                          fontSize: 49.0, // Fixed smaller size for the result
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      );
                    } else {
                      // Display _expression with dynamic sizing and scrolling
                      double fontSize = 88.0; // Adjusted initial font size
                      if (_expression.length > 10 && _expression.length <= 15) {
                        fontSize = 68.0;
                      } else if (_expression.length > 15 && _expression.length <= 20) {
                        fontSize = 49.0;
                      } else if (_expression.length > 20) {
                        fontSize = 39.0;
                      }

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _isEditing = !_isEditing;
                            _cursorPosition = _expression.length;
                          });
                        },
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true, // Show the end of the expression by default
                          child: RichText(
                            key: ValueKey<String>(_expression), // Key for AnimatedSwitcher
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                              children: _isEditing
                                  ? [
                                      TextSpan(
                                        text: _expression.substring(0, _cursorPosition),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            setState(() {
                                              _isEditing = false;
                                            });
                                          },
                                      ),
                                      TextSpan(
                                        text: "|",
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                      TextSpan(
                                        text: _expression.substring(_cursorPosition),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            setState(() {
                                              _isEditing = false;
                                            });
                                          },
                                      ),
                                    ]
                                  : [
                                      TextSpan(
                                        text: _expression,
                                        recognizer: TapGestureRecognizer()
                                          ..onTapDown = (details) {
                                            final textSpan = TextSpan(text: _expression, style: TextStyle(fontSize: fontSize));
                                            final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
                                            textPainter.layout();
                                            final position = textPainter.getPositionForOffset(details.localPosition);
                                            setState(() {
                                              _cursorPosition = position.offset;
                                            });
                                          },
                                      ),
                                    ],
                            ),
                          ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0), // Adjusted bottom padding for navigation bar
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    _buildButton("AC", const Color(0xFFA5A5A5), Colors.black),
                    _buildButton("⌫", const Color(0xFFA5A5A5), Colors.black),
                    _buildButton("%", const Color(0xFFA5A5A5), Colors.black),
                    _buildButton("÷", const Color(0xFFF1A33B), Colors.white),
                  ],
                ),
                Row(
                  children: <Widget>[
                    _buildButton("7", const Color(0xFF333333), Colors.white),
                    _buildButton("8", const Color(0xFF333333), Colors.white),
                    _buildButton("9", const Color(0xFF333333), Colors.white),
                    _buildButton("×", const Color(0xFFF1A33B), Colors.white),
                  ],
                ),
                Row(
                  children: <Widget>[
                    _buildButton("4", const Color(0xFF333333), Colors.white),
                    _buildButton("5", const Color(0xFF333333), Colors.white),
                    _buildButton("6", const Color(0xFF333333), Colors.white),
                    _buildButton("-", const Color(0xFFF1A33B), Colors.white),
                  ],
                ),
                Row(
                  children: <Widget>[
                    _buildButton("1", const Color(0xFF333333), Colors.white),
                    _buildButton("2", const Color(0xFF333333), Colors.white),
                    _buildButton("3", const Color(0xFF333333), Colors.white),
                    _buildButton("+", const Color(0xFFF1A33B), Colors.white),
                  ],
                ),
                Row(
                  children: <Widget>[
                    _buildZeroButton("0", const Color(0xFF333333), Colors.white),
                    _buildButton(".", const Color(0xFF333333), Colors.white),
                    _buildButton("=", const Color(0xFFF1A33B), Colors.white),
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
