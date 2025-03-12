import 'dart:convert';
import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;
import 'package:pop_and_pose/src/constant/api_constants.dart';
import 'package:pop_and_pose/src/constant/app_spaces.dart';
import 'package:pop_and_pose/src/constant/colors.dart';
import 'package:pop_and_pose/src/constant/toaster.dart';
import 'package:pop_and_pose/src/feature/screen/choose_screen/page/choose_screen.dart';
import 'package:pop_and_pose/src/feature/screen/num_of_copies/page/num_of_copies.dart';
import 'package:pop_and_pose/src/feature/screen/num_of_copies/widget/btn.dart';
import 'package:pop_and_pose/src/feature/screen/splash_screen/page/splash_screen.dart';
import 'package:pop_and_pose/src/feature/widgets/app_btn.dart';
import 'package:pop_and_pose/src/feature/widgets/app_texts.dart';
import 'package:pop_and_pose/src/feature/widgets/progressindicator.dart';

class ChooseFrame extends StatefulWidget {
  final String userId;
  const ChooseFrame({super.key, required this.userId});

  @override
  _ChooseFrameState createState() => _ChooseFrameState();
}

class _ChooseFrameState extends State<ChooseFrame> {
  int? selectedImage;
  int countdown = 59;
  Timer? _timer;
  String? backgroundImageUrl;
  String? deviceModel;

  // List to store frames fetched from the API
  List<Map<String, dynamic>> framesData = [];

  @override
  void initState() {
    super.initState();
  //startTimer();
  _getDeviceInfo();
    fetchFrames(); // Fetch frames data from the API
  }
   
  Future<void> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
 
    setState(() {
      deviceModel = iosInfo.model;
      //androidInfo.model;
    });
 
    if (deviceModel != null) {
      fetchBackgroundImage(deviceModel!);
    }
  }
  Future<void> fetchBackgroundImage(String deviceModel) async {
    final String apiUrl =
        'https://pop-pose-backend.vercel.app/api/background/getDeviceById/$deviceModel';
 
    try {
      final response = await http.get(Uri.parse(apiUrl));
 
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          backgroundImageUrl = data['background_image'];
        });
      } else {
        print('Failed to load background image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching background image: $e');
    }
  }
  // Fetch frames from the API
  Future<void> fetchFrames() async {
    try {
      final response = await http.get(Uri.parse(BaseurlForBackend.getFrames));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final framesList = data['frames'] as List;
        setState(() {
          framesData = framesList.map((frame) {
            return {
              'name': frame['frame_size'],
              'price': '₹${frame['price']}',
              'image': frame['image'],
              'id': frame['_id'],
              'rows': frame['rows'],
              'column': frame['column'],
              'index': frame['index'],
            };
          }).toList();
        });
      } else {
        ToasterService.error(message: 'Failed to load frames.');
      }
    } catch (error) {
      ToasterService.error(message: 'Error fetching data: $error');
    }
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          if (countdown > 0) {
            countdown--;
          } else {
            _timer?.cancel();
            Get.offAll(() => const SplashScreenPage(),
                transition: Transition.leftToRight);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (countdown == 59 && (_timer == null || !_timer!.isActive)) {
      startTimer();
    }
  }

  Future<void> _selectFrame(String userId, String frameId) async {
    try {
      final response = await http.post(
        Uri.parse(
            "https://pop-pose-backend.vercel.app/api/user/${userId}/select-frame"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"frameId": frameId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Handle the response data if necessary
        // Navigate to the next screen
        print("Frame selected successfully: $data");
        Get.to(() => NumCopies(
              userid: widget.userId,
            ));
      } else {
        ToasterService.error(message: 'Failed to select frame.');
      }
    } catch (error) {
      ToasterService.error(message: 'Error selecting frame: $error');
    }
  }

  Widget buildImageContainer(Map<String, dynamic> frame, int index) {
    final isSelected = selectedImage == index;
    return GestureDetector(
      onTap: () => setState(() => selectedImage = index),
      child: Column(
        children: [
          Container(
            height: 200,
            width: index == 0 ? 80 : 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColor.kAppColor : Colors.transparent,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  isSelected ? AppColor.kAppColor : Colors.grey,
                  BlendMode.hue,
                ),
                child: Image.network(
                  frame['image'], // Image URL fetched from the API
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Texts(
            texts: frame['price'], // Price from the API response
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildFrameGrid(BuildContext context) {
    return SizedBox(
      width: maxWidth(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: framesData
            .asMap()
            .map((index, frame) => MapEntry(
                  index,
                  buildImageContainer(frame, index),
                ))
            .values
            .toList(),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Btn(
          onTap: () {
            _timer?.cancel();
            Get.offAll(
                () => ChooseScreenPage(
                      userId: widget.userId,
                    ),
                transition: Transition.leftToRight);
          },
          width: 150,
          child: const Texts(
            texts: 'Back',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColor.kAppColor,
          ),
        ),
        const SizedBox(width: 25),
        AppBtn(
          onTap: () {
            if (selectedImage != null) {
              _timer?.cancel();
              // Call the API to select the frame and pass the userId and selected frameId
              _selectFrame(widget.userId, framesData[selectedImage!]['id']);
            } else {
              ToasterService.error(
                  message: 'Please select a frame before proceeding.');
            }
          },
          width: 150,
          child: const Texts(
            texts: 'Next',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          _timer?.cancel();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Image.network(
            backgroundImageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
            ),
            SafeArea(
              child: Column(
                children: [
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
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
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
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              height:MediaQuery.of(context).size.height * 0.75,
                              width: 700,
                              margin: const EdgeInsets.symmetric(vertical: 20),
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
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    const Texts(
                                      texts: 'Select One Frame',
                                      fontSize: 28,
                                      color: Color.fromRGBO(21, 20, 38, 1),
                                      fontWeight: FontWeight.w800,
                                    ),
                                    const SizedBox(height: 100),
                                    _buildFrameGrid(context),
                                  Spacer(),
                                    _buildNavigationButtons(),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicatorContainer(
                      progressValue: 0.05,
                      horizontal: 180,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
