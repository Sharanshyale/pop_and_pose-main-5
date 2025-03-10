import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pop_and_pose/src/constant/app_spaces.dart';
import 'package:pop_and_pose/src/constant/colors.dart';
import 'package:pop_and_pose/src/feature/screen/choose_screen/page/choose_screen.dart';
import 'package:pop_and_pose/src/feature/screen/num_of_copies/widget/btn.dart';
import 'package:pop_and_pose/src/feature/widgets/app_btn.dart';
import 'package:pop_and_pose/src/feature/widgets/app_texts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                                  hint:  const Texts(
                                  texts: "Select Shutter Speed",
                                  fontSize: 18,
                                  color: AppColor.textColorGrey,
                                  fontWeight: FontWeight.w800,
                                ),
                                 // value: selectedShutterSpeed, 
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: AppColor.kAppColorGrey),
                                    ),
                                  ),
                                  items: ['5', '2', '3'] 
                                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
                                  hint:  const Texts(
                                  texts: "Aperture",
                                  fontSize: 18,
                                  color: AppColor.textColorGrey,
                                  fontWeight: FontWeight.w800,
                                ),
                                  //value: selectedAperture,  
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder()),
                                  items: ["1", "4", "8"]
                                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedAperture = val;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                hint:  const Texts(
                                  texts: "Select ISO",
                                  fontSize: 18,
                                  color: AppColor.textColorGrey,
                                  fontWeight: FontWeight.w800,
                                ),
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder()),
                                  items: ["1", "2", "4"]
                                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedISO = val;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
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
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
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
