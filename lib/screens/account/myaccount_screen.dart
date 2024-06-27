import 'package:flutter/material.dart';
import 'package:jogfarmv1/screens/account/edtiaccount_screen.dart';
import 'package:jogfarmv1/screens/verificationAccount/upgradeaccount_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jogfarmv1/screens/auth/login_screen.dart';
import 'package:jogfarmv1/screens/home_screen.dart';
import 'package:jogfarmv1/screens/account/profilebeforelogin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jogfarmv1/model/users.dart';

class AkunSayaScreen extends StatefulWidget {
  const AkunSayaScreen({super.key});

  @override
  _AkunSayaScreenState createState() => _AkunSayaScreenState();
}

class _AkunSayaScreenState extends State<AkunSayaScreen> {
  late Future<bool> _loginStatus;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loginStatus = _checkLoginStatus();
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      String? userId = prefs.getString('userId');
      if (userId != null) {
        await _loadUserData(userId);
      } else {
        print('User ID not found in SharedPreferences');
      }
    }
    return isLoggedIn;
  }

  Future<void> _loadUserData(String uid) async {
    print('Loading user data for UID: $uid');
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>?;
          print('User Data: $userData'); // Logging user data for debugging
        });
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userId');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loginStatus,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData && snapshot.data == false) {
          return const ProfileBeforeLoginScreen();
        } else if (snapshot.hasData && snapshot.data == true) {
          return _buildLoggedInView();
        } else {
          return const Scaffold(
            body: Center(
              child: Text("Terjadi kesalahan."),
            ),
          );
        }
      },
    );
  }

  Widget _buildLoggedInView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Akun Saya',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.green[800],
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: userData?['profile_picture'] != null
                        ? NetworkImage(userData!['profile_picture'])
                        : const AssetImage('images/default_profile.png')
                            as ImageProvider<Object>,
                    backgroundColor: Colors.grey[300],
                    child: userData?['profile_picture'] == null
                        ? const Icon(Icons.person,
                            size: 40, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userData?['username'] ?? 'Username',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    userData?['phone_number'] ?? 'Phone Number',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditProfileScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                    ),
                    child: const Text(
                      'Edit Profil',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.green),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(userData?['username'] ?? 'Username'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.edit, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(userData?['address'] ?? 'Address'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(userData?['phone_number'] ?? 'Phone Number'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: const Text('Akun bisnis'),
              onTap: () {
                // Add your business account logic here
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Favorit'),
              onTap: () {
                // Add your settings logic here
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Pesanan'),
              onTap: () {
                // Add your help logic here
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Pengaturan'),
              onTap: () {
                // Add your help logic here
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Upgrade Akun'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  UpgradeAkunScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
