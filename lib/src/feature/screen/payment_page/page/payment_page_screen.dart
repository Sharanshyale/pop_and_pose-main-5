import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:pop_and_pose/src/constant/colors.dart';
import 'package:pop_and_pose/src/constant/toaster.dart';
import 'package:pop_and_pose/src/feature/screen/num_of_copies/page/num_of_copies.dart';
import 'package:pop_and_pose/src/feature/screen/num_of_copies/widget/btn.dart';
import 'package:pop_and_pose/src/feature/screen/payment_success/page/payment_success.dart';
import 'package:pop_and_pose/src/feature/screen/splash_screen/page/splash_screen.dart';
import 'package:pop_and_pose/src/feature/widgets/app_btn.dart';
import 'package:pop_and_pose/src/feature/widgets/app_texts.dart';
import 'package:pop_and_pose/src/feature/widgets/progressindicator.dart';
import 'package:pop_and_pose/src/utils/getDeviceInfo.dart';

class PaymentPageScreen extends StatefulWidget {
  final String userId;
  const PaymentPageScreen({super.key, required this.userId});

  @override
  _PaymentPageScreenState createState() => _PaymentPageScreenState();
}

class _PaymentPageScreenState extends State<PaymentPageScreen> {
  Map<String, dynamic>? userData;
  int countdown = 800;
  Timer? _timer; // Changed to nullable Timer
     String? backgroundImageUrl;
  String? deviceModel;

  @override
  void initState() {
    super.initState();
      _getDeviceInfo();
    startTimer();

    fetchUserData();
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
  
  // Fetch user data from the API
  Future<void> fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse(
            "https://pop-pose-backend.vercel.app/api/user/${widget.userId}/getUser"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userData = data['user'];
        });
      } else {
        ToasterService.error(message: 'Failed to fetch user data.');
      }
    } catch (error) {
      ToasterService.error(message: 'Error fetching user data: $error');
    }
  }

  void startTimer() {
    stopTimer(); // Add this to prevent multiple timers
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          stopTimer();
          Get.offAll(() => const SplashScreenPage(),
              transition: Transition.leftToRight);
        }
      });
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
         
         // Image.asset('images/background.png', fit: BoxFit.cover),
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
                const SizedBox(height: 5),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        userData == null
                            ? const Center(child: CircularProgressIndicator())
                            : Container(
                                width: 700,
                                constraints: BoxConstraints(
                                  minHeight:
                                      MediaQuery.of(context).size.height * 0.75,
                                ),
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
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // First Column: Frame Information
                                          Expanded(
                                            child: Column(
                                              children: [
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 25.0),
                                                  child: Texts(
                                                    texts: 'Your Order',
                                                    fontSize: 28,
                                                    color: Color.fromRGBO(
                                                        21, 20, 38, 1),
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                const SizedBox(height: 60),
                                                SizedBox(
                                                  height: 420,
                                                  width: 215,
                                                  child: Image.network(
                                                    userData?['frame_Selection']
                                                            ['image'] ??
                                                        '',
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                                const SizedBox(height: 30),
                                                Texts(
                                                  texts:
                                                      userData?['frame_Selection']
                                                              ['frame_size'] ??
                                                          'N/A',
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color.fromRGBO(
                                                      55, 65, 81, 1),
                                                ),
                                                const SizedBox(height: 30),
                                                Texts(
                                                  texts:
                                                      '${userData?['no_of_copies']['Number']} Copies',
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color.fromRGBO(
                                                      55, 65, 81, 1),
                                                ),
                                                const SizedBox(height: 30),
                                              ],
                                            ),
                                          ),
                                          VerticalDivider(width: 2,color: AppColor.kAppColorGrey,),
                                          // Second Column: Payment Details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 25.0),
                                                  child: Texts(
                                                    texts: 'Pay Using the QR code',
                                                    fontSize: 28,
                                                    color: Color.fromRGBO(
                                                        21, 20, 38, 1),
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                const SizedBox(height: 60),
                                                Row(
                                                  children: [
                                                    Texts(
                                                      texts: 'Total Amount',
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.grey.shade700,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Texts(
                                                      texts:
                                                          '${userData?['frame_Selection']['price'] * userData?['no_of_copies']['Number']}',
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 30),
                                                Container(
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 32),
                                                  width: double.infinity,
                                                  height: 190,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(9),
                                                    color: Colors.amber,
                                                  ),
                                                ),
                                                
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                     const SizedBox(height: 30),
                                     Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Btn(
                              onTap: () {
                                stopTimer();
                                Get.off(() => const NumCopies(userid: ""));
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
                                stopTimer();
                                Get.to(() => PaymentSuccessPage(
                                      userId: widget.userId,
                                      copies: userData?['no_of_copies']
                                          ['Number'],
                                    ));
                              },
                              width: 150,
                              child: Texts(
                                texts:
                                    'Pay ${userData?['frame_Selection']['price'] * userData?['no_of_copies']['Number']} ',
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                                    ],
                                  ),
                                ),
                              ),
                     const Padding(
                    padding: EdgeInsets.symmetric(vertical: 25),
                    child: CircularProgressIndicatorContainer(
                      progressValue: 0.3,
                      horizontal: 120,
                    ),
                  ),  
                       
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
