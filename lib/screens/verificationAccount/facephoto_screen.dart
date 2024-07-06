import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jogfarmv1/screens/verificationAccount/waitverification_screen.dart';
import 'package:path/path.dart' show basename;
import 'package:firebase_auth/firebase_auth.dart';

class FotoWajahScreen extends StatefulWidget {
  @override
  _FotoWajahScreenState createState() => _FotoWajahScreenState();
}

class _FotoWajahScreenState extends State<FotoWajahScreen> {
  CameraController? controller;
  late Future<void> _initializeControllerFuture;
  bool isCameraReady = false;
  bool isProcessing = false;
  File? _image;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
    );

    await controller!.initialize();
    setState(() {
      isCameraReady = true;
    });
  }

  Future<void> _takePicture() async {
    if (!controller!.value.isInitialized) {
      return;
    }

    if (controller!.value.isTakingPicture) {
      return;
    }

    try {
      setState(() {
        isProcessing = true;
      });

      // Ambil gambar dan simpan di directory temporer
      final imageFile = await controller!.takePicture();

      if (imageFile != null) {
        setState(() {
          _image = File(imageFile.path);
        });
        // Upload ke Firebase Storage
        await _uploadFile(_image!);
      }

      setState(() {
        isProcessing = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KonfirmWajahScreen(imagePath: _image!.path),
        ),
      );
    } catch (e) {
      print(e);
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<void> _uploadFile(File file) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      final storageReference = FirebaseStorage.instance
          .ref()
          .child('wajah/${currentUser!.uid}_${basename(file.path)}');
      final uploadTask = storageReference.putFile(file);
      await uploadTask;
      print('File uploaded');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto Wajah'),
      ),
      body: Stack(
        children: <Widget>[
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(controller!);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Letakkan wajah Anda di dalam frame',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: const Color(0xFF2D4739),
              height: 100,
              child: Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.camera,
                    color: Colors.white,
                    size: 50,
                  ),
                  onPressed: _takePicture,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KonfirmWajahScreen extends StatelessWidget {
  final String imagePath;

  KonfirmWajahScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Wajah'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text('Pastikan wajah dapat dilihat dengan jelas'),
            const SizedBox(height: 20),
            Container(
              width: 300,
              child: Center(
                child: Image.file(File(imagePath)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TungguVerifikasiScreen(),
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ulangi'),
            ),
          ],
        ),
      ),
    );
  }
}
