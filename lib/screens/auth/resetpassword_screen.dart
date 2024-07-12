import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Text('Berhasil'),
          content: const Text('Link untuk reset password telah dikirim ke email Anda.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _updatePasswordInFirestore(String email, String newPassword) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var userData = querySnapshot.docs[0];
      await _firestore.collection('users').doc(userData.id).update({'password': newPassword});
    }
  }

  Future<void> _resetPasswordAndSaveToFirestore(String email, String newPassword) async {
    try {
      User? user = (await _auth.signInWithEmailAndPassword(email: email, password: newPassword)).user;
      if (user != null) {
        await user.updatePassword(newPassword);
        _updatePasswordInFirestore(email, newPassword);
        _showSuccessDialog();
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: const Color.fromARGB(255, 23, 92, 28),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _resetPassword(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 23, 92, 28),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Reset Password',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
