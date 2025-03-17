import 'package:flutter/material.dart';
import 'package:pop_and_pose/src/constant/colors.dart';

class Framebackground extends StatefulWidget {
  const Framebackground({super.key});

  @override
  State<Framebackground> createState() => _FramebackgroundState();
}

class _FramebackgroundState extends State<Framebackground> {
  String? backgroundImageUrl;
  String? deviceModel;
  @override
 Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
   
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
                                    maxHeight: screenHeight * 0.86,
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
                                 
                                ),
                              ],
                            ),
                          ),
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
