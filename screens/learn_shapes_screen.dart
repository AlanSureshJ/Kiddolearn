import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LearnShapesScreen extends StatefulWidget {
  const LearnShapesScreen({super.key});

  @override
  State<LearnShapesScreen> createState() => _LearnShapesScreenState();
}

class _LearnShapesScreenState extends State<LearnShapesScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the controller and load your asset HTML.
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            print("DEBUG: Page loaded: $url");
          },
          onWebResourceError: (error) {
            print("DEBUG: Web resource error: $error");
          },
        ),
      )
      ..loadFlutterAsset('assets/Kiddo_learning_shapes/index.html')
          .then((_) => print("DEBUG: loadFlutterAsset completed"))
          .catchError((error) {
        print("DEBUG: Error loading Flutter asset: $error");
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KiddoLearn - Learn Shapes'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        backgroundColor: Colors.deepPurple, // Optional: customize as you like
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
