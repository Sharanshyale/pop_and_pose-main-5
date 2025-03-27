import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;
import 'package:pop_and_pose/src/constant/colors.dart';
import 'package:pop_and_pose/src/feature/screen/num_of_copies/widget/btn.dart';
import 'package:pop_and_pose/src/feature/screen/select_photo/page/select_photos.dart';
import 'package:pop_and_pose/src/feature/widgets/app_btn.dart';
import 'package:pop_and_pose/src/feature/widgets/app_texts.dart';
import 'package:pop_and_pose/src/utils/getDeviceInfo.dart';

class Framebackground extends StatefulWidget {
  final String userId1;
  const Framebackground({super.key, required this.userId1});

  @override
  State<Framebackground> createState() => _FramebackgroundState();
}

class _FramebackgroundState extends State<Framebackground> {
  List<String> imageUrls = [];
  int rows = 3;
  int columns = 2;
  double padding = 10.0;
  double horizontalGap = 10.0;
  double verticalGap = 10.0;
  String frameImage = '';
  String userId1 = '';
  String? backgroundImageUrl;
  String? deviceModel;
  String imageShape = 'circle';

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
    fetchUserData();
  }

  Future<void> _getDeviceInfo() async {
    List<String> deviceInfo = await Getdeviceinformation().getDevice();

    setState(() {
      deviceModel = deviceInfo[0];
    });

    if (deviceModel != null) {
      String? imageUrl = await Getdeviceinformation().fetchBackgroundImage(deviceModel!);
      setState(() {
        backgroundImageUrl = imageUrl;
      });
    }
  }

  Future<void> fetchUserData() async {
    final url = Uri.parse(
     'https://pop-pose-backend.vercel.app/api/user/getDetailsByUserId/${widget.userId1}');

    try {
      final response = await http.get(url);
      print('Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];

        // Safely parsing the data with null checks
        setState(() {
          imageUrls = List<String>.from(user['image_captured'] ?? []);
          final frameSelection = user['frame_Selection'];

          rows = frameSelection['rows'] ?? 3;  
          columns = frameSelection['columns'] ?? 2; 
          padding = (frameSelection['padding'] ?? 10).toDouble();  
          horizontalGap = (frameSelection['horizontal_gap'] ?? 10).toDouble();
          verticalGap = (frameSelection['vertical_gap'] ?? 10).toDouble(); 
          frameImage = frameSelection['image'] ?? '';
          imageShape = frameSelection['shapes'] ?? 'circle';  
        });

        print('Rows: $rows');
        print('Columns: $columns');
        print('Padding: $padding');
        print('Horizontal Gap: $horizontalGap');
        print('Vertical Gap: $verticalGap');
        print('Frame Image: $frameImage');
        print('Image Shape: $imageShape');
        print('Image URLs: $imageUrls');
      } else {
        print('Failed to load user data. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }


Future<void> deleteImages(String userId) async {
  final url = Uri.parse("https://pop-pose-backend.vercel.app/api/user/deleteImagesByUserId/${widget.userId1}");
  try{
    final response = await http.delete(url,headers: {
        'Content-Type': 'application/json',
      },);

    if (response.statusCode == 200) {
      print('Images deleted successfully.');
    } else {
      print('Failed to delete images. Status Code: ${response.statusCode}');
    }
  }catch(e){
    print('Error deleting images: $e');
  }
  }

  Widget buildImageShape(String shape, String imageUrl) {
    switch (shape.toLowerCase()) {
      case 'circle':
        return ClipOval(
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            height: 100, // Fixed size for circle
            width: 100,
          ),
        );
      case 'rectangle':
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            height: 100, // Fixed height for rectangle
            width: 150, // Fixed width for rectangle
          ),
        );
      default:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            height: 100, // Default square size
            width: 100,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final imageSize = screenWidth * (screenWidth > 600 ? 0.3 : 0.5);

        return Stack(
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.75,
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
                    child: Row(
                      children: [
                       Expanded(child: Container(width: 400,color: Colors.black,)),
                        Expanded(
                       
                          child: Padding(
                            padding: EdgeInsets.all(padding),
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns, 
                                crossAxisSpacing: horizontalGap,
                                mainAxisSpacing: verticalGap,
                              ),
                              itemCount: imageUrls.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.all(padding),
                                  child: buildImageShape(imageShape, imageUrls[index]),
                                );
                              },
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                  Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
              
              
                               Btn(
                            onTap: () { 
                             deleteImages(widget.userId1);
                                    Get.offAll(() =>  PhotoSelector(userId: widget.userId1,));
                            },
                            width: 150,
                            child: const Texts(
                              texts: 'Back',
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: AppColor.kAppColor,
                            ),
                          ),
                          
                              const SizedBox(width: 20),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 150,
                                  minWidth: 120,
                                ),
                                child: AppBtn(
                                  onTap: () {
                                  
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
                        )
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
