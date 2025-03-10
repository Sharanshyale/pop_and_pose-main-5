import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:pop_and_pose/src/feature/screen/camera/data/camera_api.dart';
import 'package:pop_and_pose/src/feature/screen/camera/data/ssdp_discovery_.dart';

class CameraRepository {
  final SSDPDiscovery discovery;
  CameraApi? _cameraApi;

  CameraRepository(this.discovery);

  // Centralized method to ensure _cameraApi is not null
  CameraApi _ensureCameraApi() {
    if (_cameraApi == null) {
      throw Exception("Camera not discovered. Call discoverCamera first.");
    }
    return _cameraApi!;
  }

  // Modify discoverCamera to initialize CameraApi with the discovered baseUrl
  Future<bool> discoverCamera() async {
    final baseUrl = await discovery.sendSSDPRequest();
    if (baseUrl != null) {
      _cameraApi = CameraApi(baseUrl);
      return true;
    }
    return false;
  }

  // Modify takePicture to return the image bytes as Uint8List
  Future<Uint8List?> takePicture() async {
    _ensureCameraApi();
    // Capture the image and return the image data as Uint8List
    final imageBytes = await _cameraApi!.takePicture();
    return imageBytes; // Return the image data as Uint8List
  }

  Future<http.Response?> startLiveView() async {
    _ensureCameraApi();
    return await _cameraApi!.startLiveView();
  }

  Future<Stream<Uint8List>> fetchLiveView() async {
    _ensureCameraApi();
    return await _cameraApi!.startFetchingLiveView();
  }

  Future<List<String>?> getThumbnailsList() async {
    _ensureCameraApi();
    return await _cameraApi!.getThumbnailsList();
  }

  Future<void> stopLiveView() async {
    _ensureCameraApi();
    await _cameraApi!.stopLiveView();
  }

  Future<void> setISO(int value) async {
    _ensureCameraApi();
    await _cameraApi!.setISO(value);
  }

  Future<void> setWhiteBalance(String value) async {
    _ensureCameraApi();
    await _cameraApi!.setWhiteBalance(value);
  }
}
