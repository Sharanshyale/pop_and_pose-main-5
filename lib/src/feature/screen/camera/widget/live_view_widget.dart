import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pop_and_pose/src/constant/loader.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_bloc.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_event.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_state.dart';
import 'package:pop_and_pose/src/utils/log.dart';

class LiveViewScreen extends StatefulWidget {
  const LiveViewScreen({super.key});

  @override
  State<LiveViewScreen> createState() => _LiveViewScreenState();
}

class _LiveViewScreenState extends State<LiveViewScreen> {
  @override
  void initState() {
    super.initState();
    // Start live view when entering the screen
    context.read<CameraBloc>().add(StartLiveViewEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<CameraBloc, CameraState>(
        listener: (context, state) {
          if (state is CameraError) {
            // Show an error message if there is a camera issue
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          Log.d("Current State: ${state.runtimeType}");

          if (state is LiveViewFetchedState) {
            // Display the live view feed directly using the latest frame from state
            Log.d("Current Frame received ====>  ${state.frame.length}");
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context)
                      .size
                      .width, // Constrain the max width
                  maxHeight: MediaQuery.of(context)
                      .size
                      .height, // Constrain the max height
                ),
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Image.memory(
                    state.frame,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            );
          } else if (state is LiveViewStartedState) {
            // Show a loading indicator or placeholder during live view start
            return Center(child: loading());
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    Log.d('Live view disposed');
    super.dispose();
  }
}
