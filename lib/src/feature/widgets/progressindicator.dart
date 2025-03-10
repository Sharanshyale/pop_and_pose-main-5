import 'package:flutter/material.dart';
import 'package:pop_and_pose/src/constant/app_spaces.dart';
import 'package:pop_and_pose/src/constant/colors.dart';

class CircularProgressIndicatorContainer extends StatelessWidget {
  final double progressValue;
  final double horizontal;

  const CircularProgressIndicatorContainer(
      {super.key, required this.progressValue, required this.horizontal});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      margin: EdgeInsets.symmetric(horizontal: horizontal),
      width: maxWidth(context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 7),
        child: Container(
          height: 20,
          width: maxWidth(context),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: LinearProgressIndicator(
            value: progressValue,
            borderRadius: BorderRadius.circular(6),
            backgroundColor: Colors.white,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColor.kAppColor
            ),
          ),
        ),
      ),
    );
  }
}
