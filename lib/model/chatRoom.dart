import 'package:jogfarmv1/model/messages.dart';

class ChatRoom {
  final String chatRoomId;
  final String user1Id;
  final String user2Id;
  final List<Message> messages;

  ChatRoom({
    required this.chatRoomId,
    required this.user1Id,
    required this.user2Id,
    required this.messages,
  });

  Map<String, dynamic> toMap() {
    return {
      'chat_room_id': chatRoomId,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'messages': messages.map((message) => message.toMap()).toList(),
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      chatRoomId: map['chat_room_id'],
      user1Id: map['user1_id'],
      user2Id: map['user2_id'],
      messages: List<Message>.from(
        (map['messages'] as List<dynamic>).map((messageMap) => Message.fromMap(messageMap)),
      ),
    );
  }
}
