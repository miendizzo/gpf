import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

List<CameraDescription> cameras = [];

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  void initializeCamera() async {
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller!.initialize();
    setState(() {
      isCameraInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Camera Loading...'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Flue Detection Camera'),
      ),
      body: CameraPreview(controller!),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (controller != null && controller!.value.isInitialized) {
            XFile? imageFile = await controller!.takePicture();
            if (imageFile != null) {
              FirebaseVisionImage visionImage =
                  FirebaseVisionImage.fromFile(File(imageFile.path));
              FaceDetector faceDetector =
                  FirebaseVision.instance.faceDetector();
              List<Face> faces = await faceDetector.processImage(visionImage);

              if (faces.isNotEmpty) {
                print('Face detected!');
              } else {
                print('No face detected. Flu cannot be determined.');
              }
            }
          }
        },
        child: Icon(Icons.camera),
      ),
    );
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }
}
