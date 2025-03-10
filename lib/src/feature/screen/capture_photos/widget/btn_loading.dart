import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget btnLoading() {
  return const SizedBox(
    height: 30,
    width: 30,
    child: SpinKitSpinningLines(
      color: Colors.white,
    ),
  );
}
