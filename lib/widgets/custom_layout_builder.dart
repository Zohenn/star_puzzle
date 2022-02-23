import 'package:flutter/material.dart';

class CustomLayoutBuilder extends StatelessWidget {
  const CustomLayoutBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final Widget Function(bool) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final screenWidth = MediaQuery.of(context).size.width;
      return builder(screenWidth < 700);
    });
  }
}
