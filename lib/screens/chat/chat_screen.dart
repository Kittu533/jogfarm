import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String chatId;

  ChatScreen({required this.receiverId, required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _messageController = TextEditingController();
  String receiverName = '';

  @override
  void initState() {
    super.initState();
    _fetchReceiverName();
  }

  Future<void> _fetchReceiverName() async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(widget.receiverId).get();
    setState(() {
      receiverName = userDoc['username'];
    });
  }

  void _sendMessage(String text, String? fileUrl) {
    if (text.isEmpty && fileUrl == null) return;

    var message = {
      'senderId': _auth.currentUser!.uid,
      'receiverId': widget.receiverId,
      'text': text,
      'timestamp': DateTime.now().toIso8601String(),
      'fileUrl': fileUrl,
    };

    _firestore.collection('chats/${widget.chatId}/messages').add(message);

    var chat = {
      'participants': [_auth.currentUser!.uid, widget.receiverId],
      'lastMessage': text.isEmpty ? 'Image' : text,
      'lastTimestamp': DateTime.now().toIso8601String(),
    };

    _firestore.collection('chats').doc(widget.chatId).set(chat);
  }

  Future<void> _sendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      // Simpan file ke Firebase Storage dan dapatkan URL-nya
      try {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref = FirebaseStorage.instance.ref().child('chat_images').child(fileName);
        UploadTask uploadTask = ref.putFile(file);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        String fileUrl = await taskSnapshot.ref.getDownloadURL();

        _sendMessage('', fileUrl);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $receiverName'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats/${widget.chatId}/messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderId'] == _auth.currentUser!.uid;

                    return ListTile(
                      title: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: message['fileUrl'] != null
                              ? Image.network(message['fileUrl'])
                              : Text(
                                  message['text'],
                                  style: TextStyle(color: isMe ? Colors.white : Colors.black),
                                ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.photo),
                  onPressed: _sendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                    ),
                    onSubmitted: (text) {
                      _sendMessage(text, null);
                      _messageController.clear();
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage(_messageController.text, null);
                    _messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
