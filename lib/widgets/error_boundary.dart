import 'package:flutter/material.dart';

class ErrorBoundaryWidget extends StatefulWidget {
  final Widget child;

  const ErrorBoundaryWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _ErrorBoundaryWidgetState createState() => _ErrorBoundaryWidgetState();
}

class _ErrorBoundaryWidgetState extends State<ErrorBoundaryWidget> {
  @override
  void initState() {
    super.initState();
    ErrorWidget.builder = (FlutterErrorDetails details) {
      if (details.toString().contains('hardware_keyboard.dart')) {
        return widget.child;
      }
      return ErrorWidget(details.exception);
    };
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
