import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jogfarmv1/model/users.dart';
import 'package:jogfarmv1/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jogfarmv1/screens/maps_screen.dart';
import 'package:geocoding/geocoding.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  File? _image;
  String? _profileImageUrl;
  bool _isImageDeleted = false;
  bool _isLoading = false;

  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      UserModel? user = await DatabaseService().getUser(userId);
      if (user != null) {
        setState(() {
          _usernameController.text = user.username;
          _emailController.text = user.email;
          _firstNameController.text = user.firstName ?? '';
          _lastNameController.text = user.lastName ?? '';
          _phoneNumberController.text = user.phoneNumber;
          _addressController.text = user.address ?? '';
          _dateOfBirthController.text = user.dateOfBirth?.toIso8601String() ?? '';
          _profileImageUrl = user.profilePicture;
          _currentUser = user; // Simpan data pengguna saat ini
          print('User Data Loaded: $user');
        });
      } else {
        print('User data not found');
      }
    } else {
      print('No user is currently logged in');
    }
  }

  Future<void> _saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      await _uploadImage();
      UserModel updatedUser = UserModel(
        uid: userId,
        username: _usernameController.text,
        email: _emailController.text,
        password: _currentUser!.password, // Gunakan password yang disimpan
        phoneNumber: _phoneNumberController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        address: _addressController.text,
        dateOfBirth: DateTime.tryParse(_dateOfBirthController.text),
        profilePicture: _profileImageUrl,
        ktpNumber: _currentUser!.ktpNumber, // Gunakan nilai yang disimpan
        ktpPicture: _currentUser!.ktpPicture, // Gunakan nilai yang disimpan
        gender: _currentUser!.gender, // Gunakan nilai yang disimpan
        isAdmin: _currentUser!.isAdmin, // Gunakan nilai yang disimpan
        isBuyer: _currentUser!.isBuyer, // Gunakan nilai yang disimpan
        isSeller: _currentUser!.isSeller, // Gunakan nilai yang disimpan
        isKtpConfirmed: _currentUser!.isKtpConfirmed, // Gunakan nilai yang disimpan
        createdAt: _currentUser!.createdAt, // Gunakan nilai yang disimpan
      );
      await DatabaseService().updateUser(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui!')),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_image != null) {
      try {
        setState(() {
          _isLoading = true;
        });
        User? currentUser = FirebaseAuth.instance.currentUser;
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('images')
            .child('profile_${currentUser!.uid}.jpg');

        await storageRef.putFile(_image!);
        _profileImageUrl = await storageRef.getDownloadURL();
        print('Profile Image URL: $_profileImageUrl');
      } catch (e) {
        print('Error uploading image: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    setState(() {
      _isLoading = true;
    });
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        setState(() {
          _image = imageFile;
          _isImageDeleted = false;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteImage() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        setState(() {
          _isLoading = true;
        });
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('images')
            .child('profile_${currentUser.uid}.jpg');

        await storageRef.delete();
        setState(() {
          _image = null;
          _profileImageUrl = null;
          _isImageDeleted = true;
        });
      } catch (e) {
        print('Error deleting image: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih Galeri'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Hapus Foto'),
                onTap: () {
                  _deleteImage();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectAddress() async {
    LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );
    if (result != null) {
      setState(() {
        _addressController.text = '${result.latitude}, ${result.longitude}';
      });
      await _getAddressFromLatLng(result);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      setState(() {
        _addressController.text = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}';
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : (_profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : const AssetImage('images/default_profile.png')
                                  as ImageProvider<Object>?),
                      backgroundColor: Colors.grey[300],
                      child: _image == null && _profileImageUrl == null
                          ? const Icon(Icons.person,
                              size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _showImagePickerOptions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Edit Foto Profil',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _addressController,
                    readOnly: true,
                    onTap: _selectAddress,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Simpan perubahan',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
