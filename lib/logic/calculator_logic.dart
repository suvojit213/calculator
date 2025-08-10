
int getPrecedence(String operator) {
  switch (operator) {
    case "+":
    case "-":
      return 1;
    case "×":
    case "÷":
      return 2;
    case "%":
      return 3;
    default:
      return 0;
  }
}

double applyOperation(double b, double a, String operator) {
  switch (operator) {
    case "+":
      return a + b;
    case "-":
      return a - b;
    case "×":
      return a * b;
    case "÷":
      if (b == 0) {
        throw Exception("Division by zero");
      }
      return a / b;
    default:
      return 0;
  }
}

String calculateFinalResult(String expression) {
  try {
    if (expression.isEmpty) {
      return "";
    }

    List<String> tokens = [];
    String currentNumber = "";

    for (int i = 0; i < expression.length; i++) {
      String char = expression[i];
      if ("0123456789.".contains(char)) {
        currentNumber += char;
      } else {
        if (currentNumber.isNotEmpty) {
          tokens.add(currentNumber);
          currentNumber = "";
        }
        tokens.add(char);
      }
    }
    if (currentNumber.isNotEmpty) {
      tokens.add(currentNumber);
    }

    List<double> values = [];
    List<String> ops = [];

    for (int i = 0; i < tokens.length; i++) {
      String token = tokens[i];
      if (double.tryParse(token) != null) {
        values.add(double.parse(token));
      } else if (token == "%") {
        double lastValue = values.removeLast();
        values.add(lastValue / 100);
      } else {
        while (ops.isNotEmpty && getPrecedence(ops.last) >= getPrecedence(token)) {
          double output = applyOperation(values.removeLast(), values.removeLast(), ops.removeLast());
          values.add(output);
        }
        ops.add(token);
      }
    }

    while (ops.isNotEmpty) {
      double output = applyOperation(values.removeLast(), values.removeLast(), ops.removeLast());
      values.add(output);
    }

    String result = values.single.toString();
    if (result.endsWith(".0")) {
      result = result.substring(0, result.length - 2);
    }
    return result;
  } catch (e) {
    return "Error";
  }
}

String calculateRealTimeResult(String expression) {
  try {
    expression = expression.trim();
    if (expression.isEmpty) {
      return "";
    }

    String lastChar = expression.substring(expression.length - 1);
    if ("+-×÷".contains(lastChar)) {
      return "";
    }

    return calculateFinalResult(expression);
  } catch (e) {
    return ""; // Return empty string in case of intermediate errors
  }
}
