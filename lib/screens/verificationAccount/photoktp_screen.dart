import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jogfarmv1/screens/verificationAccount/facephoto_screen.dart';
import 'package:path/path.dart' show basename;
import 'package:firebase_auth/firebase_auth.dart';

class PhotoKtpScreen extends StatefulWidget {
  @override
  _PhotoKtpScreenState createState() => _PhotoKtpScreenState();
}

class _PhotoKtpScreenState extends State<PhotoKtpScreen> {
  CameraController? controller;
  late Future<void> _initializeControllerFuture;
  bool isCameraReady = false;
  bool isProcessing = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showImagePickerOptions();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    controller = CameraController(
      firstCamera,
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
            builder: (context) => KonfirmKtpScreen(imagePath: _image!.path)),
      );
    } catch (e) {
      print(e);
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      setState(() {
        isProcessing = true;
      });

      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });

        // Upload ke Firebase Storage
        await _uploadFile(_image!);

        setState(() {
          isProcessing = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => KonfirmKtpScreen(imagePath: _image!.path)),
        );
      } else {
        setState(() {
          isProcessing = false;
        });
      }
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
          .child('ktp/${currentUser!.uid}_${basename(file.path)}');
      final uploadTask = storageReference.putFile(file);
      await uploadTask;
      final downloadUrl = await storageReference.getDownloadURL();

      // Simpan URL gambar KTP ke Firestore
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'ktp_picture': downloadUrl,
        'is_ktp_confirmed': true, // Setel status konfirmasi KTP menjadi true
      });

      print('File uploaded');
    } catch (e) {
      print(e);
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil Gambar'),
                onTap: () {
                  _takePicture();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih Galeri'),
                onTap: () {
                  _pickImageFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Hapus Foto'),
                onTap: () {
                  setState(() {
                    _image = null;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto KTP'),
        backgroundColor: const Color(0xFF2D4739),
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
                  'Letakkan KTP di dalam Frame',
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
                      Icons.credit_card,
                      size: 100,
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

class KonfirmKtpScreen extends StatelessWidget {
  final String imagePath;

  KonfirmKtpScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi KTP'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text('Pastikan KTP dapat dilihat dengan jelas'),
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
                    builder: (context) => FotoWajahScreen(),
                  ),
                );
              },
              child: const Text('Simpan dan Lanjut'),
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
