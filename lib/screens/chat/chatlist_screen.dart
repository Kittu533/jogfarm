import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'package:intl/intl.dart';
import 'package:jogfarmv1/screens/auth/login_screen.dart'; // Pastikan import halaman login

class ChatListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> _fetchReceiverData(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  String _formatTimestamp(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser == null) {
      // Jika user belum login, arahkan ke halaman login atau tampilkan pesan yang relevan
      return Scaffold(
        appBar: AppBar(
          title: Text('Chats'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Anda belum login. Silakan login untuk melihat chat.'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()), // Ganti dengan halaman login Anda
                  );
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('chats').orderBy('lastTimestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var chats = snapshot.data!.docs.where((doc) {
            return List<String>.from(doc['participants']).contains(_auth.currentUser!.uid);
          }).toList();

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              var chat = chats[index];
              var participants = List<String>.from(chat['participants']);
              var otherUserId = participants.firstWhere((id) => id != _auth.currentUser!.uid);
              var lastMessage = chat['lastMessage'];
              var lastTimestamp = chat['lastTimestamp'];

              return FutureBuilder<Map<String, dynamic>>(
                future: _fetchReceiverData(otherUserId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Loading...'),
                      subtitle: Text(lastMessage),
                    );
                  }

                  if (userSnapshot.hasError) {
                    return ListTile(
                      title: Text('Error'),
                      subtitle: Text(lastMessage),
                    );
                  }

                  var receiverData = userSnapshot.data!;
                  var receiverName = receiverData['username'] ?? 'Unknown User';
                  var receiverPhotoUrl = receiverData['profile_picture'];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: receiverPhotoUrl != null
                          ? NetworkImage(receiverPhotoUrl)
                          : AssetImage('assets/default_profile.png') as ImageProvider,
                    ),
                    title: Text(receiverName),
                    subtitle: Text(lastMessage),
                    trailing: Text(_formatTimestamp(lastTimestamp)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            receiverId: otherUserId,
                            chatId: chat.id,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
