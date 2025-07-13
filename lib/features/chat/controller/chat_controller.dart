import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myplace/features/chat/repository/chat_repository.dart';

class ChatController with ChangeNotifier {
  final ChatRepository _chatRepository;

  ChatController({ChatRepository? chatRepository})
      : _chatRepository = chatRepository ?? ChatRepository();

  Future<void> sendMessage(String receiverId, String text) async {
    await _chatRepository.sendMessage(receiverId, text);
  }

  Stream<QuerySnapshot> getMessages(String receiverId) {
    return _chatRepository.getMessages(receiverId);
  }

  Future<void> markAsRead(String messageId, String receiverId) async {
    await _chatRepository.markAsRead(messageId, receiverId);
  }
}
