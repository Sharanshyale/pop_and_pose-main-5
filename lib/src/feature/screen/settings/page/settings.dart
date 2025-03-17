import 'dart:io';
 
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pop_and_pose/src/constant/colors.dart';

import 'package:pop_and_pose/src/feature/screen/num_of_copies/widget/btn.dart';
import 'package:pop_and_pose/src/feature/widgets/app_btn.dart';
import 'package:pop_and_pose/src/feature/widgets/app_texts.dart';
import 'package:shared_preferences/shared_preferences.dart';
 
import 'package:http/http.dart' as http;
 
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
 
  @override
  _SettingsPageState createState() => _SettingsPageState();
}
 
class _SettingsPageState extends State<SettingsPage> {
  String? selectedShutterSpeed;
  String? selectedAperture;
  String? selectedISO;
  bool ledRingFlash = false;
  String selectedWhiteBalance = "Cloudy";
  File? _selectedImage;
  bool _isUploading = false;
 
  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }
 
  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedShutterSpeed = prefs.getString('option1') ?? '5';
      selectedAperture = prefs.getString('option2') ?? '1';
      selectedISO = prefs.getString('option3') ?? '1';
      ledRingFlash = prefs.getBool('isToggled') ?? false;
    });
  }
 
  Future<File?> pickImage() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      return image != null ? File(image.path) : null;
    } else {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);
      return result != null ? File(result.files.single.path!) : null;
    }
  }
 
  Future<void> uploadImage(String deviceKey, File imageFile) async {
    var url = Uri.parse(
        'https://pop-pose-backend.vercel.app/api/background/update-background-image');
 
    var request = http.MultipartRequest('PUT', url);
    request.fields['device_key'] = deviceKey;
    request.files.add(await http.MultipartFile.fromPath(
      'background_image',
      imageFile.path,
    ));
 
    try {
      setState(() => _isUploading = true);
      var response = await request.send();
      setState(() => _isUploading = false);
 
      if (response.statusCode == 200) {
        print("Image uploaded successfully!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image uploaded successfully!")),
        );
      } else {
        print("pload failed: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upload failed!")),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error uploading image!")),
      );
    }
  }
 
  void selectAndUploadImage() async {
    File? imageFile = await pickImage();
 
    if (imageFile != null) {
      setState(() => _selectedImage = imageFile);
      await uploadImage('Hello device 2', imageFile);
    }
  }
 
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('option1', selectedShutterSpeed ?? '5');
    await prefs.setString('option2', selectedAperture ?? '1');
    await prefs.setString('option3', selectedISO ?? '1');
    await prefs.setBool('isToggled', ledRingFlash);
    _printSavedSettings();
  }

  Future<void> _printSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    print('------------------------------------');
    print('Saved settings:');
    print('Option 1: ${prefs.getString('option1')}');
    print('Option 2: ${prefs.getString('option2')}');
    print('Option 3: ${prefs.getString('option3')}');
    print('Toggle: ${prefs.getBool('isToggled')}');
    print('------------------------------------');
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'images/background.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Container(
              width: 700,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              margin: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: AppColor.kAppColorWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Texts(
                                  texts: "Settings",
                                  fontSize: 28,
                                  color: AppColor.textColorBlack,
                                  fontWeight: FontWeight.w800,
                                ),
                                const SizedBox(height: 20),
                                const Texts(
                                  texts: "Shutter Speed",
                                  fontSize: 18,
                                  color: AppColor.textColorBlack,
                                  fontWeight: FontWeight.w600,
                                ),
                                DropdownButtonFormField<String>(
                                  hint: const Texts(
                                    texts: "Select Shutter Speed",
                                    fontSize: 18,
                                    color: AppColor.textColorGrey,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  // value: selectedShutterSpeed,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColor.kAppColorGrey),
                                    ),
                                  ),
                                  items: ['5', '2', '3']
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text(e)))
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedShutterSpeed = val;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                const Texts(
                                  texts: "Aperture",
                                  fontSize: 18,
                                  color: AppColor.textColorBlack,
                                  fontWeight: FontWeight.w600,
                                ),
                                DropdownButtonFormField<String>(
                                  hint: const Texts(
                                    texts: "Aperture",
                                    fontSize: 18,
                                    color: AppColor.textColorGrey,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  //value: selectedAperture,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder()),
                                  items: ["1", "4", "8"]
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text(e)))
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedAperture = val;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Texts(
                                      texts: "LED Ring Flash",
                                      fontSize: 18,
                                      color: AppColor.textColorBlack,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    Switch(
                                      value: ledRingFlash,
                                      onChanged: (val) {
                                        setState(() {
                                          ledRingFlash = val;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Texts(
                                  texts: "ISO",
                                  fontSize: 18,
                                  color: Color.fromRGBO(21, 20, 38, 1),
                                  fontWeight: FontWeight.w600,
                                ),
                                DropdownButtonFormField<String>(
                                  //  value: selectedISO,
                                  hint: const Texts(
                                    texts: "Select ISO",
                                    fontSize: 18,
                                    color: AppColor.textColorGrey,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder()),
                                  items: ["1", "2", "4"]
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text(e)))
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedISO = val;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: selectAndUploadImage,
                                  child: Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: _selectedImage == null
                                        ? const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.cloud_upload,
                                                  size: 30, color: Colors.grey),
                                              SizedBox(height: 10),
                                              Text(
                                                  "Tap to upload background image",
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                            ],
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.file(_selectedImage!,
                                                fit: BoxFit.cover),
                                          ),
                                  ),
                                ),
                                const Texts(
                                  texts: "White Balance",
                                  fontSize: 18,
                                  color: AppColor.textColorBlack,
                                  fontWeight: FontWeight.w600,
                                ),
                                Column(
                                  children: [
                                    _buildRadio("Cloudy"),
                                    _buildRadio("Daylight"),
                                    _buildRadio("Tungsten"),
                                    _buildRadio("Auto"),
                                    _buildRadio("Shade"),
                                    _buildRadio("White Fluorescent Light"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              const Texts(
                                texts: "Live Monitor",
                                fontSize: 28,
                                color: AppColor.textColorBlack,
                                fontWeight: FontWeight.w800,
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: 400,
                                height: 400,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  color: AppColor.kAppColorGrey,
                                ),
                              ),
                              const SizedBox(height: 100),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Btn(
                                    onTap: () {},
                                    width: 150,
                                    child: const Texts(
                                      texts: 'Back',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.textColorBlack,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  AppBtn(
                                    onTap: _saveSettings,
                                    width: 150,
                                    child: const Texts(
                                      texts: 'Save',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.textColorWhite,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildRadio(String value) {
    return RadioListTile<String>(
      title: Text(value),
      value: value,
      groupValue: selectedWhiteBalance,
      onChanged: (val) {
        setState(() {
          selectedWhiteBalance = val!;
        });
      },
    );
  }
}