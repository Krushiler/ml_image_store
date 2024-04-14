import 'package:flutter/material.dart';

class ClickableBox extends StatelessWidget {
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Widget child;
  final Color? splashColor;

  const ClickableBox({
    super.key,
    this.onTap,
    required this.child,
    this.borderRadius,
    this.splashColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (onTap != null)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                splashColor: splashColor,
                borderRadius: borderRadius,
                highlightColor: Colors.transparent,
              ),
            ),
          ),
      ],
    );
  }
}
