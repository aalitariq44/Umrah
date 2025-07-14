import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myplace/data/models/message_model.dart';
import 'package:myplace/features/chat/services/media_compression_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final MediaCompressionService _mediaCompressionService;

  ChatRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
    MediaCompressionService? mediaCompressionService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _mediaCompressionService =
            mediaCompressionService ?? MediaCompressionService();

  Future<String> sendMessage({
    required String receiverId,
    required String text,
    required MessageType type,
    String? url,
    int? duration,
    String? contactName,
    String? contactNumber,
    String? imageUrl,
    String? fileName,
    double? latitude,
    double? longitude,
    int? fileSize,
    String? mimeType,
  }) async {
    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();
    final String messageId = const Uuid().v4();

    Message newMessage = Message(
      id: messageId,
      senderId: currentUserId,
      receiverId: receiverId,
      text: text,
      timestamp: timestamp,
      type: type,
      status: MessageStatus.sending,
      url: url,
      duration: duration,
      contactName: contactName,
      contactNumber: contactNumber,
      imageUrl: imageUrl,
      fileName: fileName,
      latitude: latitude,
      longitude: longitude,
      fileSize: fileSize,
      mimeType: mimeType,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .set(newMessage.toMap());

    // Update message status to sent
    await updateMessageStatus(chatRoomId, messageId, MessageStatus.sent);
    
    // Update last message in chat room
    await _updateLastMessage(chatRoomId, newMessage);
    
    return messageId;
  }

  Future<void> updateMessageStatus(String chatRoomId, String messageId, MessageStatus status) async {
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update({'status': status.toString().split('.').last});
  }

  Future<void> _updateLastMessage(String chatRoomId, Message message) async {
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .set({
      'lastMessage': message.text.isNotEmpty ? message.text : _getTypeDescription(message.type),
      'lastMessageTime': message.timestamp,
      'lastMessageSender': message.senderId,
      'participants': [message.senderId, message.receiverId],
    }, SetOptions(merge: true));
  }

  String _getTypeDescription(MessageType type) {
    switch (type) {
      case MessageType.image:
        return '📷 Image';
      case MessageType.voice:
        return '🎤 Voice Message';
      case MessageType.audio:
        return '🎵 Audio';
      case MessageType.document:
        return '📄 Document';
      case MessageType.location:
        return '📍 Location';
      case MessageType.contact:
        return '👤 Contact';
      default:
        return 'Message';
    }
  }

  Future<void> sendVoiceMessage(String receiverId, File file, int duration) async {
    final ref = _storage.ref('voice_messages').child(const Uuid().v4());
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    
    await sendMessage(
      receiverId: receiverId,
      text: 'Voice Message',
      type: MessageType.voice,
      url: url,
      duration: duration,
    );
  }

  Future<void> sendContactMessage(String receiverId, Contact contact) async {
    final contactName = contact.displayName;
    final contactNumber = contact.phones.isNotEmpty ? contact.phones.first.number : 'N/A';
    
    await sendMessage(
      receiverId: receiverId,
      text: contactName,
      type: MessageType.contact,
      contactName: contactName,
      contactNumber: contactNumber,
    );
  }

  Future<String> sendImageMessage(String receiverId, File file) async {
    final String messageId = const Uuid().v4();
    final String currentUserId = _auth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    // Create a local message first
    Message localMessage = Message(
      id: messageId,
      senderId: currentUserId,
      receiverId: receiverId,
      text: 'Image',
      timestamp: timestamp,
      type: MessageType.image,
      status: MessageStatus.sending,
      localFile: file,
    );
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .set(localMessage.toMap());
    
    // Upload the image
    final compressedFile =
        await _mediaCompressionService.compressImage(file) ?? file;
    final ref = _storage.ref('image_messages').child(messageId);
    await ref.putFile(compressedFile);
    final imageUrl = await ref.getDownloadURL();

    // Update the message with the remote URL
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update({
      'imageUrl': imageUrl,
      'status': MessageStatus.sent.toString().split('.').last,
      'fileSize': await compressedFile.length(),
      'mimeType': _mediaCompressionService.getMimeType(compressedFile.path),
    });

    await _updateLastMessage(chatRoomId, localMessage.copyWith(imageUrl: imageUrl, status: MessageStatus.sent));
    return messageId;
  }

  Future<void> sendDocumentMessage(String receiverId, File file) async {
    // Check file size
    if (!_mediaCompressionService.isValidFileSize(file)) {
      throw Exception('File size is too large');
    }
    
    final ref = _storage.ref('document_messages').child(const Uuid().v4());
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    
    await sendMessage(
      receiverId: receiverId,
      text: 'Document',
      type: MessageType.document,
      url: url,
      fileName: file.path.split('/').last,
      fileSize: await file.length(),
      mimeType: _mediaCompressionService.getMimeType(file.path),
    );
  }

  Future<void> sendAudioMessage(String receiverId, File file) async {
    final ref = _storage.ref('audio_messages').child(const Uuid().v4());
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    
    await sendMessage(
      receiverId: receiverId,
      text: 'Audio',
      type: MessageType.audio,
      url: url,
      fileName: file.path.split('/').last,
      fileSize: await file.length(),
      mimeType: _mediaCompressionService.getMimeType(file.path),
    );
  }

  Future<void> sendLocationMessage(String receiverId, Position position) async {
    await sendMessage(
      receiverId: receiverId,
      text: 'Location',
      type: MessageType.location,
      latitude: position.latitude,
      longitude: position.longitude,
    );
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
        .update({'status': MessageStatus.read.toString().split('.').last});
  }

  Future<void> markAllMessagesAsRead(String receiverId) async {
    final String currentUserId = _auth.currentUser!.uid;
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    final unreadMessages = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', whereIn: ['sent', 'delivered'])
        .get();

    final batch = _firestore.batch();
    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {'status': MessageStatus.read.toString().split('.').last});
    }
    await batch.commit();
  }

  Future<void> setTypingStatus(String receiverId, bool isTyping) async {
    final String currentUserId = _auth.currentUser!.uid;
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('typing')
        .doc(currentUserId)
        .set({
      'isTyping': isTyping,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<bool> getTypingStatus(String receiverId) {
    final String currentUserId = _auth.currentUser!.uid;
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('typing')
        .doc(receiverId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return false;
      final data = doc.data() as Map<String, dynamic>;
      final isTyping = data['isTyping'] ?? false;
      final timestamp = data['timestamp'] as Timestamp?;
      
      // Consider typing expired after 3 seconds
      if (timestamp != null) {
        final now = DateTime.now();
        final typingTime = timestamp.toDate();
        if (now.difference(typingTime).inSeconds > 3) {
          return false;
        }
      }
      
      return isTyping;
    });
  }

  Stream<List<Map<String, dynamic>>> getChatRooms() {
    final String currentUserId = _auth.currentUser!.uid;
    
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
              'id': doc.id,
              ...doc.data(),
            }).toList());
  }

  Future<void> deleteMessage(String messageId, String receiverId) async {
    final String currentUserId = _auth.currentUser!.uid;
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> updateMessageProgress(String messageId, String receiverId, double progress) async {
    final String currentUserId = _auth.currentUser!.uid;
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .update({'uploadProgress': progress});
  }

  // Online/Offline status
  Future<void> setUserOnlineStatus(bool isOnline) async {
    final String currentUserId = _auth.currentUser!.uid;
    
    await _firestore.collection('users').doc(currentUserId).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  Stream<Map<String, dynamic>?> getUserOnlineStatus(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }
}

extension MessageExtension on Message {
  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? text,
    Timestamp? timestamp,
    MessageStatus? status,
    MessageType? type,
    String? url,
    int? duration,
    String? contactName,
    String? contactNumber,
    String? imageUrl,
    String? fileName,
    double? latitude,
    double? longitude,
    int? fileSize,
    String? mimeType,
    File? localFile,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      type: type ?? this.type,
      url: url ?? this.url,
      duration: duration ?? this.duration,
      contactName: contactName ?? this.contactName,
      contactNumber: contactNumber ?? this.contactNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      fileName: fileName ?? this.fileName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      localFile: localFile ?? this.localFile,
    );
  }
}
