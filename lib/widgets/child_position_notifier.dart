import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PositionChangedLayoutNotification extends LayoutChangedNotification {
  PositionChangedLayoutNotification(this.position);

  final Offset position;
}

class PositionChangedLayoutNotifier extends SingleChildRenderObjectWidget {
  /// Creates a [PositionChangedLayoutNotifier] that dispatches layout changed
  /// notifications when [child] changes layout size.
  const PositionChangedLayoutNotifier({
    Key? key,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderPositionChangedWithCallback(
      onLayoutChangedCallback: (Offset position) {
        PositionChangedLayoutNotification(position).dispatch(context);
      },
    );
  }
}

class _RenderPositionChangedWithCallback extends RenderProxyBox {
  _RenderPositionChangedWithCallback({
    RenderBox? child,
    required this.onLayoutChangedCallback,
  }) : assert(onLayoutChangedCallback != null),
        super(child);

  // There's a 1:1 relationship between the _RenderSizeChangedWithCallback and
  // the `context` that is captured by the closure created by createRenderObject
  // above to assign to onLayoutChangedCallback, and thus we know that the
  // onLayoutChangedCallback will never change nor need to change.

  final void Function(Offset) onLayoutChangedCallback;

  Offset? _oldPosition;

  @override
  void performLayout() {
    super.performLayout();
    // Don't send the initial notification, or this will be SizeObserver all
    // over again!
    final position = localToGlobal(Offset.zero);
    if (_oldPosition != null && position != _oldPosition) {
      onLayoutChangedCallback(position);
    }
    _oldPosition = position;
  }
}