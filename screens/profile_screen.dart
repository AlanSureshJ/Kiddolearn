import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:kiddolearn/screens/login_screen.dart';
import 'package:kiddolearn/screens/send_reset_code_screen.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends StatefulWidget {
  final String email;
  static const String routeName = "/profile";

  const ProfileScreen({required this.email, super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  String? profileImageUrl;
  bool isLoading = true;
  bool hasError = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  /// Fetch user profile data from the backend
  Future<void> fetchProfileData() async {
    try {
      final url =
          Uri.parse('http://192.168.0.141:5000/profile?email=${widget.email}');
      print('📤 Fetching profile data from: $url');

      final response = await http.get(url);
      print('📥 Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        print('✅ Decoded Response: $decodedData');

        setState(() {
          userData = {
            "name": decodedData['name'] ?? "No Name Available",
            "email": decodedData['email'] ?? "No Email",
            "age": decodedData['age']?.toString() ?? "N/A",
            "level": decodedData['level'] ?? "N/A"
          };

          if (decodedData['profile_picture'] != null &&
              decodedData['profile_picture'].isNotEmpty &&
              decodedData['profile_picture'].startsWith('http')) {
            profileImageUrl = decodedData['profile_picture'];
          } else if (decodedData['profile_picture'] != null &&
              decodedData['profile_picture'].isNotEmpty) {
            profileImageUrl =
                'http://192.168.0.141:5000/profile_pics/${decodedData['profile_picture']}';
          } else {
            profileImageUrl = 'assets/default_avatar.png';
          }

          isLoading = false;
          hasError = false;
        });
      } else {
        print('❌ Failed to load profile data. Status: ${response.statusCode}');
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print('❗ Exception occurred: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> updateProfilePicture() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Profile Picture"),
          content: const Text("Choose a photo from gallery or take a new one."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text("Take Photo"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text("Choose from Gallery"),
            ),
          ],
        );
      },
    );

    if (source == null) return; // User canceled

    final XFile? pickedImage = await _picker.pickImage(source: source);
    if (pickedImage == null) return;

    File imageFile = File(pickedImage.path); // ✅ Convert XFile to File

    if (!imageFile.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected image does not exist.')),
      );
      return;
    }

    // Get temp directory to store the compressed image
    final directory = await getTemporaryDirectory();
    final String compressedPath = '${directory.path}/compressed.jpg';

    final File? compressedFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      compressedPath,
      quality: 70, // Adjust quality (lower = more compression)
    ).then((XFile? compressed) =>
        compressed != null ? File(compressed.path) : null);

    if (compressedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to compress image.')),
      );
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.0.141:5000/upload-profile-picture'),
      );

      request.fields['email'] = widget.email;
      request.files
          .add(await http.MultipartFile.fromPath('file', compressedFile.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      if (response.statusCode == 200) {
        setState(() {
          profileImageUrl = jsonResponse['profile_picture'];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile picture updated successfully!')),
        );

        // Refresh profile data
        fetchProfileData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                jsonResponse['error'] ?? 'Failed to update profile picture'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating profile picture')),
      );
    }
  }

  void logout(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  void navigateToResetPassword(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SendResetCodeScreen(email: widget.email)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/b2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : hasError
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Oops! Something went wrong. Please try again.",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: fetchProfileData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Retry"),
                        )
                      ],
                    )
                  : userData == null
                      ? const Text("No data available")
                      : ProfileDetails(
                          userData: userData!,
                          profileImageUrl: profileImageUrl,
                          onUpdateProfilePicture: updateProfilePicture,
                          onLogout: () => logout(context),
                          onChangePassword: () =>
                              navigateToResetPassword(context),
                        ),
        ),
      ),
    );
  }
}

class ProfileDetails extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String? profileImageUrl;
  final VoidCallback onUpdateProfilePicture;
  final VoidCallback onLogout;
  final VoidCallback onChangePassword;

  const ProfileDetails({
    super.key,
    required this.userData,
    required this.profileImageUrl,
    required this.onUpdateProfilePicture,
    required this.onLogout,
    required this.onChangePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onUpdateProfilePicture,
            child: CircleAvatar(
              radius: 70,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!) as ImageProvider
                  : const AssetImage('assets/default_avatar.png'),
              backgroundColor: Colors.transparent,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Name: ${userData['name']}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "Email: ${userData['email']}",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            "Age: ${userData['age']}",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            "Level: ${userData['level']}",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onChangePassword,
            child: const Text("Reset Password"),
          ),
          ElevatedButton(
            onPressed: onUpdateProfilePicture,
            child: const Text("Change Profile Picture"),
          ),
          ElevatedButton(
            onPressed: onLogout,
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
