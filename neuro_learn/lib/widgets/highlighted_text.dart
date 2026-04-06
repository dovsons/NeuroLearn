import 'package:flutter/material.dart';
import 'package:neuro_learn/models/transcript_result.dart';

class HighlightedText extends StatelessWidget {
  final List<WordComparison> comparisons;
  final EdgeInsets padding;

  const HighlightedText({
    Key? key,
    required this.comparisons,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Wrap(
        spacing: 4,
        runSpacing: 8,
        children: comparisons.map((comparison) {
          return _buildWordWidget(comparison);
        }).toList(),
      ),
    );
  }

  Widget _buildWordWidget(WordComparison comparison) {
    Color backgroundColor;
    Color textColor;
    String displayText = comparison.word;

    switch (comparison.status) {
      case WordStatus.correct:
        backgroundColor = Colors.greenAccent.withOpacity(0.3);
        textColor = Colors.green[800]!;
        break;
      case WordStatus.incorrect:
        backgroundColor = Colors.redAccent.withOpacity(0.3);
        textColor = Colors.red[800]!;
        displayText =
            '${comparison.word} (you said: ${comparison.userSaid})';
        break;
      case WordStatus.missing:
        backgroundColor = Colors.amberAccent.withOpacity(0.3);
        textColor = Colors.amber[800]!;
        displayText = '${comparison.word} [MISSING]';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: textColor.withOpacity(0.5),
        ),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
