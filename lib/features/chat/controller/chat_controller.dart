import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:myplace/features/chat/repository/chat_repository.dart';

class ChatController with ChangeNotifier {
  final ChatRepository _chatRepository;

  ChatController({ChatRepository? chatRepository})
      : _chatRepository = chatRepository ?? ChatRepository();

  Future<void> sendMessage(String receiverId, String text, String type) async {
    await _chatRepository.sendMessage(receiverId, text, type);
  }

  Future<void> sendVoiceMessage(String receiverId, File file, int duration) async {
    await _chatRepository.sendVoiceMessage(receiverId, file, duration);
  }

  Future<void> sendContactMessage(String receiverId, Contact contact) async {
    await _chatRepository.sendContactMessage(receiverId, contact);
  }

  Future<void> sendImageMessage(String receiverId, File file) async {
    await _chatRepository.sendImageMessage(receiverId, file);
  }

  Future<void> sendDocumentMessage(String receiverId, File file) async {
    await _chatRepository.sendDocumentMessage(receiverId, file);
  }

  Future<void> sendAudioMessage(String receiverId, File file) async {
    await _chatRepository.sendAudioMessage(receiverId, file);
  }

  Stream<QuerySnapshot> getMessages(String receiverId) {
    return _chatRepository.getMessages(receiverId);
  }

  Future<void> markAsRead(String messageId, String receiverId) async {
    await _chatRepository.markAsRead(messageId, receiverId);
  }
}
