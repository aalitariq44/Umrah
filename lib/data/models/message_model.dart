import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String text;
  final Timestamp timestamp;
  final bool isRead;
  final String type;
  final String? url;
  final int? duration;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.type = 'text',
    this.url,
    this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp,
      'isRead': isRead,
      'type': type,
      'url': url,
      'duration': duration,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      text: map['text'],
      timestamp: map['timestamp'],
      isRead: map['isRead'] ?? false,
      type: map['type'] ?? 'text',
      url: map['url'],
      duration: map['duration'],
    );
  }
}
