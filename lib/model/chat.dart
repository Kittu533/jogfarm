class Chat {
  final String chatId;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastTimestamp;

  Chat({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
    required this.lastTimestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastTimestamp': lastTimestamp.toIso8601String(),
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      chatId: map['chatId'],
      participants: List<String>.from(map['participants']),
      lastMessage: map['lastMessage'],
      lastTimestamp: DateTime.parse(map['lastTimestamp']),
    );
  }
}
