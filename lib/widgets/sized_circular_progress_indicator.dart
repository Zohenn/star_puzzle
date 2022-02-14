import 'package:flutter/material.dart';

class SizedCircularProgressIndicator extends StatelessWidget {
  const SizedCircularProgressIndicator({
    Key? key,
    this.value,
    this.backgroundColor,
    this.color,
    this.valueColor,
    this.strokeWidth,
    this.semanticsLabel,
    this.semanticsValue,
    this.size = 24,
  }): super(key: key);

  final double? value;
  final Color? backgroundColor;
  final Color? color;
  final Animation<Color>? valueColor;
  final double? strokeWidth;
  final String? semanticsLabel;
  final String? semanticsValue;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        key: key,
        value: value,
        backgroundColor: backgroundColor,
        color: color,
        valueColor: valueColor,
        strokeWidth: strokeWidth ?? 4.0,
        semanticsLabel: semanticsLabel,
        semanticsValue: semanticsValue,
      ),
    );
  }
}
