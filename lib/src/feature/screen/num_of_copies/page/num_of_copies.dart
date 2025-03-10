import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;
import 'package:pop_and_pose/src/constant/api_constants.dart';
import 'package:pop_and_pose/src/constant/colors.dart';
import 'package:pop_and_pose/src/constant/toaster.dart';
import 'package:pop_and_pose/src/feature/screen/choose_screen/page/choose_screen.dart';
import 'package:pop_and_pose/src/feature/screen/num_of_copies/widget/btn.dart';

import 'package:pop_and_pose/src/feature/screen/payment_page/page/payment_page_screen.dart';
import 'package:pop_and_pose/src/feature/screen/splash_screen/page/splash_screen.dart';
import 'package:pop_and_pose/src/feature/widgets/app_btn.dart';
import 'package:pop_and_pose/src/feature/widgets/app_texts.dart';

class NumCopies extends StatefulWidget {
  final String userid;
  const NumCopies({super.key, required this.userid});

  @override
  _NumCopiesState createState() => _NumCopiesState();
}

class _NumCopiesState extends State<NumCopies> {
  String? selectedCopyId;
  int countdown = 8000;
  Timer? _timer;
  List<Map<String, dynamic>> availableCopies = [];

  @override
  void initState() {
    super.initState();
   // startTimer();
    fetchCopies();
  }

  Future<void> fetchCopies() async {
    try {
      final response = await http.get(Uri.parse(BaseurlForBackend.getCopies));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final copiesList = data['copies'] as List;

        setState(() {
          availableCopies = copiesList.map((copy) {
            return {
              "id": copy['_id'],
              "number": copy['Number'],
            };
          }).toList();
        });
      } else {
        ToasterService.error(message: 'Failed to load copies.');
      }
    } catch (error) {
      ToasterService.error(message: 'Error fetching data: $error');
    }
  }

  void startTimer() {
    stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
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

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  Future<void> _selectNoOfCopies(String userId, String copyId) async {
    try {
      final response = await http.post(
        Uri.parse(
            "https://pop-pose-backend.vercel.app/api/user/$userId/select-number"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"numberId": copyId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Selected no of copies successfully: $data");

        Get.to(() => PaymentPageScreen(
              userId: userId,
            ));
      } else {
        ToasterService.error(message: 'Failed to select number of copies.');
      }
    } catch (error) {
      ToasterService.error(message: 'Error selecting copies: $error');
    }
  }

  Widget buildCopyContainer(Map<String, dynamic> copy) {
    bool isSelected = selectedCopyId == copy['id'];

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCopyId = copy['id'];
        });
      },
      child: Container(
        height: 125,
        width: 130,
        decoration: BoxDecoration(
          color: isSelected ? AppColor.kAppColor : Colors.white,
          border: Border.all(
              color: isSelected ? AppColor.kAppColor : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Texts(
              texts: '${copy['number']}', // Display the number of copies
              fontSize: 24,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
            ),
            Texts(
              texts: 'Copies',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ],
        ),
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
        body: Stack(
          children: [
            Image.asset(
              'images/background.png',
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
                          Container(
                        
                              width: 700,
                            constraints: BoxConstraints(
                              minHeight:
                                  MediaQuery.of(context).size.height * 0.75,
                            ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 25.0),
                                    child: Texts(
                                      texts: 'Select The Number Of Copies',
                                      fontSize: 28,
                                      color: Color.fromRGBO(21, 20, 38, 1),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 60),
                                  Center(
                                    child: Wrap(
                                      spacing: 30,
                                      runSpacing: 10,
                                      children: availableCopies
                                          .map((copy) =>
                                              buildCopyContainer(copy))
                                          .toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Btn(
          onTap: () { 
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
                                          if (selectedCopyId != null) {
                                            stopTimer();
                                            _selectNoOfCopies(
                                                widget.userid, selectedCopyId!);
                                          } else {
                                            ToasterService.error(
                                                message:
                                                    'Please select copies before proceeding.');
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
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }
}




