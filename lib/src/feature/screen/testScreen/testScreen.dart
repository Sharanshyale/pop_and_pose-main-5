import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:pop_and_pose/src/constant/api_constants.dart';

class Testscreen extends StatefulWidget {
  const Testscreen({super.key});

  @override
  State<Testscreen> createState() => _TestscreenState();
}

class _TestscreenState extends State<Testscreen> {
  GlobalKey _repaintBoundaryKey = GlobalKey();
  List<Map<String, dynamic>> framesData = [];
  Map<String, dynamic>? selectedFrame;

  @override
  void initState() {
    super.initState();
    fetchFrames();
  }

  Future<void> fetchFrames() async {
    try {
      final response = await http.get(Uri.parse(BaseurlForBackend.getFrames)); // Use your API endpoint here

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final framesList = data['frames'] as List;
        setState(() {
          framesData = framesList.map((frame) {
            return {
              'name': frame['frame_size'] ?? 'Unnamed Frame',
              'price': '₹${frame['price'] ?? 0}',
              'image': frame['image'] ?? '',
              'id': frame['_id'] ?? '',
              'rows': frame['rows'] ?? 1,
              'columns': frame['columns'] ?? 1,
              'index': frame['index'] ?? 0,
              'orientation': frame['orientation'] ?? 'horizontal',
              'no_of_photos': frame['no_of_photos'] ?? 1,
              'background': frame['background'] ?? [
                'https://www.example.com/photo1.jpg',
                'https://www.example.com/photo2.jpg',
                'https://www.example.com/photo3.jpg'
              ],
              'padding': frame['padding'] ?? 0,
              'horizontal_gap': frame['horizontal_gap'] ?? 0,
              'vertical_gap': frame['vertical_gap'] ?? 0,
            };
          }).toList();

          // Set the first frame as the default selected frame
          if (framesData.isNotEmpty) {
            selectedFrame = framesData[0];
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load frames')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching data: $error')));
    }
  }

  Widget _buildPhotoFrame(Map<String, dynamic> frame) {
    final orientation = frame['orientation'];
    final noOfPhotos = frame['no_of_photos'];
    final rows = frame['rows'];
    final columns = frame['columns'];
    final padding = frame['padding'];
    final horizontalGap = frame['horizontal_gap'];
    final verticalGap = frame['vertical_gap'];
    final background = frame['background'];

    // Generate photos dynamically based on no_of_photos
    final photos = List.generate(noOfPhotos, (index) {
      return Container(
        color: Colors.grey[300], // Placeholder color for photos
        child: Center(child: Text('Photo ${index + 1}')),
      );
    });

    return RepaintBoundary(
      key: _repaintBoundaryKey,
      child: Container(
        padding: EdgeInsets.all(padding.toDouble()),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Stack(
          children: [
            // Display background images
            if (background.isNotEmpty)
              ...background.map((imageUrl) {
                return Positioned.fill(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover, // Cover the entire frame
                  ),
                );
              }).toList(),

            // Display photos
            orientation.toLowerCase() == 'horizontal'
                ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: horizontalGap.toDouble(),
                      mainAxisSpacing: verticalGap.toDouble(),
                      childAspectRatio: 1,
                    ),
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      return photos[index];
                    },
                  )
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: horizontalGap.toDouble(),
                      mainAxisSpacing: verticalGap.toDouble(),
                      childAspectRatio: 1,
                    ),
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      return photos[index];
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureAndSaveWidget() async {
    try {
      RenderRepaintBoundary boundary =
          _repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List uint8List = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/captured_frame.png';

      File imageFile = File(imagePath);
      await imageFile.writeAsBytes(uint8List);
      print(imagePath);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image saved at $imagePath')));
      await ImageGallerySaver.saveFile(imagePath);
    } catch (e) {
      print('Error capturing widget: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to capture image')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Frames'),
      ),
      body: selectedFrame == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              height: 600, // Adjust height as needed
              child: Column(
                children: [
                  Expanded(
                    child: _buildPhotoFrame(selectedFrame!),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Frame Size: ${selectedFrame!['name']}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Price: ${selectedFrame!['price']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _captureAndSaveWidget, // Capture and save the frame as an image
                    child: const Text('Capture and Save Frame'),
                  ),
                ],
              ),
            ),
    );
  }
}
