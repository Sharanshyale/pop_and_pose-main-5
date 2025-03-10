// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
// import 'package:googleapis/drive/v3.dart' as drive;

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({super.key});

  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  // File? _imageFile;
  // final picker = ImagePicker();
  // bool _isUploading = false;
  // String _status = '';

  // // Google Sign-In instance with your client ID
  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //   clientId:
  //       '149277559281-38ihem5erq2kh8hkcvted0qghu5e309i.apps.googleusercontent.com', // Add your iOS client ID
  //   scopes: [
  //     'https://www.googleapis.com/auth/drive.file',
  //   ],
  // );

  // Future<void> _pickImage(ImageSource source) async {
  //   try {
  //     final pickedFile = await picker.pickImage(source: source);
  //     setState(() {
  //       if (pickedFile != null) {
  //         _imageFile = File(pickedFile.path);
  //         _status = 'Image selected';
  //       }
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _status = 'Error picking image: $e';
  //     });
  //     _showSnackBar(_status);
  //   }
  // }

  // Future<bool> _handleSignIn() async {
  //   try {
  //     final account = await _googleSignIn.signIn();
  //     if (account == null) {
  //       _status = 'Sign-in cancelled by user';
  //       _showSnackBar(_status);
  //       return false;
  //     }
  //     _status = 'Signed in as ${account.email}';
  //     _showSnackBar(_status);
  //     return true;
  //   } catch (error) {
  //     _status = 'Sign-in failed: $error';
  //     _showSnackBar(_status);
  //     return false;
  //   }
  // }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Future<void> _uploadPhotoToDrive() async {
  //   if (_imageFile == null) {
  //     _status = 'No image selected';
  //     _showSnackBar(_status);
  //     return;
  //   }

  //   setState(() {
  //     _isUploading = true;
  //     _status = 'Starting upload...';
  //   });

  //   try {
  //     // Check if user is signed in
  //     final currentUser = _googleSignIn.currentUser;
  //     if (currentUser == null) {
  //       final signedIn = await _handleSignIn();
  //       if (!signedIn) {
  //         throw Exception('Not signed in');
  //       }
  //     }

  //     // Get auth headers
  //     final headers = await _googleSignIn.currentUser!.authHeaders;
  //     final client = GoogleAuthClient(headers);

  //     // Create Drive API client
  //     final driveApi = drive.DriveApi(client);

  //     setState(() {
  //       _status = 'Uploading to Drive...';
  //     });

  //     // Prepare file metadata
  //     var driveFile = drive.File();
  //     final timestamp = DateTime.now().millisecondsSinceEpoch;
  //     driveFile.name = 'flutter_upload_$timestamp.jpg';
  //     driveFile.mimeType = 'image/jpeg';

  //     // Create file on Drive
  //     final media =
  //         drive.Media(_imageFile!.openRead(), _imageFile!.lengthSync());
  //     final result = await driveApi.files.create(
  //       driveFile,
  //       uploadMedia: media,
  //     );

  //     setState(() {
  //       _status = 'Upload complete! File ID: ${result.id}';
  //     });
  //     _showSnackBar('File uploaded successfully');
  //   } catch (error) {
  //     _status = 'Upload failed: $error';
  //     _showSnackBar(_status);
  //   } finally {
  //     setState(() {
  //       _isUploading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload to Drive (iOS)'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // children: [
          //   if (_imageFile != null) ...[
          //     Expanded(
          //       child: Image.file(
          //         _imageFile!,
          //         fit: BoxFit.contain,
          //       ),
          //     ),
          //     const SizedBox(height: 20),
          //   ],
          //   Text(
          //     _status,
          //     textAlign: TextAlign.center,
          //     style: const TextStyle(fontSize: 16),
          //   ),
          //   const SizedBox(height: 20),
          //   ElevatedButton.icon(
          //     onPressed: () => _pickImage(ImageSource.gallery),
          //     icon: const Icon(Icons.photo_library),
          //     label: const Text('Select from Gallery'),
          //   ),
          //   const SizedBox(height: 10),
          //   ElevatedButton.icon(
          //     onPressed: _isUploading ? null : _uploadPhotoToDrive,
          //     icon: _isUploading
          //         ? const SizedBox(
          //             width: 24,
          //             height: 24,
          //             child: CircularProgressIndicator(strokeWidth: 2),
          //           )
          //         : const Icon(Icons.cloud_upload),
          //     label: Text(_isUploading ? 'Uploading...' : 'Upload to Drive'),
          //   ),
          // ],
        ),
      ),
    );
  }
}

// Helper class for authenticated requests
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
