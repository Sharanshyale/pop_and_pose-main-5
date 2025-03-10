import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget loading() {
  return const SizedBox(
    height: 60,
    width: 60,
    child: SpinKitSpinningLines(
      color: Color.fromARGB(255, 76, 172, 100),
    ),
  );
}
