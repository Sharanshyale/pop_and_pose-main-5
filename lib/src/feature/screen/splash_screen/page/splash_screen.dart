import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/route_manager.dart';
import 'package:pop_and_pose/src/constant/api_constants.dart';
import 'package:pop_and_pose/src/constant/toaster.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_bloc.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_event.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_state.dart';
import 'package:pop_and_pose/src/feature/screen/choose_frame/page/choose_frame.dart';
import 'package:pop_and_pose/src/feature/screen/choose_screen/page/choose_screen.dart';
import 'package:pop_and_pose/src/feature/screen/register_device/page/register_device.dart';
import 'package:pop_and_pose/src/feature/screen/settings/page/settings.dart';
import 'package:pop_and_pose/src/feature/widgets/app_texts.dart';
import 'package:pop_and_pose/src/feature/widgets/containers.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:get/get.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with SingleTickerProviderStateMixin {
  bool _isLoadingDialogShowing = false;
  late AnimationController _animationController;
  String? _deviceInfo;

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

   Future<void> _getDeviceInfo() async {
     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
 
    setState(() {
     _deviceInfo = iosInfo.model;
   
    });
  }

  Future<bool> checkDeviceExists() async {
    const String apiUrl =
        "https://pop-pose-backend.vercel.app/api/background/devices";
    try {
      final response = await http.get(Uri.parse(apiUrl));
 
      if (response.statusCode == 200) {
        List<dynamic> devices = jsonDecode(response.body);
        String? currentDeviceKey = _deviceInfo;
        print('deviceModel $currentDeviceKey');
 
        bool deviceExists =
            devices.any((device) => device['device_key'] == currentDeviceKey);
            print('object $deviceExists');
        return deviceExists;
      } else {
        debugPrint("Failed to fetch devices: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("Error fetching devices: $e");
      return false;
    }
  }
  Future<void> _submitWithoutUser() async {
    // Prepare request body
    Map<String, String> requestBody = {
      "user_Name": "temporaryUser",
      "phone_Number": "9876543210",
      "email": "emailtemp@gmail.com",
    };

    try {
      final response = await http.post(
        Uri.parse(BaseurlForBackend.startUserJourney1), // API Endpoint
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        var responseData = json.decode(response.body);

        // Extract '_id' from 'user' object
        if (responseData != null && responseData.containsKey('user')) {
          var userObject = responseData['user'];

          if (userObject != null && userObject.containsKey('_id')) {
            String userId = userObject['_id'] ?? ''; // Get user ID safely

            if (userId.isNotEmpty) {
              Get.to(
                () => ChooseScreenPage(userId: userId),
              );
            } else {
              Get.snackbar("Error", "User ID is empty. Please try again.");
            }
          } else {
            Get.snackbar("Error", "User ID is missing in the response.");
          }
        } else {
          Get.snackbar(
              "Error", "Unexpected response format. User object not found.");
        }
      } else {
        Get.snackbar("Error", "Failed to create user. Please try again.");
      }
    } catch (error) {
      print("Error: $error");
      Get.snackbar("Error", "An error occurred. Please try again.");
    }
  }

  Widget _buildStatusContainer({
    required Color color,
    required IconData icon,
    required String message,
    VoidCallback? onRetry,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
          if (onRetry != null)
            GestureDetector(
              onTap: onRetry,
              child: Icon(
                Icons.refresh,
                color: color,
              ),
            ),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    if (_isLoadingDialogShowing) return;

    _isLoadingDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.95 + (0.05 * value),
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.25,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SpinKitSpinningLines(
                                color: Color.fromARGB(255, 76, 172, 100),
                                size: 90.0,
                              ),
                              Icon(
                                Icons.camera_alt_rounded,
                                size: 30,
                                color: Color.fromARGB(255, 97, 187, 228),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        Texts(
                          texts: 'Discovering Camera...',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        //)
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) => _isLoadingDialogShowing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'images/background.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Determine layout based on screen size
                final bool isLargeScreen = constraints.maxWidth > 800;

                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: isLargeScreen ? 40 : 20),
                        Containers(
                          height: isLargeScreen ? 200 : 140,
                          width: isLargeScreen ? 200 : 140,
                          child: Image.asset(
                            'images/Logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: isLargeScreen ? 40 : 20),
                        Texts(
                          texts: 'Pop And Pose',
                          fontSize: isLargeScreen ? 80 : 60,
                          color: const Color.fromRGBO(21, 20, 38, 1),
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 10),
                        BlocConsumer<CameraBloc, CameraState>(
                          listener: (context, state) {
                            if (state is CameraError) {
                              _dismissLoadingDialog();
                              ToasterService.error(message: state.message);
                            } else if (state is CameraConnectedState) {
                              _dismissLoadingDialog();
                              _submitWithoutUser();
                            } else if (state is CameraDiscoveringState) {
                              _showLoadingDialog(context);
                            } else if (state is CameraDisconnectedState) {
                              _dismissLoadingDialog();
                            }
                          },
                          builder: (context, state) {
                            return _buildStatusUI(state);
                          },
                        ),
                        const SizedBox(height: 20),
                        Containers(
                          width: isLargeScreen ? 120 : 92,
                          height: isLargeScreen ? 120 : 92,
                          child: Image.asset(
                            'images/icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 60),
                        Container(
                          padding: const EdgeInsets.all(15),
                          width: 500,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: const StepProgressIndicator(
                            totalSteps: 10,
                            currentStep: 1,
                            size: 4,
                            padding: 0,
                            selectedColor: Colors.black,
                            unselectedColor: Color.fromARGB(255, 235, 231, 231),
                            roundedEdges: Radius.circular(20),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _dismissLoadingDialog() {
    if (_isLoadingDialogShowing && mounted && context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      _isLoadingDialogShowing = false;
    }
  }

  Widget _buildStatusUI(CameraState state) {
    if (state is CameraDisconnectedState) {
      return _buildStatusContainer(
        color: Colors.red,
        icon: Icons.error_outline_rounded,
        message: 'Failed to discover camera\nPlease check your permissions',
        onRetry: () {
          context.read<CameraBloc>().add(DiscoverCameraEvent());
        },
      );
    } else if (state is CameraConnectedState) {
      return _buildStatusContainer(
        color: Colors.green,
        icon: Icons.check_circle_outline_rounded,
        message: 'Camera Ready!\nStarting soon...',
      );
    } else {
      return GestureDetector(
        onTap: () async
         {
          
            bool exists = await checkDeviceExists();
            if (exists) {
              Get.offAll(() => const ChooseFrame(
                    userId: '',
                  ));
             
            } else {
              Get.offAll(() =>
                  const RegisterDevice());
            }
 
     //   context.read<CameraBloc>().add(DiscoverCameraEvent());
          
        //Get.offAll(() => const RegisterDevice());
      
      //  Get.offAll(() =>  const SettingsPage());
        },
        child: const Texts(
          texts: 'Touch the screen to START',
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: Color.fromRGBO(55, 65, 81, 1),
        ),
      );
    }
  }
}
