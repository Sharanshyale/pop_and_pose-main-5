import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pop_and_pose/src/constant/api_constants.dart';

class RegisterDevice extends StatefulWidget {
  const RegisterDevice({super.key});

  @override
  State<RegisterDevice> createState() => _RegisterDeviceState();
}

class _RegisterDeviceState extends State<RegisterDevice> {
   final _formKey = GlobalKey<FormState>();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();
  String? _deviceInfo;
    @override
  void initState() {
    super.initState();
    _getDeviceInfo();
  }

  Future<void> _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
   IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
 
    setState(() {
      _deviceInfo = iosInfo.model;
    });
  }
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String latitude = _latController.text;
      String longitude = _longController.text;
      String device = _deviceInfo ?? "Unknown Device";
 
      Map<String, String> requestBody = {
        "latitude": latitude,
        "longitude": longitude,
        "device_name": device,
        "device_key":''
      };
 
      try {
var response = await http.post(
Uri.parse(BaseurlForBackend.registerDevice),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(requestBody),
        );
 
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location submitted successfully!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to submit location!")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body:  Container(
        
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _latController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Latitude"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter latitude";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _longController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Longitude"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter longitude";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      ));
  }
}

