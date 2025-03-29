// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:pop_and_pose/src/constant/colors.dart';
import 'package:pop_and_pose/src/feature/screen/capture_photos/page/capture_photos.dart';
import 'package:pop_and_pose/src/feature/screen/splash_screen/page/splash_screen.dart';
import 'package:pop_and_pose/src/feature/widgets/app_btn.dart';
import 'package:pop_and_pose/src/feature/widgets/app_texts.dart';
import 'package:pop_and_pose/src/feature/widgets/progressindicator.dart';
import 'package:pop_and_pose/src/utils/getDeviceInfo.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String userId;
  final int? copies;
  const PaymentSuccessPage({super.key, required this.userId, this.copies});

  @override
  _PaymentSuccessPageState createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  int countdown = 800;
  Timer? _timer;
     String? backgroundImageUrl;
  String? deviceModel;

  @override
  void initState() {
    super.initState();
      _getDeviceInfo();
    startTimer();
  }

  void startTimer() {
    stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          stopTimer();
          Get.offAll(
            () => const SplashScreenPage(),
            transition: Transition.leftToRight,
          );
        }
      });
    });
  }

  void stopTimer() {
    _timer?.cancel();
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
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (countdown == 59 && (_timer == null || !_timer!.isActive)) {
      startTimer();
    }
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Determine responsive values based on screen size
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            // Responsive sizing
            final containerWidth =
                screenWidth > 900 ? 900.0 : screenWidth * 0.9;
            final imageSize = screenWidth * (screenWidth > 600 ? 0.3 : 0.5);

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
                  child: Column(
                    children: [
                      // Timer Container
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 7, top: 3),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: AppColor.kAppColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Texts(
                                texts: '$countdown',
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: containerWidth,
                                  constraints: BoxConstraints(
                                    minHeight: screenHeight * 0.7,
                                    maxHeight: screenHeight * 0.75,
                                  ),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 20),
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
                                    padding: EdgeInsets.all(
                                        screenWidth > 600 ? 20.0 : 10.0),
                                    child: Stack(
                                      children: [
                                        // Centered content
                                        Positioned.fill(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: SizedBox(
                                                  height: imageSize,
                                                  width: imageSize,
                                                  child: Image.asset(
                                                    'images/saly.png',
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  height: screenHeight * 0.03),
                                              const Texts(
                                                texts: 'Payment Successful!',
                                                fontSize: 32,
                                                color: Color.fromRGBO(
                                                    21, 20, 38, 1),
                                                fontWeight: FontWeight.w600,
                                              ),
                                              SizedBox(
                                                  height: screenHeight * 0.02),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20),
                                                child: Texts(
                                                  texts:
                                                      'Get ready to flaunt yourself. Proceed to capture.',
                                                  textAlign: TextAlign.center,
                                                  fontSize: 22,
                                                  color: Color.fromRGBO(
                                                      107, 114, 128, 1),
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Bottom-aligned button
                                        Positioned(
                                          bottom: 80,
                                          left: 0,
                                          right: 0,
                                          child: Center(
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 300,
                                                minWidth: 200,
                                              ),
                                              child: AppBtn(
                                                onTap: () {
                                                  stopTimer();
                                                  Get.to(
                                                    () => CapturePhotos(
                                                      copies: widget.copies,
                                                      userId: widget.userId,
                                                    ),
                                                  );
                                                },
                                                width: 200,
                                                child: const Texts(
                                                  texts: 'Continue',
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicatorContainer(
                          progressValue: 0.4,
                          horizontal: screenWidth > 600 ? 180 : 50,
                        ),
                      ),
                    ],
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
