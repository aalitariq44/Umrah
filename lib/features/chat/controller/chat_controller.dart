import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:myplace/features/chat/repository/chat_repository.dart';
import 'package:myplace/data/models/message_model.dart';
import 'dart:async';

class ChatController with ChangeNotifier {
  final ChatRepository _chatRepository;
  final Map<String, StreamSubscription> _typingSubscriptions = {};
  final Map<String, bool> _typingStatus = {};
  final Map<String, StreamSubscription> _onlineStatusSubscriptions = {};
  final Map<String, Map<String, dynamic>?> _onlineStatus = {};

  ChatController({ChatRepository? chatRepository})
      : _chatRepository = chatRepository ?? ChatRepository();

  @override
  void dispose() {
    for (final subscription in _typingSubscriptions.values) {
      subscription.cancel();
    }
    for (final subscription in _onlineStatusSubscriptions.values) {
      subscription.cancel();
    }
    super.dispose();
  }

  Future<String> sendTextMessage(String receiverId, String text) async {
    return await _chatRepository.sendMessage(
      receiverId: receiverId,
      text: text,
      type: MessageType.text,
    );
  }

  Future<void> sendVoiceMessage(String receiverId, File file, int duration) async {
    await _chatRepository.sendVoiceMessage(receiverId, file, duration);
  }

  Future<void> sendContactMessage(String receiverId, Contact contact) async {
    await _chatRepository.sendContactMessage(receiverId, contact);
  }

  Future<String> sendImageMessage(String receiverId, File file) async {
    return await _chatRepository.sendImageMessage(receiverId, file);
  }

  Future<void> sendDocumentMessage(String receiverId, File file) async {
    await _chatRepository.sendDocumentMessage(receiverId, file);
  }

  Future<void> sendAudioMessage(String receiverId, File file) async {
    await _chatRepository.sendAudioMessage(receiverId, file);
  }

  Future<void> sendLocationMessage(String receiverId, Position position) async {
    await _chatRepository.sendLocationMessage(receiverId, position);
  }

  Stream<QuerySnapshot> getMessages(String receiverId) {
    return _chatRepository.getMessages(receiverId);
  }

  Future<void> markAsRead(String messageId, String receiverId) async {
    await _chatRepository.markAsRead(messageId, receiverId);
  }

  Future<void> markAllMessagesAsRead(String receiverId) async {
    await _chatRepository.markAllMessagesAsRead(receiverId);
  }

  // Typing status methods
  Future<void> setTypingStatus(String receiverId, bool isTyping) async {
    await _chatRepository.setTypingStatus(receiverId, isTyping);
  }

  void subscribeToTypingStatus(String receiverId) {
    _typingSubscriptions[receiverId]?.cancel();
    _typingSubscriptions[receiverId] = _chatRepository.getTypingStatus(receiverId).listen((isTyping) {
      _typingStatus[receiverId] = isTyping;
      notifyListeners();
    });
  }

  bool isUserTyping(String userId) {
    return _typingStatus[userId] ?? false;
  }

  void unsubscribeFromTypingStatus(String receiverId) {
    _typingSubscriptions[receiverId]?.cancel();
    _typingSubscriptions.remove(receiverId);
    _typingStatus.remove(receiverId);
  }

  // Online status methods
  void subscribeToOnlineStatus(String userId) {
    _onlineStatusSubscriptions[userId]?.cancel();
    _onlineStatusSubscriptions[userId] = _chatRepository.getUserOnlineStatus(userId).listen((status) {
      _onlineStatus[userId] = status;
      notifyListeners();
    });
  }

  void unsubscribeFromOnlineStatus(String userId) {
    _onlineStatusSubscriptions[userId]?.cancel();
    _onlineStatusSubscriptions.remove(userId);
    _onlineStatus.remove(userId);
  }

  Map<String, dynamic>? getUserOnlineStatus(String userId) {
    return _onlineStatus[userId];
  }

  bool isUserOnline(String userId) {
    final status = _onlineStatus[userId];
    return status?['isOnline'] ?? false;
  }

  DateTime? getLastSeen(String userId) {
    final status = _onlineStatus[userId];
    final lastSeen = status?['lastSeen'];
    if (lastSeen is Timestamp) {
      return lastSeen.toDate();
    }
    return null;
  }

  Future<void> setUserOnlineStatus(bool isOnline) async {
    await _chatRepository.setUserOnlineStatus(isOnline);
  }

  Stream<List<Map<String, dynamic>>> getChatRooms() {
    return _chatRepository.getChatRooms();
  }

  Future<void> deleteMessage(String messageId, String receiverId) async {
    await _chatRepository.deleteMessage(messageId, receiverId);
  }

  Future<void> updateMessageProgress(String messageId, String receiverId, double progress) async {
    await _chatRepository.updateMessageProgress(messageId, receiverId, progress);
  }
}
