import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String chatId, String senderId, String receiverId, String text, String? fileUrl) async {
    var message = {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': DateTime.now().toIso8601String(),
      'fileUrl': fileUrl,
    };

    await _firestore.collection('chats/$chatId/messages').add(message);
  }

  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats/$chatId/messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
