import 'package:flutter/material.dart';

class RowOrColumn extends StatelessWidget {
  const RowOrColumn({
    Key? key,
    required this.isRow,
    required this.rowLayoutBuilder,
    required this.columnLayoutBuilder,
    required this.children,
  }) : super(key: key);

  final bool isRow;
  final Widget Function(List<Widget>) rowLayoutBuilder;
  final Widget Function(List<Widget>) columnLayoutBuilder;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return isRow ? rowLayoutBuilder(children) : columnLayoutBuilder(children);
  }
}
