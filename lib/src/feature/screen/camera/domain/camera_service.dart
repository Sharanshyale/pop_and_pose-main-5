import 'dart:typed_data';

import 'package:http/http.dart' as http;

abstract class CameraService {
  Future<bool> discoverCamera();
  Future<Uint8List> takePicture(); // Change this method to return Uint8List
  Future<http.Response?> startLiveView();
  Future<void> stopLiveView();
  Future<Stream<Uint8List?>> fetchLiveView();
  Future<List<String>?> getThumbnailsList();
  Future<void> setISO(int value);
  Future<void> setWhiteBalance(String value);
}
