import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageContainerScreen extends StatefulWidget {
  const ImageContainerScreen({super.key});

  @override
  State<ImageContainerScreen> createState() => _ImageContainerScreenState();
}

class _ImageContainerScreenState extends State<ImageContainerScreen> {
  // Controller for taking screenshot
  ScreenshotController screenshotController = ScreenshotController();

  final List<String> imageUrls = [
    'images/icon.png',
    'images/doodle.png',
    'images/saly.png',
  ];

  Future<void> _captureAndSave() async {
    try {
      // Capture the container as an image
      final Uint8List? imageBytes = await screenshotController.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 1.0,
      );

      if (imageBytes != null) {
        // Get the app's documents directory
        final directory = await getApplicationDocumentsDirectory();
        final filePath =
            '${directory.path}/container_screenshot_${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Save the image to the file
        final file = File(filePath);
        await file.writeAsBytes(imageBytes);

        // Provide feedback to the user
        if (await file.exists()) {
          _showSnackBar('Image saved successfully! Path: $filePath');
        } else {
          _showSnackBar('Failed to save image');
        }
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> saveFile(String fileName, Uint8List fileBytes) async {
    try {
      // Get the app's document directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // Write the file
      await file.writeAsBytes(fileBytes);

      print('File saved at: $filePath');
    } catch (e) {
      print('Error saving file: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Container Screenshot'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container to be captured
            Screenshot(
              controller: screenshotController,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: imageUrls.map((url) {
                    return Image.asset(
                      url,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Download button
            ElevatedButton(
              onPressed: _captureAndSave,
              child: const Text('Download as JPG'),
            ),
          ],
        ),
      ),
    );
  }
}
