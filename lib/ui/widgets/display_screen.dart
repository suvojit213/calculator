import 'package:flutter/material.dart';

class DisplayScreen extends StatelessWidget {
  final String expression;
  final int cursorPosition;
  final bool isCursorVisible;
  final bool isFinalResult;
  final double fontSize;
  final String realTimeOutput;
  final Function(TapUpDetails) onTapUp;

  const DisplayScreen({
    super.key,
    required this.expression,
    required this.cursorPosition,
    required this.isCursorVisible,
    required this.isFinalResult,
    required this.fontSize,
    required this.realTimeOutput,
    required this.onTapUp,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                double targetFontSize = 88.0;
                final textStyle = TextStyle(
                    fontSize: targetFontSize, fontWeight: FontWeight.w300);
                final textPainter = TextPainter(
                  text: TextSpan(text: expression, style: textStyle),
                  textDirection: TextDirection.ltr,
                );
                textPainter.layout();

                if (textPainter.width > constraints.maxWidth) {
                  targetFontSize =
                      (constraints.maxWidth / textPainter.width) *
                          targetFontSize;
                  if (!isFinalResult && targetFontSize < 52.0) {
                    targetFontSize = 52.0;
                  }
                }

                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: fontSize, end: targetFontSize),
                  duration: const Duration(milliseconds: 150),
                  builder: (context, animatedFontSize, child) {
                    Widget textDisplayWidget = RichText(
                      key: ValueKey(expression),
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: animatedFontSize,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(
                            text: expression.substring(0, cursorPosition),
                          ),
                          if (!isFinalResult)
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Container(
                                width: 2.0,
                                height: animatedFontSize * 0.8,
                                color: isCursorVisible
                                    ? Colors.orange
                                    : Colors.transparent,
                              ),
                            ),
                          TextSpan(
                            text: expression.substring(cursorPosition),
                          ),
                        ],
                      ),
                    );

                    if (!isFinalResult) {
                      textDisplayWidget = SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                        child: textDisplayWidget,
                      );
                    }

                    return GestureDetector(
                      onTapUp: onTapUp,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: textDisplayWidget,
                      ),
                    );
                  },
                );
              },
            ),
            if (realTimeOutput.isNotEmpty &&
                realTimeOutput != expression)
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  String textToDisplay = realTimeOutput;
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
                      final number = double.parse(realTimeOutput);
                      textToDisplay = number.toStringAsExponential(6);
                    } catch (e) {
                      textToDisplay = realTimeOutput;
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
    );
  }
}
