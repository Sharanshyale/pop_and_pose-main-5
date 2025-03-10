import 'package:flutter/material.dart';
import 'package:pop_and_pose/src/constant/colors.dart';

class Btn extends StatelessWidget {
  final Color? textColor;
  final Widget? child;
  final double? width;
  final void Function()? onTap;

  const Btn({
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(7.0),
            border: Border.all(color: AppColor.kAppColor//const Color.fromRGBO(11, 171, 124, 1)
            )),
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
