import 'package:flutter/material.dart';
import 'package:jogfarmv1/model/users.dart';
import 'package:jogfarmv1/screens/auth/login_screen.dart';
import 'package:jogfarmv1/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final DatabaseService _databaseService = DatabaseService();
  bool _passwordVisible = false;

  Future<void> _register() async {
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar('Semua kolom harus diisi', Colors.red);
      return;
    }

    if (!_validatePassword(_passwordController.text)) {
      _showSnackBar('Kata sandi harus minimal 8 karakter dan terdiri dari huruf dan angka', Colors.red);
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      UserModel user = UserModel(
        uid: userCredential.user!.uid,
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phoneNumber: _phoneNumberController.text,
      );

      await _databaseService.addUser(user);

      _showSnackBar('Akun berhasil dibuat!', Colors.green);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e', Colors.red);
    }
  }

  bool _validatePassword(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      content: Text(message),
      duration: Duration(milliseconds: 2500),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color.fromARGB(255, 23, 92, 28);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.person_add, size: 100, color: Colors.white),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Daftar',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                          hintText: 'Masukkan username Anda',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: backgroundColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          hintText: 'Masukkan email Anda',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: backgroundColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _phoneNumberController,
                        decoration: InputDecoration(
                          labelText: 'No Telepon',
                          prefixIcon: Icon(Icons.phone),
                          hintText: 'Masukkan nomor telepon Anda',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: backgroundColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          hintText: 'min 8 karakter, huruf dan angka',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
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
                        ),
                        obscureText: !_passwordVisible,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 100,
                            vertical: 20,
                          ),
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          'Daftar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Sudah punya akun ? Login',
                          style: TextStyle(color: Colors.green),
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
