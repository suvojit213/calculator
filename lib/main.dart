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
  String _output = "0";
  String _currentNumber = "";
  double _num1 = 0.0;
  String _operand = "";
  bool _isNewNumber = true;
  String _selectedOperator = ""; // New state variable for selected operator

  void _buttonPressed(String buttonText) {
    setState(() {
      _selectedOperator = ""; // Clear selected operator by default
    });
    if (buttonText == "AC") {
      _output = "0";
      _currentNumber = "";
      _num1 = 0.0;
      _operand = "";
      _isNewNumber = true;
    } else if (buttonText == "C") {
      _output = "0";
      _currentNumber = "";
      _isNewNumber = true;
    } else if (buttonText == "+/-") {
      if (_currentNumber.isNotEmpty && _currentNumber != "0") {
        if (_currentNumber.startsWith("-")) {
          _currentNumber = _currentNumber.substring(1);
        } else {
          _currentNumber = "-$_currentNumber";
        }
        _output = _currentNumber;
      }
    } else if (buttonText == "%") {
      if (_currentNumber.isNotEmpty) {
        double value = double.parse(_currentNumber);
        _currentNumber = (value / 100).toString();
        _output = _currentNumber;
      }
    } else if (buttonText == ".") {
      if (!_currentNumber.contains(".")) {
        if (_isNewNumber) {
          _currentNumber = "0.";
          _isNewNumber = false;
        } else {
          _currentNumber += ".";
        }
        _output = _currentNumber;
      }
    } else if (buttonText == "=") {
      if (_operand.isNotEmpty && _currentNumber.isNotEmpty) {
        double num2 = double.parse(_currentNumber);
        switch (_operand) {
          case "+":
            _num1 += num2;
            break;
          case "-":
            _num1 -= num2;
            break;
          case "×":
            _num1 *= num2;
            break;
          case "÷":
            if (num2 != 0) {
              _num1 /= num2;
            } else {
              _output = "Error";
              _num1 = 0.0;
              _currentNumber = "";
              _operand = "";
              _isNewNumber = true;
              return;
            }
            break;
        }
        _output = _num1.toString();
        if (_output.endsWith(".0")) {
          _output = _output.substring(0, _output.length - 2);
        }
        _currentNumber = _output;
        _operand = "";
        _isNewNumber = true;
      }
    } else if (buttonText == "+" || buttonText == "-" || buttonText == "×" || buttonText == "÷") {
      if (_currentNumber.isNotEmpty) {
        _num1 = double.parse(_currentNumber);
        _operand = buttonText;
        _isNewNumber = true;
        setState(() {
          _selectedOperator = buttonText; // Set selected operator
        });
      }
    } else {
      if (_isNewNumber) {
        _currentNumber = buttonText;
        _isNewNumber = false;
      } else {
        _currentNumber += buttonText;
      }
      _output = _currentNumber;
    }

    setState(() {
      // Limit output length to prevent overflow
      if (_output.length > 9) {
        _output = double.parse(_output).toStringAsExponential(3);
      }
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
        margin: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () => _buttonPressed(buttonValue),
          style: ElevatedButton.styleFrom(
            backgroundColor: currentButtonColor,
            foregroundColor: currentTextColor,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            minimumSize: const Size(80, 80), // Ensure buttons are circular
          ),
          child: child ?? Text(
            buttonValue,
            style: const TextStyle(
              fontSize: 35.0,
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
        margin: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () => _buttonPressed(buttonValue),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0), // Rounded rectangle for zero
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            minimumSize: const Size(170, 80), // Wider for zero
          ),
          child: child ?? Align(
            alignment: Alignment.centerLeft,
            child: Text(
              buttonValue,
              style: const TextStyle(
                fontSize: 35.0,
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
              padding: const EdgeInsets.all(20.0),
              alignment: Alignment.bottomRight,
              child: Text(
                _output,
                style: const TextStyle(
                  fontSize: 90.0,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: <Widget>[
                  _buildButton("AC", const Color(0xFFA5A5A5), Colors.black, child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("A", style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w500)),
                      Text("C", style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w500)),
                    ],
                  )),
                  _buildButton("+/-", const Color(0xFFA5A5A5), Colors.black, child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("+", style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w500)),
                      Text("-", style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.w500)),
                    ],
                  )),
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
        ],
      ),
    );
  }
}