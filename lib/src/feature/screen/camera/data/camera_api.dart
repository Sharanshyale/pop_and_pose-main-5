import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pop_and_pose/src/constant/api_constants.dart';
import 'package:pop_and_pose/src/feature/screen/camera/data/live_view_frame_handler.dart';
import 'package:pop_and_pose/src/feature/screen/camera/presentation/bloc/camera_state.dart';
import 'package:pop_and_pose/src/utils/api_service.dart';
import 'package:pop_and_pose/src/utils/log.dart';

class CameraApi {
  final String _baseUrl;
  late final LiveViewFrameHandler handler;

  CameraApi(this._baseUrl) {
    handler = LiveViewFrameHandler(_baseUrl);
  }

  // Modify this method to return the image as bytes
  Future<Uint8List?> takePicture() async {
    Log.d('Base Url is $_baseUrl');

    try {
      final response = await ApiService.sendPostRequest(
          '$_baseUrl${CameraAPIConstants.takePictureUrl}', {
        CameraAPIConstants.autoFocus: true,
      });

      if (response.statusCode == 200) {
        Log.d("Image captured, bytes length: ${response.bodyBytes.length}");
        return response.bodyBytes; // Return the image as a byte array
      } else {
        throw Exception('Failed to capture image');
      }
    } catch (e) {
      Log.e("Error in takePicture: $e");
      throw Exception('Error capturing image: $e');
    }
  }

  Future<http.Response?> startLiveView() async {
    final shootingLiveviewUrl = '$_baseUrl${CameraAPIConstants.liveViewUrl}';

    return ApiService.sendPostRequest(shootingLiveviewUrl, {
      CameraAPIConstants.liveViewSize: "small",
      CameraAPIConstants.cameraDisplay: "on",
      CameraAPIConstants.quality: "normal",
    });
  }

  Future<Stream<Uint8List>> startFetchingLiveView() async {
    final liveViewUrl =
        Uri.parse('$_baseUrl${CameraAPIConstants.liveViewScrollUrl}');
    handler.startFetchingLiveView(liveViewUrl);

    return handler.liveViewStream;
  }

  Future<void> stopLiveView() async {
    final stopLiveViewUrl = '$_baseUrl${CameraAPIConstants.liveViewScrollUrl}';
    handler.stopFetchingLiveView();

    ApiService.sendDeleteRequest(stopLiveViewUrl);
  }

  Future<void> setISO(int value) async {
    final String url = '$_baseUrl$CameraAPIConstants.isoUrl';

    ApiService.sendPutRequest(url, {
      CameraAPIConstants.iosValue: value,
    });
  }

  Future<void> setWhiteBalance(String value) async {
    final String url = '$_baseUrl$CameraAPIConstants.wbUrl';

    ApiService.sendPutRequest(url, {
      CameraAPIConstants.value: value,
    });
  }

  Future<List<String>> getThumbnailsList() async {
    try {
      // Step 1: Get contents root
      final contentsData =
          await _fetchJSON('$_baseUrl${CameraAPIConstants.contentsUrl}');
      final sdUrl = contentsData[CameraAPIConstants.url][0];

      // Step 2: Get SD Card folders
      final foldersData = await _fetchJSON(sdUrl);
      final latestFolder =
          _findLatestFolder(foldersData[CameraAPIConstants.url]);

      // Step 3: Get folder contents
      final listData = await _fetchJSON('$latestFolder?kind=list');
print("data is ${_extractThumbnailUrls(listData[CameraAPIConstants.url])}");

      return _extractThumbnailUrls(listData[CameraAPIConstants.url]);
      
    } catch (e) {
      // Rethrow the error wrapped in a Future to match the return type
      return Future.error(
          CameraError("Failed to get the image URL list: ${e.toString()}"));
    }
  }

  Future<Map<String, dynamic>> _fetchJSON(String endPoint) async {
    final response = await ApiService.sendGetRequest(endPoint);

    if (response.statusCode != 200) {
      throw CameraError(
          'Failed to fetch JSON from endpoint $endPoint : ${response.statusCode}');
    }
    return jsonDecode(response.body);
  }

  String _findLatestFolder(List<dynamic> folders) {
    return folders.reduce((a, b) {
      final aNum =
          int.parse(a.split('/').last.replaceAll(RegExp(r'[^\d]'), ''));
      final bNum =
          int.parse(b.split('/').last.replaceAll(RegExp(r'[^\d]'), ''));
      return aNum > bNum ? a : b;
    });
  }

  List<String> _extractThumbnailUrls(List<dynamic> urls) {
    return urls
        .map((url) =>
            url.contains('?') ? '$url&kind=display' : '$url?kind=display')
        .toList()
        .reversed
        .take(8)
        .toList()
        .reversed
        .toList();

  }
  
  
}
