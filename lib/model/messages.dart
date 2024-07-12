class Message {
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final String? fileUrl;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.fileUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'fileUrl': fileUrl,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      text: map['text'],
      timestamp: DateTime.parse(map['timestamp']),
      fileUrl: map['fileUrl'],
    );
  }
}
