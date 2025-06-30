import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});

  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  // Function to pick image and upload it
  Future<void> pickImage() async {
    final picker = ImagePicker();
    // Pick image from camera
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      // Log the file path
      print("Selected file path: ${pickedFile.path}");

      // Now you can send this file to the server
      uploadFile(pickedFile.path);
    } else {
      print("No image selected");
    }
  }

  // Function to upload the selected file to the server
  Future<void> uploadFile(String filePath) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://192.168.0.141:5000/upload-profile-picture'));

    var file = await http.MultipartFile.fromPath('file', filePath);
    request.files.add(file);

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        print('File uploaded successfully!');
      } else {
        print('Failed to upload file: ${response.statusCode}');
        // Print the response body for more details
        final responseBody = await response.stream.bytesToString();
        print('Response Body: $responseBody');
      }
    } catch (e) {
      print('Error occurred while uploading: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Picture Upload'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: pickImage, // Trigger the pickImage function when pressed
          child: Text('Pick Image'),
        ),
      ),
    );
  }
}
