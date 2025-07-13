import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myplace/data/models/message_model.dart';
import 'package:myplace/data/services/storage_service.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final StorageService _storageService;

  ChatRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    StorageService? storageService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storageService = storageService ?? StorageService();

  Future<void> sendMessage(String receiverId, String text, String type, {String? url, int? duration}) async {
    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId: currentUserId,
      receiverId: receiverId,
      text: text,
      timestamp: timestamp,
      type: type,
      url: url,
      duration: duration,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Future<void> sendVoiceMessage(String receiverId, File file, int duration) async {
    final url = await _storageService.uploadFile('voice_messages', file);
    if (url != null) {
      await sendMessage(receiverId, 'Voice Message', 'voice', url: url, duration: duration);
    }
  }

  Stream<QuerySnapshot> getMessages(String receiverId) {
    final String currentUserId = _auth.currentUser!.uid;
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> markAsRead(String messageId, String receiverId) async {
    final String currentUserId = _auth.currentUser!.uid;
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }
}
