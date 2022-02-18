import 'package:flutter/material.dart';

class AutoKeepAlive extends StatefulWidget {
  const AutoKeepAlive({
    Key? key,
    required this.childBuilder,
  }) : super(key: key);

  final Widget Function() childBuilder;

  @override
  _AutoKeepAliveState createState() => _AutoKeepAliveState();
}

class _AutoKeepAliveState extends State<AutoKeepAlive> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return widget.childBuilder();
  }

  @override
  bool get wantKeepAlive => true;
}