import 'package:flutter/material.dart';
import 'package:star_puzzle/widgets/sized_circular_progress_indicator.dart';

class FutureHandler extends StatefulWidget {
  const FutureHandler({
    Key? key,
    required this.future,
    this.onNotDone,
    required this.onDone,
    this.doneCallback,
    this.buildDoneCallback,
    this.onError,
    this.fillColor,
    this.indicatorSize,
    this.indicatorStrokeWidth,
    this.indicatorColor,
    this.once = false,
  }) : super(key: key);

  final Future? future;
  final Widget Function()? onNotDone;
  final Widget Function() onDone;
  final VoidCallback? doneCallback;
  final VoidCallback? buildDoneCallback;
  final Widget Function()? onError;
  final Color? fillColor;
  final double? indicatorSize;
  final double? indicatorStrokeWidth;
  final Color? indicatorColor;
  final bool once;

  @override
  _FutureHandlerState createState() => _FutureHandlerState();
}

class _FutureHandlerState extends State<FutureHandler> {
  bool _done = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();

    if (!bool.fromEnvironment('dart.vm.product')) {
      widget.future?.catchError((e) => throw e);
    }

    final future = widget.future;

    widget.future?.then((value) {
      if (mounted && widget.future == future) {
        setState(() {
          _done = true;
          if (widget.doneCallback != null) {
            widget.doneCallback!();
          }
        });
      }
    }).onError((error, stackTrace) {
      if (mounted && widget.future == future) {
        setState(() {
          _error = true;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant FutureHandler oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.once && widget.future != oldWidget.future) {
      _done = false;
      _error = false;

      final future = widget.future;

      widget.future?.then((value) {
        if (mounted && widget.future == future) {
          setState(() {
            _done = true;
            if (widget.doneCallback != null) {
              widget.doneCallback!();
            }
          });
        }
      }).onError((error, stackTrace) {
        if (mounted && widget.future == future) {
          setState(() {
            _error = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.future == null || _done) {
      if (widget.buildDoneCallback != null) {
        widget.buildDoneCallback!();
      }
      return widget.onDone();
    }

    if (_error) {
      return widget.onError != null ? widget.onError!() : Center(child: Text('Niestety, ale mamy problem 😟'));
    }

    return widget.onNotDone != null
        ? widget.onNotDone!()
        : Material(
            color: widget.fillColor ?? Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: SizedCircularProgressIndicator(
                size: widget.indicatorSize,
                strokeWidth: widget.indicatorStrokeWidth,
                valueColor: AlwaysStoppedAnimation(widget.indicatorColor ?? Theme.of(context).colorScheme.secondary),
              ),
            ),
          );
  }
}
