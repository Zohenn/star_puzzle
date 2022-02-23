import 'package:flutter/material.dart';

class ConditionalBuilder extends StatelessWidget {
  const ConditionalBuilder({
    Key? key,
    required this.condition,
    this.ifTrue,
    this.ifFalse,
  })  : assert(ifTrue != null || ifFalse != null),
        super(key: key);

  final bool condition;
  final Widget Function()? ifTrue;
  final Widget Function()? ifFalse;

  @override
  Widget build(BuildContext context) {
    if(condition){
      return ifTrue != null ? ifTrue!() : const SizedBox.shrink();
    }

    return ifFalse != null ? ifFalse!() : const SizedBox.shrink();
  }
}