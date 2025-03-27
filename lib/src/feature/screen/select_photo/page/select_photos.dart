import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';
import 'package:pop_and_pose/src/constant/api_constants.dart';
import 'package:pop_and_pose/src/constant/colors.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_bloc.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_event.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_state.dart';
import 'package:pop_and_pose/src/feature/screen/frameBackground/page/frameBackground.dart';
import 'package:pop_and_pose/src/feature/screen/num_of_copies/widget/btn.dart';
import 'package:pop_and_pose/src/feature/screen/print_screen/print_screen.dart';
import 'package:pop_and_pose/src/feature/screen/splash_screen/page/splash_screen.dart';
import 'package:pop_and_pose/src/feature/screen/testScreen/testScreen.dart';
import 'package:pop_and_pose/src/feature/widgets/app_btn.dart';
import 'package:pop_and_pose/src/feature/widgets/app_texts.dart';
import 'package:pop_and_pose/src/feature/widgets/containers.dart';
import 'package:pop_and_pose/src/feature/widgets/progressindicator.dart';
import 'package:http_parser/http_parser.dart';
import 'package:pop_and_pose/src/utils/getDeviceInfo.dart';

 
class PhotoSelector extends StatefulWidget {
  final Map<String, dynamic>? imageInfo;
  final String userId;
  final int? copies;
  const PhotoSelector(
      {super.key, this.imageInfo, this.copies, required this.userId});
 
  @override
  _PhotoSelectorState createState() => _PhotoSelectorState();
}
 
class _PhotoSelectorState extends State<PhotoSelector> {
  Map<int, Uint8List> selectedImages = {}; // Change the value type to Uint8List
  int countdown =800;
  Timer? _timer;
    String? backgroundImageUrl;
  String? deviceModel;
 
  // Handle image selection and store actual byte data
  void _handleImageSelection(Uint8List imageBytes) {
    if (selectedImages.containsValue(imageBytes)) {
      setState(() {
        selectedImages.removeWhere((key, value) => value == imageBytes);
      });
    } else if (selectedImages.length < getMaxImages()) {
      for (int i = 1; i <= getMaxImages(); i++) {
        if (!selectedImages.containsKey(i)) {
          setState(() {
            selectedImages[i] = imageBytes;
          });
          break;
        }
      }
    }
  }
  Future<void> clearImages() async {
    selectedImages.clear(); 
    
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
  int getMaxImages() {
    if (widget.imageInfo != null && widget.imageInfo!['name'] != null) {
      switch (widget.imageInfo!['name']) {
        case 'one':
          return 4;
        case 'two':
          return 2;
        case 'three':
          return 4;
        case 'four':
          return 6;
        default:
          return 4;
      }
    }
    return 4;
  }
 
  // Start the countdown timer
  void startTimer() {
    stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          stopTimer();
          Get.offAll(() => const SplashScreenPage());
        }
      });
    });
  }
 
  void stopTimer() {
    _timer?.cancel();
  }
 
  @override
  void initState() {
    super.initState();
    startTimer();
      _getDeviceInfo();
    context.read<CameraBloc>().add(FetchThumbnailsList());
    clearImages();
  }
 
  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }
 
  // Upload selected images to backend
  Future<void> uploadImage() async {
    if (selectedImages.length < 4) {
      Get.snackbar('Error', 'Please select 4 images before uploading.');
      return;
    }
 
    // Prepare the data for uploading
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse(BaseurlForBackend.uploadimage));
 
      request.fields['userId'] = widget.userId;
 
      // Add the selected images (stored as Uint8List) to the request
      selectedImages.forEach((key, value) {
        request.files.add(http.MultipartFile.fromBytes(
          'images[]',
          value, // Directly use the byte data (Uint8List)
          filename: 'image_$key.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
      });
 
      var response = await request.send();
 
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseData = json.decode(responseBody);
        Get.snackbar('Success', 'Images uploaded successfully!');
        // Optionally navigate to the next screen
        // Get.to(() => PrintScreenPage(
        //     imageUrls: responseData['imageUrls'], copies: widget.copies));
        Get.to(() => Framebackground(userId1: widget.userId,
        ));
      
        
      } else {
        Get.snackbar('Error', 'Failed to upload images');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while uploading images');
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
    builder: (context, state) {
      List<Uint8List> thumbnailsList = [];
      if (state is ThumbnailsFetchedState) {
        thumbnailsList = state.thumbnailsList;
      }
 
        return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            if (didPop) {
              stopTimer();
            }
          },
          child: Scaffold(
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
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;
                      final screenHeight = constraints.maxHeight;
                      final containerWidth =
                          screenWidth > 900 ? 900.0 : screenWidth * 0.9;
                 
                      return Column(
                        children: [
                          // Timer
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
                
                          // Main Content
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Container(
                                      width: containerWidth,
                                      constraints: BoxConstraints(
                                        minHeight: screenHeight * 0.7,
                                        maxHeight: screenHeight * 0.7,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 20),
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
                                            EdgeInsets.all(screenWidth * 0.02),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Texts(
                                              texts: 'Select The Photos You Like',
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Color.fromRGBO(21, 20, 38, 1),
                                            ),
                                            SizedBox(height: screenHeight * 0.02),
                                            Expanded(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Grid of thumbnails
                                                  Expanded(
                                                    child: GridView.builder(
                                                      shrinkWrap: true,
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount:
                                                            screenWidth > 600
                                                                ? 3
                                                                : 2,
                                                        crossAxisSpacing: 16,
                                                        mainAxisSpacing: 16,
                                                        childAspectRatio: 1,
                                                      ),
                                                      itemCount:
                                                          thumbnailsList.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        final imagePath =
                                                            thumbnailsList[index];
                                                        final isSelected =
                                                            selectedImages
                                                                .containsValue(
                                                                    imagePath);
                 
                                                        return GestureDetector(
                                                          onTap: () {
                                                            _handleImageSelection(
                                                                imagePath
                                                                    as Uint8List);
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                color: isSelected
                                                                    ? Colors.green
                                                                    : Colors.grey,
                                                                width: isSelected
                                                                    ? 3
                                                                    : 1,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              child:
                                                                  Image.memory(
                            thumbnailsList[index],
                            fit: BoxFit.cover,
                          )
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: screenWidth * 0.2),
                                                  // Preview container
                                                  Expanded(
                                                      child:
                                                          getContainerWidget()),
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
                 
                          // Bottom Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                
                
                                 Btn(
                              onTap: () { 
                                 stopTimer();
                                      Get.offAll(() => const SplashScreenPage());
                              },
                              width: 150,
                              child: const Texts(
                                texts: 'Back',
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppColor.kAppColor,
                              ),
                            ),
                                // ConstrainedBox(
                                //   constraints: const BoxConstraints(
                                //     maxWidth: 150,
                                //     minWidth: 120,
                                //   ),
                                 
                                 
                                //   child: OutlinedButton(
                                //     onPressed: () {
                                //       stopTimer();
                                //       Get.offAll(() => const SplashScreenPage());
                                //     },
                                //     style: OutlinedButton.styleFrom(
                                //       padding: const EdgeInsets.symmetric(
                                //           vertical: 15),
                                //     ),
                                //     child: const Texts(
                                //       texts: 'Back',
                                //       fontSize: 18,
                                //       fontWeight: FontWeight.w600,
                                //       color: Colors.green,
                                //     ),
                                //   ),
                                // ),
                                const SizedBox(width: 20),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 150,
                                    minWidth: 120,
                                  ),
                                  child: AppBtn(
                                    onTap: () {
                                      uploadImage(); // Call the upload function
                                    },
                                    child: const Texts(
                                      texts: 'Next',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
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
              ],
            ),
          ),
        );
      },
    );
  }
 
//   Widget getContainerWidget() {
//     if (widget.imageInfo != null && widget.imageInfo!['name'] != null) {
//       switch (widget.imageInfo!['name']) {
//         case 'one':
//           return contOne(selectedImages.cast<int, String>());
//         case 'two':
//           return contTwo(selectedImages.cast<int, String>());
//         case 'three':
//           return contFour(selectedImages.cast<int, String>());
//         case 'four':
//           return sixthCont(selectedImages.cast<int, String>());
//         default:
//           return contFour(selectedImages.cast<int, String>());
//       }
//     }
//     return contFour(selectedImages.cast<int, String>());
//   }
// }
 Widget getContainerWidget() {
  if (widget.imageInfo != null && widget.imageInfo!['name'] != null) {
    switch (widget.imageInfo!['name']) {
      case 'one':
        return contOne(selectedImages);
      case 'two':
        return contTwo(selectedImages);
      case 'three':
        return contFour(selectedImages);
      case 'four':
        return sixthCont(selectedImages);
      default:
        return contFour(selectedImages);
    }
  }
  return contFour(selectedImages);
}
}
contOne(Map<int, Uint8List> selectedImages){
  return Containers(
    width: 200,
    height: 600,
    color: const Color.fromRGBO(183, 183, 183, 1),
    child: Column(
      children: [
        const SizedBox(height: 23),
        Containers(
          width: 105,
          height: 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: Container(
            color: const Color.fromRGBO(183, 183, 183, 1),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15,
                top: 20,
              ),
              child: Column(
                children: [
                  for (int i = 1; i <= 4; i++) ...[
                    if (i > 1) const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: selectedImages.containsKey(i)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  selectedImages[i]!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : Text(
                                '$i',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    ),
  );
}
 
Widget contTwo(Map<int, Uint8List> selectedImages) {
  return Containers(
    width: 400,
    height: 600,
    color: const Color.fromRGBO(183, 183, 183, 1),
    child: Column(
      children: [
        const SizedBox(height: 23),
        Containers(
          width: 105,
          height: 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: Container(
            color: const Color.fromRGBO(183, 183, 183, 1),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 19),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 1,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                    childAspectRatio: constraints.maxWidth /
                        ((constraints.maxHeight - 16) / 2),
                    padding: EdgeInsets.zero,
                    children: List.generate(2, (index) {
                      final position = index + 1;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: selectedImages.containsKey(position)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  selectedImages[position]!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : Text(
                                '$position',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}

Widget contFour(Map<int, Uint8List> selectedImages) {
  return Containers(
    width: 400,
    height: 600,
    color: const Color.fromRGBO(183, 183, 183, 1),
    child: Column(
      children: [
        const SizedBox(height: 23),
        Containers(
          width: 105,
          height: 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: Container(
            color: const Color.fromRGBO(183, 183, 183, 1),
            child: LayoutBuilder(builder: (context, constraints) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 19),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio:
                      (constraints.maxWidth / 2) / (constraints.maxHeight / 2),
                  padding: EdgeInsets.zero,
                  children: List.generate(4, (index) {
                    final position = index + 1;
                    return Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: selectedImages.containsKey(position)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                selectedImages[position]!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            )
                          : Text(
                              '$position',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ],
    ),
  );
}
 
Widget sixthCont(Map<int, Uint8List> selectedImages) {
  return Containers(
    width: 400,
    height: 600,
    color: const Color.fromRGBO(183, 183, 183, 1),
    child: Column(
      children: [
        const SizedBox(height: 23),
        Containers(
          width: 105,
          height: 7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: Container(
            color: const Color.fromRGBO(183, 183, 183, 1),
            child: LayoutBuilder(builder: (context, constraints) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 19),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  childAspectRatio:
                      (constraints.maxWidth / 2) / (constraints.maxHeight / 3),
                  padding: EdgeInsets.zero,
                  children: List.generate(6, (index) {
                    final position = index + 1;
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: selectedImages.containsKey(position)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                selectedImages[position]!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            )
                          : Text(
                              '$position',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ],
    ),
  );
}