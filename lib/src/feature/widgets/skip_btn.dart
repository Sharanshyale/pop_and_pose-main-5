import 'package:flutter/material.dart';

class SkipBtn extends StatelessWidget {
  final Color? textColor;
  final Widget? child;
  final double? width;
  final void Function()? onTap;

  const SkipBtn({
    super.key,
    this.onTap,
    this.textColor,
    this.child,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 190, 190, 190),
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(7.0),
          splashColor: Colors.white.withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.1),
          onTap: onTap,
          child: SizedBox(
            width: width,
            height: 48.0,
            child: Center(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
