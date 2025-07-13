import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myplace/data/models/user_model.dart' as model;
import 'package:myplace/features/chat/controller/chat_controller.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:myplace/features/chat/widgets/message_composer.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final model.User friend;
  const ChatScreen({super.key, required this.friend});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friend.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatController.getMessages(widget.friend.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('لا توجد رسائل بعد'));
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var messageDoc = snapshot.data!.docs[index];
                    var messageData = messageDoc.data() as Map<String, dynamic>;

                    // Mark message as read
                    if (messageData['receiverId'] == currentUserId && !messageData['isRead']) {
                      chatController.markAsRead(messageDoc.id, widget.friend.uid);
                    }

                    bool isMe = messageData['senderId'] == currentUserId;
                    return _buildMessageBubble(
                      context,
                      messageData,
                      isMe,
                    );
                  },
                );
              },
            ),
          ),
          MessageComposer(
            onSendMessage: (text) {
              final chatController = Provider.of<ChatController>(context, listen: false);
              chatController.sendMessage(widget.friend.uid, text, 'text');
            },
            onSendVoiceMessage: (file, duration) {
              final chatController = Provider.of<ChatController>(context, listen: false);
              chatController.sendVoiceMessage(widget.friend.uid, file, duration);
            },
            onSendContact: (contact) {
              final chatController = Provider.of<ChatController>(context, listen: false);
              chatController.sendContactMessage(widget.friend.uid, contact);
            },
            onSendImage: (file) {
              final chatController = Provider.of<ChatController>(context, listen: false);
              chatController.sendImageMessage(widget.friend.uid, file);
            },
            onSendDocument: (file) {
              final chatController = Provider.of<ChatController>(context, listen: false);
              chatController.sendDocumentMessage(widget.friend.uid, file);
            },
            onSendAudio: (file) {
              final chatController = Provider.of<ChatController>(context, listen: false);
              chatController.sendAudioMessage(widget.friend.uid, file);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, Map<String, dynamic> messageData, bool isMe) {
    final time = DateFormat('hh:mm a').format((messageData['timestamp'] as Timestamp).toDate());
    final type = messageData['type'] ?? 'text';

    Widget messageContent;
    if (type == 'text') {
      messageContent = Text(messageData['text']);
    } else if (type == 'voice') {
      final duration = messageData['duration'] ?? 0;
      final minutes = (duration / 60).floor();
      final seconds = duration % 60;
      final durationString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      messageContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () async {
              await _audioPlayer.play(UrlSource(messageData['url']));
            },
          ),
          Text(durationString),
        ],
      );
    } else if (type == 'contact') {
      messageContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(messageData['contactName'] ?? 'Unknown Contact', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(messageData['contactNumber'] ?? ''),
        ],
      );
    } else if (type == 'image') {
      messageContent = Image.network(messageData['imageUrl']);
    } else if (type == 'document') {
      messageContent = Row(
        children: [
          const Icon(Icons.insert_drive_file),
          const SizedBox(width: 8),
          Text(messageData['fileName'] ?? 'Document'),
        ],
      );
    } else if (type == 'audio') {
      messageContent = Row(
        children: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () async {
              await _audioPlayer.play(UrlSource(messageData['url']));
            },
          ),
          Text(messageData['fileName'] ?? 'Audio'),
        ],
      );
    } else {
      messageContent = const Text('Unsupported message type');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            decoration: BoxDecoration(
              color: isMe ? Colors.orange[300] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                messageContent,
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(time, style: const TextStyle(fontSize: 10)),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.done_all,
                        size: 16,
                        color: messageData['isRead'] ? Colors.blue : Colors.grey,
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
