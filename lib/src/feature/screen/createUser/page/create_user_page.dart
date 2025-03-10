import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pop_and_pose/src/constant/api_constants.dart';
import 'package:pop_and_pose/src/constant/colors.dart';
import 'package:pop_and_pose/src/feature/screen/choose_frame/page/choose_frame.dart';
import 'package:pop_and_pose/src/feature/screen/splash_screen/page/splash_screen.dart';
import 'package:pop_and_pose/src/feature/widgets/app_btn.dart';
import 'package:pop_and_pose/src/feature/widgets/app_texts.dart';
import 'package:pop_and_pose/src/feature/widgets/skip_btn.dart';
import 'package:pop_and_pose/src/feature/widgets/textfield.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  int countdown = 59;
  Timer? _timer;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  void initState() {
    super.initState();
    // startTimer();
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

  void dispose() {
    stopTimer();
    super.dispose();
  }

  Future<void> _submit() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();

    // Validate email
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      Get.snackbar("Invalid Input", "Please enter a valid email address.");
      return;
    }

    // Validate phone number
    if (phone.isEmpty || !RegExp(r'^\+?\d{10,15}$').hasMatch(phone)) {
      Get.snackbar("Invalid Input", "Please enter a valid phone number.");
      return;
    }

    // Prepare request body
    Map<String, String> requestBody = {
      "user_Name": name,
      "phone_Number": phone,
      "email": email,
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
                () => ChooseFrame(userId: userId),
                transition: Transition.rightToLeft,
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
                () => ChooseFrame(userId: userId),
                transition: Transition.rightToLeft,
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
        body: Stack(children: [
          Image.asset(
            'images/background.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
              child: Column(children: [
            Align(
                alignment: Alignment.topRight,
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
                    )))),
            const SizedBox(height: 5),
            Expanded(
              child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(children: [
                    Container(
                        width: 600,
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.84,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 25),
                                  child: Texts(
                                    texts: 'Enter Your Details',
                                    fontSize: 28,
                                    color: Color.fromRGBO(21, 20, 38, 1),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Texts(
                                  texts:
                                      'Enter your details to create an account',
                                  fontSize: 16,
                                  color: Color.fromRGBO(21, 20, 38, 1),
                                  fontWeight: FontWeight.w400,
                                ),
                                const SizedBox(height: 20),
                                CustField(
                                  title: 'UserName',
                                  hintText: 'Rajat Saxena',
                                  inputType: TextInputType.emailAddress,
                                  mealController: _nameController,
                                ),
                                CustField(
                                  title: 'Email',
                                  hintText: 'xyz@gmail.com',
                                  inputType: TextInputType.emailAddress,
                                  mealController: _emailController,
                                ),
                                CustField(
                                  title: 'Enter Your Phone Number ',
                                  hintText: '+919876543210  ',
                                  inputType: TextInputType.emailAddress,
                                  mealController: _phoneController,
                                ),
                                const SizedBox(height: 20),
                                AppBtn(
                                  onTap: () {
                                    _submit();
                                  },
                                  child: const Texts(
                                    texts: 'Submit',
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SkipBtn(
                                  onTap: () {
                                    _submitWithoutUser();
                                  },
                                  child: const Texts(
                                    texts: 'Skip',
                                    fontSize: 18,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ))),
                  ])),
            ),
          ])),
        ]),
      ),
    );
  }
}
