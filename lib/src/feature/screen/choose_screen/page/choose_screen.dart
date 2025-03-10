import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:pop_and_pose/src/feature/screen/choose_frame/page/choose_frame.dart';
import 'package:pop_and_pose/src/feature/screen/settings/page/settings.dart';
import 'package:pop_and_pose/src/feature/widgets/app_btn.dart';
import 'package:pop_and_pose/src/feature/widgets/app_texts.dart';
import 'package:pop_and_pose/src/feature/widgets/progressindicator.dart';

class ChooseScreenPage extends StatelessWidget {
  final String userId;
  const ChooseScreenPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Define breakpoints
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'images/background.png',
                fit: BoxFit.cover,
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Center(
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: isMobile
                                          ? 400
                                          : isTablet
                                              ? 400
                                              : 700,
                                      width: isMobile
                                          ? 300
                                          : isTablet
                                              ? 400
                                              : 800,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Texts(
                                              texts: 'Select a Payment Option',
                                              fontSize: 28,
                                              color:
                                                  Color.fromRGBO(21, 20, 38, 1),
                                              fontWeight: FontWeight.w800,
                                            ),
                                            SizedBox(
                                                height: isMobile ? 30 : 60),
                                            AppBtn(
                                              onTap: () {
                                                Get.to(() => ChooseFrame(
                                                      userId: userId,
                                                    ));
                                              },
                                              width: isMobile ? 150 : 200,
                                              child: const Texts(
                                                texts: 'Pay Online',
                                                fontSize: 22,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            // const SizedBox(height: 20),
                                            // const AppBtn(
                                            //   width: 200,
                                            //   child: Texts(
                                            //     texts: 'Already Paid',
                                            //     fontSize: 22,
                                            //     fontWeight: FontWeight.w600,
                                            //     color: Colors.white,
                                            //   ),
                                            // ),
                                            const SizedBox(height: 20),
                                            AppBtn(
                                              onTap: () {
                                                Get.to(
                                                    () => const SettingsPage());
                                              },
                                              width: isMobile ? 150 : 200,
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.settings,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 7),
                                                  Texts(
                                                    texts: 'Settings Page',
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ],
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
                        ),
                        const Positioned(
                          left: 0,
                          right: 0,
                          bottom: 20,
                          child: Center(
                            child: CircularProgressIndicatorContainer(
                                progressValue: 0.03, horizontal: 180),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
