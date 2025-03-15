import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class ScannerPage extends StatefulWidget {
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  String detectedCategory = "Scanning...";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras!.isEmpty) {
      print("No cameras available");
      return;
    }

    _cameraController = CameraController(
      cameras![0], // Use the back camera
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (!mounted) return;

    setState(() {
      _isCameraInitialized = true;
    });

    // Start scanning every 2 seconds
    Timer.periodic(Duration(seconds: 2), (timer) async {
      if (!mounted || !_isCameraInitialized) return;
      await _scanFrame();
    });
  }

  Future<void> _scanFrame() async {
    if (!_cameraController!.value.isInitialized) return;

    try {
      final XFile image = await _cameraController!.takePicture();
      final String base64Image =
          base64Encode(await File(image.path).readAsBytes());

      // Update UI to show scanning status
      setState(() {
        detectedCategory = "Scanning...";
      });

      // Send image to Google Cloud Vision API
      final String apiKey = "AIzaSyBH87_ZQOe4dUU5lyJEUMlcNAFlhdalsDA";
      final response = await http.post(
        Uri.parse(
            'https://vision.googleapis.com/v1/images:annotate?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "requests": [
            {
              "image": {"content": base64Image},
              "features": [
                {"type": "LABEL_DETECTION", "maxResults": 5}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List labels = data['responses'][0]['labelAnnotations'];

        if (labels.isNotEmpty) {
          String detectedLabel = labels[0]['description'].toLowerCase();
          String category = _categorizeWaste(detectedLabel);

          setState(() {
            detectedCategory = "Detected: $detectedLabel ($category)";
          });
        } else {
          setState(() {
            detectedCategory = "No labels detected";
          });
        }
      } else {
        setState(() {
          detectedCategory = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        detectedCategory = "Error scanning frame";
      });
      print("❌ Error scanning frame: $e");
    }
  }

  String _categorizeWaste(String label) {
    List<String> biodegradable = [
      "banana peel",
      "apple core",
      "leaves",
      "paper"
    ];
    List<String> nonBiodegradable = [
      "plastic bottle",
      "metal can",
      "glass",
      "electronics"
    ];

    if (biodegradable.contains(label)) {
      return "Biodegradable ♻️";
    } else if (nonBiodegradable.contains(label)) {
      return "Non-Biodegradable 🚯";
    } else {
      return "Unknown ❓";
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _isCameraInitialized
              ? CameraPreview(_cameraController!)
              : Center(child: CircularProgressIndicator()),

          // Transparent Google Pay-style scanner overlay
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 4),
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent,
              ),
            ),
          ),

          // Detected waste category text
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  detectedCategory,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
