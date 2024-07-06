import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String sellerName;
  final String sellerProfileImage;

  ChatScreen({required this.sellerName, required this.sellerProfileImage});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D4739),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.sellerProfileImage),
            ),
            SizedBox(width: 8),
            Text(widget.sellerName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text('Ini adalah halaman chat dengan penjual.'),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(8),
      color: const Color(0xFF2D4739),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // Tambahkan fungsi untuk menambahkan lampiran
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Tulis Pesan...',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.black),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.white),
            onPressed: () {
              // Tambahkan fungsi untuk mengirim pesan
            },
          ),
        ],
      ),
    );
  }
}
