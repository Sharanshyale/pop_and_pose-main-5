import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_bloc.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_event.dart';

class TakePictureButton extends StatelessWidget {
  const TakePictureButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.read<CameraBloc>().add(TakePictureEvent()),
      child: const Text('Take Picture'),
    );
  }
}
