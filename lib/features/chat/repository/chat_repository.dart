import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myplace/data/models/message_model.dart';
import 'package:uuid/uuid.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  ChatRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future<void> sendMessage(String receiverId, String text, String type, {String? url, int? duration, String? contactName, String? contactNumber, String? imageUrl, String? fileName, double? latitude, double? longitude}) async {
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
      contactName: contactName,
      contactNumber: contactNumber,
      imageUrl: imageUrl,
      fileName: fileName,
      latitude: latitude,
      longitude: longitude,
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
    final ref = _storage.ref('voice_messages').child(const Uuid().v4());
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    await sendMessage(receiverId, 'Voice Message', 'voice', url: url, duration: duration);
  }

  Future<void> sendContactMessage(String receiverId, Contact contact) async {
    final contactName = contact.displayName;
    final contactNumber = contact.phones.isNotEmpty ? contact.phones.first.number : 'N/A';
    await sendMessage(receiverId, '', 'contact', contactName: contactName, contactNumber: contactNumber);
  }

  Future<void> sendImageMessage(String receiverId, File file) async {
    final ref = _storage.ref('image_messages').child(const Uuid().v4());
    await ref.putFile(file);
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(receiverId, 'Image', 'image', imageUrl: imageUrl);
  }

  Future<void> sendDocumentMessage(String receiverId, File file) async {
    final ref = _storage.ref('document_messages').child(const Uuid().v4());
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    await sendMessage(receiverId, 'Document', 'document', url: url, fileName: file.path.split('/').last);
  }

  Future<void> sendAudioMessage(String receiverId, File file) async {
    final ref = _storage.ref('audio_messages').child(const Uuid().v4());
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    await sendMessage(receiverId, 'Audio', 'audio', url: url, fileName: file.path.split('/').last);
  }

  Future<void> sendLocationMessage(String receiverId, Position position) async {
    await sendMessage(receiverId, 'Location', 'location', latitude: position.latitude, longitude: position.longitude);
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
