import 'package:flutter/painting.dart';

const smallBreakpoint = 700;

Offset sizeToOffset(Size size) => Offset(size.width, size.height);

String formatSeconds(int seconds) => '${seconds ~/ 60}:${(seconds % 60 < 10 ? '0' : '') + (seconds % 60).toString()}';