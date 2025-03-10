import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:pop_and_pose/src/feature/screen/camera/data/camera_repository.dart';
import 'package:pop_and_pose/src/feature/screen/camera/domain/camera_service.dart';

class CameraServiceImpl implements CameraService {
  final CameraRepository _repository;

  CameraServiceImpl(this._repository);

  @override
  Future<bool> discoverCamera() async {
    return await _repository.discoverCamera();
  }

  // Modify this method to return the image bytes as Future<Uint8List>
  @override
  Future<Uint8List> takePicture() async {
    // Capture the image bytes through the repository
    final imageBytes = await _repository.takePicture();
    if (imageBytes == null) {
      throw Exception('Failed to capture image.');
    }
    return imageBytes; // Return the image data as Uint8List
  }

  @override
  Future<http.Response?> startLiveView() async {
    return await _repository.startLiveView();
  }

  @override
  Future<Stream<Uint8List?>> fetchLiveView() async {
    return await _repository.fetchLiveView();
  }

  @override
  Future<List<String>?> getThumbnailsList() async {
    return await _repository.getThumbnailsList();
  }

  @override
  Future<void> stopLiveView() async {
    return await _repository.stopLiveView();
  }

  @override
  Future<void> setISO(int value) async {
    await _repository.setISO(value);
  }

  @override
  Future<void> setWhiteBalance(String value) async {
    await _repository.setWhiteBalance(value);
  }
}
