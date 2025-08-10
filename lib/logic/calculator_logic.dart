String calculateFinalResult(String expression) {
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

String calculateRealTimeResult(String expression) {
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
