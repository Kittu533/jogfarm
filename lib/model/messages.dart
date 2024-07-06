class Message {
  final int messageId;
  final int senderId;
  final int receiverId;
  final String content;
  final DateTime timestamp;

  Message({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });

  // Method to convert Message object to a map
  Map<String, dynamic> toMap() {
    return {
      'message_id': messageId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Factory method to create a Message object from a map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['message_id'],
      senderId: map['sender_id'],
      receiverId: map['receiver_id'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
