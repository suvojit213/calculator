import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData.dark(),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _output = '0';
  String _currentInput = '';
  double _num1 = 0;
  String _operator = '';
  bool _isScientific = true;

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'AC') {
        _output = '0';
        _currentInput = '';
        _num1 = 0;
        _operator = '';
      } else if (buttonText == '+' ||
          buttonText == '-' ||
          buttonText == 'x' ||
          buttonText == '÷') {
        if (_currentInput.isNotEmpty) {
          _num1 = double.parse(_currentInput);
          _operator = buttonText;
          _currentInput = '';
        }
      } else if (buttonText == '=') {
        if (_currentInput.isNotEmpty && _operator.isNotEmpty) {
          double num2 = double.parse(_currentInput);
          double result = 0;
          if (_operator == '+') {
            result = _num1 + num2;
          } else if (_operator == '-') {
            result = _num1 - num2;
          } else if (_operator == 'x') {
            result = _num1 * num2;
          } else if (_operator == '÷') {
            result = _num1 / num2;
          }
          _output = result.toString();
          _num1 = result;
          _currentInput = '';
          _operator = '';
        }
      } else if (buttonText == '.') {
        if (!_currentInput.contains('.')) {
          _currentInput += buttonText;
          _output = _currentInput;
        }
      } else if (
          buttonText == '(' || buttonText == ')' ||
          buttonText == 'mc' || buttonText == 'm+' || buttonText == 'm-' || buttonText == 'mr' ||
          buttonText == '2nd' || buttonText == 'x²' || buttonText == 'x³' || buttonText == 'xʸ' || buttonText == 'eˣ' || buttonText == '10ˣ' ||
          buttonText == '¹/ₓ' || buttonText == '²√x' || buttonText == '³√x' || buttonText == 'ʸ√x' || buttonText == 'ln' || buttonText == 'log₁₀' ||
          buttonText == 'x!' || buttonText == 'sin' || buttonText == 'cos' || buttonText == 'tan' || buttonText == 'e' || buttonText == 'EE' ||
          buttonText == 'Rand' || buttonText == 'sinh' || buttonText == 'cosh' || buttonText == 'tanh' || buttonText == 'π' || buttonText == 'Deg' ||
          buttonText == '+/-' || buttonText == '%'
      ) {
        // TODO: Implement scientific functions
        print('Pressed: $buttonText');
      }
      else {
        if (_currentInput == '0') {
          _currentInput = buttonText;
        } else {
          _currentInput += buttonText;
        }
        _output = _currentInput;
      }
    });
  }

  Widget _buildButton(String buttonText, {Color? color, Color? textColor, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () => _buttonPressed(buttonText),
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey[850],
            foregroundColor: textColor ?? Colors.white,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
  
  Widget _buildIconButton({required IconData icon, VoidCallback? onPressed, Color? color, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey[850],
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        title: const Text(''),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      drawer: const Drawer(),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Rad',
                    style: TextStyle(color: Colors.grey, fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Text(
                      _output,
                      style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w300, color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),
            _buildScientificCalculatorPad(),
          ],
        ),
      ),
    );
  }

  Widget _buildScientificCalculatorPad() {
    return Column(
      children: [
        Row(
          children: <Widget>[
            _buildButton('(', color: Colors.grey[800]),
            _buildButton(')', color: Colors.grey[800]),
            _buildButton('mc', color: Colors.grey[800]),
            _buildButton('m+', color: Colors.grey[800]),
            _buildButton('m-', color: Colors.grey[800]),
            _buildButton('mr', color: Colors.grey[800]),
          ],
        ),
        Row(
          children: <Widget>[
            _buildButton('2nd', color: Colors.grey[800]),
            _buildButton('x²', color: Colors.grey[800]),
            _buildButton('x³', color: Colors.grey[800]),
            _buildButton('xʸ', color: Colors.grey[800]),
            _buildButton('eˣ', color: Colors.grey[800]),
            _buildButton('10ˣ', color: Colors.grey[800]),
          ],
        ),
        Row(
          children: <Widget>[
            _buildButton('¹/ₓ', color: Colors.grey[800]),
            _buildButton('²√x', color: Colors.grey[800]),
            _buildButton('³√x', color: Colors.grey[800]),
            _buildButton('ʸ√x', color: Colors.grey[800]),
            _buildButton('ln', color: Colors.grey[800]),
            _buildButton('log₁₀', color: Colors.grey[800]),
          ],
        ),
        Row(
          children: <Widget>[
            _buildButton('x!', color: Colors.grey[800]),
            _buildButton('sin', color: Colors.grey[800]),
            _buildButton('cos', color: Colors.grey[800]),
            _buildButton('tan', color: Colors.grey[800]),
            _buildButton('e', color: Colors.grey[800]),
            _buildButton('EE', color: Colors.grey[800]),
          ],
        ),
        Row(
          children: <Widget>[
            _buildButton('Rand', color: Colors.grey[800]),
            _buildButton('sinh', color: Colors.grey[800]),
            _buildButton('cosh', color: Colors.grey[800]),
            _buildButton('tanh', color: Colors.grey[800]),
            _buildButton('π', color: Colors.grey[800]),
            _buildButton('Deg', color: Colors.grey[800]),
          ],
        ),
        Row(
          children: <Widget>[
            _buildButton('AC', color: Colors.grey, textColor: Colors.black),
            _buildButton('+/-', color: Colors.grey, textColor: Colors.black),
            _buildButton('%', color: Colors.grey, textColor: Colors.black),
            _buildButton('÷', color: Colors.orange),
          ],
        ),
        Row(
          children: <Widget>[
            _buildButton('7'),
            _buildButton('8'),
            _buildButton('9'),
            _buildButton('x', color: Colors.orange),
          ],
        ),
        Row(
          children: <Widget>[
            _buildButton('4'),
            _buildButton('5'),
            _buildButton('6'),
            _buildButton('-', color: Colors.orange),
          ],
        ),
        Row(
          children: <Widget>[
            _buildButton('1'),
            _buildButton('2'),
            _buildButton('3'),
            _buildButton('+', color: Colors.orange),
          ],
        ),
        Row(
          children: <Widget>[
            _buildIconButton(icon: Icons.apps, onPressed: () {
                print('Icon button pressed');
            }),
            _buildButton('0'),
            _buildButton('.'),
            _buildButton('=', color: Colors.orange),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}