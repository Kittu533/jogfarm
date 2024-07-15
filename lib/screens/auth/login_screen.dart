import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jogfarmv1/screens/auth/register_screen.dart';
import 'package:jogfarmv1/screens/home_screen.dart';
import 'package:jogfarmv1/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late Future<FirebaseApp> _initialization;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _initialization = Firebase.initializeApp();
    _passwordVisible = false;
  }

  Future<void> _sendPasswordResetEmail(String username) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _showFailureNotification('Username tidak ditemukan');
        return;
      }

      var userData = querySnapshot.docs[0];
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: userData['email']);
      _showSuccessNotification('Email reset password telah dikirim');
    } catch (e) {
      log('Error sending password reset email: $e');
      _showFailureNotification('Gagal mengirim email reset password: $e');
    }
  }

  Future<void> _signInWithUsernamePassword() async {
    try {
      if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
        _showFailureNotification('Semua kolom harus diisi');
        return;
      }

      String email = '';
      String input = _usernameController.text;

      if (RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(input)) {
        // Input is an email
        email = input;
      } else {
        // Input is a username
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('username', isEqualTo: input)
            .get();

        if (querySnapshot.docs.isEmpty) {
          _showFailureNotification('Username tidak ditemukan');
          return;
        }

        var userData = querySnapshot.docs[0];
        email = userData['email'];
      }

      // Authenticate the user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: _passwordController.text);

      if (userCredential.user != null) {
        // Save login status and user ID
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', userCredential.user!.uid);

        _showSuccessNotification('Login berhasil');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        _showFailureNotification('Password salah');
      }
    } catch (e) {
      log('Error signing in with username and password: $e');
      _showFailureNotification('Terjadi kesalahan saat masuk');
    }
  }

  void _showSuccessNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      content: Text(message),
      duration: Duration(milliseconds: 2500),
    ));
  }

  void _showFailureNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(message),
      duration: Duration(milliseconds: 2500),
    ));
  }

  Future<void> _handleGoogleBtnClick(BuildContext context) async {
    await _initialization; // Pastikan Firebase telah diinisialisasi
    _signInWithGoogle().then((user) async {
      log('\nUser: ${user.user.toString()}');
      log('\nUserAdditionalInfo: ${user.additionalUserInfo.toString()}');

      // Simpan status login
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      _showSuccessNotification('Login dengan Google berhasil');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }).catchError((e) {
      log('Error signing in with Google: $e');
      _showFailureNotification('Gagal masuk dengan Google: $e');
    });
  }

  Future<UserCredential> _signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color.fromARGB(255, 23, 92, 28);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'images/logo_jogfarm.png',
                height: 100,
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Masuk',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username atau Email',
                          prefixIcon: Icon(Icons.person),
                          hintText: 'Masukkan username atau email Anda',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: backgroundColor),
                          ),
                          labelStyle: TextStyle(color: backgroundColor),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          hintText: 'Masukkan password Anda',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: backgroundColor),
                          ),
                          labelStyle: TextStyle(color: backgroundColor),
                        ),
                        obscureText: !_passwordVisible,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _sendPasswordResetEmail(_usernameController.text);
                          },
                          child: const Text(
                            'Lupa Password?',
                            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegisterScreen()),
                            );
                          },
                          child: const Text(
                            'Belum punya akun ? Daftar',
                            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _signInWithUsernamePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: backgroundColor,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: const [
                          Expanded(child: Divider(thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('Or'),
                          ),
                          Expanded(child: Divider(thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _handleGoogleBtnClick(context),
                        icon: Image.asset(
                          'assets/images/google.png',
                          width: 24,
                          height: 24,
                        ),
                        label: const Text(
                          'Sign in with Google',
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
