// ignore_for_file: deprecated_member_use, library_prefixes, library_private_types_in_public_api

import 'dart:async';
import 'package:get/get.dart' as GetNavigator;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pop_and_pose/src/constant/colors.dart';
import 'package:pop_and_pose/src/constant/loader.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_bloc.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_event.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_state.dart';
import 'package:pop_and_pose/src/feature/screen/camera/widget/live_view_widget.dart';
import 'package:pop_and_pose/src/feature/screen/select_photo/page/select_photos.dart';
import 'package:pop_and_pose/src/feature/screen/splash_screen/page/splash_screen.dart';
import 'package:pop_and_pose/src/feature/widgets/app_texts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pop_and_pose/src/utils/getDeviceInfo.dart';

class CapturePhotos extends StatefulWidget {
  final Map<String, dynamic>? imageInfo;
  final int? copies;
  final String userId;
  const CapturePhotos(
      {super.key, this.imageInfo, this.copies, required this.userId});
  @override
  _CapturePhotosState createState() => _CapturePhotosState();
}

class _CapturePhotosState extends State<CapturePhotos> {
  late CameraBloc _cameraBloc;
  bool _isCameraConnected = false;
  bool _isConnecting = false;
  int countdown = 3059;
  Timer? _timer;
  StreamSubscription<CameraState>? _cameraStateSubscription;
  String? backgroundImageUrl;
  String? deviceModel;
  @override
  void initState() {
    super.initState();
    _cameraBloc = context.read<CameraBloc>();
    _getDeviceInfo();
    startTimer();
    _subscribeToCamera();
  }
Future<void> _getDeviceInfo() async {
    List<String> deviceInfo=await Getdeviceinformation().getDevice();
 
    setState(() {
      deviceModel = deviceInfo[0];
   
    });
 
    if (deviceModel != null) {
      String? imageUrl=await Getdeviceinformation().fetchBackgroundImage(deviceModel!);
      setState(() {
        backgroundImageUrl=imageUrl;
      });
        
    }
  }
  @override
  void dispose() {
    stopTimer();
    _cameraStateSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToCamera() {
    _cameraStateSubscription = _cameraBloc.stream.listen((state) {
      if (state is CameraConnectedState) {
        setState(() {
          _isCameraConnected = true;
          _isConnecting = false;
        });
      } else if (state is CameraDisconnectedState) {
        setState(() {
          _isCameraConnected = false;
          _isConnecting = false;
        });
      } else if (state is CameraDiscoveringState) {
        setState(() {
          _isConnecting = true;
        });
      }
    });
  }

  void _connectCamera() {
    if (!_isConnecting) {
      _cameraBloc.add(DiscoverCameraEvent());
    }
  }

  void startTimer() {
    stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          stopTimer();
          Get.off(const SplashScreenPage(),
              transition: GetNavigator.Transition.leftToRight);
        }
      });
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (countdown == 59 && (_timer == null || !_timer!.isActive)) {
      startTimer();
    }
  }

  Widget _buildStatusContainer({
    required Color color,
    required IconData icon,
    required String message,
    VoidCallback? onRetry,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          stopTimer();
        }
      },
      child: Scaffold(
        body: OrientationBuilder(
          builder: (context, orientation) {
            return Stack(
              fit: StackFit.expand,
              children: [
                 backgroundImageUrl != null
              ? Image.network(
                backgroundImageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
              : const Center(child: CircularProgressIndicator()),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate responsive dimensions
                      final isPortrait = orientation == Orientation.portrait;
                      final containerWidth =
                          constraints.maxWidth * (isPortrait ? 0.9 : 0.8);
                      final containerHeight =
                          constraints.maxHeight * (isPortrait ? 0.75 : 0.85);
                      final fontSize =
                          constraints.maxWidth * (isPortrait ? 0.08 : 0.04);
                      final previewHeight =
                          containerHeight * (isPortrait ? 0.55 : 0.6);

                      return SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: constraints.maxHeight * 0.05,
                                horizontal: constraints.maxWidth * 0.05,
                              ),
                              child: Container(
                                width: containerWidth,
                                height: containerHeight,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding:
                                      EdgeInsets.all(containerWidth * 0.05),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Texts(
                                        texts: 'Capture 8 Photos!',
                                        fontSize: fontSize,
                                        color:
                                            const Color.fromRGBO(21, 20, 38, 1),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      SizedBox(height: containerHeight * 0.02),
                                      Container(
                                        width: containerWidth * 0.9,
                                        height: previewHeight,
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(
                                              217, 217, 217, 1),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: const LiveViewScreen(),
                                      ),
                                      SizedBox(height: containerHeight * 0.0),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Spacer for alignment (using Flexible to take up remaining space)
                                          Flexible(
                                            flex: 1,
                                            child:
                                                Container(), // Empty container to take up space, align items properly
                                          ),

                                          // Circular button for 'Take Picture'
                                          InkWell(
                                            onTap: () {
                                              context
                                                  .read<CameraBloc>()
                                                  .add(TakePictureEvent());
                                            },
                                            child: Container(
                                              width:
                                                  60, // Fixed width of the button
                                              height:
                                                  60, // Fixed height of the button
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      'images/take_picture.png'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Next button aligned to the right
                                          Flexible(
                                            flex: 1,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  context
                                                      .read<CameraBloc>()
                                                      .add(StopLiveViewEvent());
                                                  Get.to(() => PhotoSelector(
                                                        imageInfo:
                                                            widget.imageInfo,
                                                        copies: widget.copies,
                                                        userId: widget.userId,
                                                      ));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                ),
                                                child: const Text(
                                                  "Next",
                                                  style:
                                                  
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                      // Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.spaceBetween,
                                      //   children: [
                                      //     const Expanded(child: SizedBox()),
                                      //     // Circular button for 'Take Picture'
                                      //     // Round image as 'Take Picture' button
                                      //     InkWell(
                                      //       onTap: () {
                                      //         context
                                      //             .read<CameraBloc>()
                                      //             .add(TakePictureEvent());
                                      //       },
                                      //       child: Container(
                                      //         width: 60, // Width of the button
                                      //         height:
                                      //             60, // Height of the button
                                      //         decoration: const BoxDecoration(
                                      //           shape: BoxShape.circle,
                                      //           image: DecorationImage(
                                      //             image: AssetImage(
                                      //                 'images/take_picture.png'), // Replace with your image path
                                      //             fit: BoxFit.cover,
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //     // Spacer for alignment
                                      //     Expanded(
                                      //       child: Align(
                                      //         alignment: Alignment
                                      //             .centerRight, // Align "Next" button to the right
                                      //         child: ElevatedButton(
                                      //           onPressed: () {
                                      //             context
                                      //                 .read<CameraBloc>()
                                      //                 .add(StopLiveViewEvent());
                                      //             Get.to(() => PhotoSelector(
                                      //                   imageInfo:
                                      //                       widget.imageInfo,
                                      //                   copies: widget.copies,
                                      //                 ));
                                      //           },
                                      //           style: ElevatedButton.styleFrom(
                                      //             shape: RoundedRectangleBorder(
                                      //               borderRadius:
                                      //                   BorderRadius.circular(
                                      //                       8),
                                      //             ),
                                      //             padding: const EdgeInsets
                                      //                 .symmetric(
                                      //                 horizontal: 16,
                                      //                 vertical: 8),
                                      //           ),
                                      //           child: const Text(
                                      //             "Next",
                                      //             style:
                                      //                 TextStyle(fontSize: 16),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_isConnecting)
                  Center(
                    child: loading(),
                  ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02,
                      right: MediaQuery.of(context).size.width * 0.02,
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.15,
                        height: MediaQuery.of(context).size.width * 0.15,
                        decoration: const BoxDecoration(
                          color: AppColor.kAppColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Texts(
                            texts: '$countdown',
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
