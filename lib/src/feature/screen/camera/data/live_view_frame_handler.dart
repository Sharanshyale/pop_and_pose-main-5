import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:pop_and_pose/src/utils/log.dart';

class LiveViewFrameHandler {
  final String baseUrl;
  final StreamController<Uint8List> _liveViewController = StreamController<Uint8List>.broadcast();
  final List<int> _imageDataBuffer = [];
  bool _isFetchingLiveView = false;

  LiveViewFrameHandler(this.baseUrl);

  Stream<Uint8List> get liveViewStream => _liveViewController.stream;

  // Start fetching live view stream
  Future<void> startFetchingLiveView(Uri url) async {
    final client = HttpClient();
    try {
      _isFetchingLiveView = true;
      while (_isFetchingLiveView) {
        final request = await client.getUrl(url);
        final response = await request.close();

        if (response.statusCode == 200) {
          // Process chunks as they come in
          await for (final chunk in response) {
            _processChunk(chunk);
          }
        } else {
          Log.e("Error: Unable to start live view, status code: ${response.statusCode}");
        }

        // Retry if the live view is not available (black image received)
        if (_imageDataBuffer.isEmpty) {
          Log.d("Live view unavailable, retrying...");
          await Future.delayed(const Duration(milliseconds: 200)); // Add delay before retry
        }
      }
    } catch (e) {
      Log.e("Exception during live view fetching: $e");
    } finally {
      client.close();
    }
  }

  // Check if the buffer contains valid JPEG markers (SOI and EOI)
  bool _hasValidJPEGMarkers(List<int> buffer) {
    return buffer.isNotEmpty &&
           buffer[0] == 0xFF && buffer[1] == 0xD8 && // SOI marker
           buffer[buffer.length - 2] == 0xFF && buffer[buffer.length - 1] == 0xD9; // EOI marker
  }

  // Process each chunk of data
  void _processChunk(List<int> chunk) {
    _imageDataBuffer.addAll(chunk);

    if (_hasValidJPEGMarkers(_imageDataBuffer)) {
      final jpegData = Uint8List.fromList(_imageDataBuffer);

      // Decode the image to check its dimensions and content
      final bitmap = decodeImage(jpegData);

      if (bitmap != null && !(bitmap.width == 160 && bitmap.height == 120)) {
        // Only push the image if it's not the black 160x120 image
        Log.d('Valid image received: ${bitmap.width}x${bitmap.height}');
        if (!_liveViewController.isClosed) {
          _liveViewController.add(jpegData);  // Push valid frame to the stream
        }
      } else {
        // This is a black image (160x120), ignore it
        Log.d('Received black image (160x120), skipping...');
      }

      // Clear the buffer to prepare for the next frame
      _imageDataBuffer.clear();
    }
  }

  // Stop fetching live view
  void stopFetchingLiveView() {
    _isFetchingLiveView = false;
    _liveViewController.close();
  }
}
