import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;

class Getdeviceinformation{

  Future<List<String>> getDevice() async {
     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
 
   return[iosInfo.model,iosInfo.modelName];
  }
Future<String?> fetchBackgroundImage(String deviceModel) async {
    final String apiUrl =
        'https://pop-pose-backend.vercel.app/api/background/getDeviceById/$deviceModel';
 
    try {
      final response = await http.get(Uri.parse(apiUrl));
 
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body); 
        return  data['background_image'];
       
      } else {
        print('Failed to load background image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching background image: $e');
       return null;
    }
   
  }
  
}