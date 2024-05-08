import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

class HeadacheDetectorScreen extends StatefulWidget {
  @override
  _HeadacheDetectorScreenState createState() => _HeadacheDetectorScreenState();
}

class _HeadacheDetectorScreenState extends State<HeadacheDetectorScreen> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isDetecting = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.high);
    await _cameraController.initialize();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _loadModel() async {
    await Tflite.loadModel(
      model: 'assets/headache_model.tflite',
      labels: 'assets/headache_labels.txt',
    );
  }

  Future<void> _captureImage() async {
    if (_cameraController.value.isInitialized) {
      setState(() {
        _isDetecting = true;
      });
      final image = await _cameraController.takePicture();
      await _processImage(image.path);
    }
  }

  Future<void> _processImage(String imagePath) async {
    setState(() {
      _isProcessing = true;
    });

    // Perform image processing and inference using TensorFlow Lite
    // Replace this with your TensorFlow Lite model inference code
    // Example:
    // var results = await Tflite.runModelOnImage(
    //   path: imagePath,
    // );
    // Handle the results and display them to the user
    setState(() {
      _isProcessing = false;
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Headache Detector'),
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isProcessing
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _isDetecting ? null : _captureImage,
                      child:
                          Text(_isDetecting ? 'Detecting...' : 'Capture Image'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HeadacheDetectorScreen(),
  ));
}
