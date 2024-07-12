import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('chats').orderBy('lastTimestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

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

              return ListTile(
                title: Text(otherUserId),
                subtitle: Text(lastMessage),
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
      ),
    );
  }
}
