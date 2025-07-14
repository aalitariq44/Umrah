import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myplace/data/models/user_model.dart' as model;
import 'package:myplace/features/chat/controller/chat_controller.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:myplace/features/chat/widgets/message_composer.dart';
import 'package:myplace/features/call/services/call_manager.dart';
import 'package:myplace/data/models/message_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () async {
              final currentUser = model.User(
                uid: currentUserId,
                email: FirebaseAuth.instance.currentUser!.email ?? '',
                name: FirebaseAuth.instance.currentUser!.displayName ?? 'أنا',
                phone: '',
              );
              
              await CallManager.initiateCall(
                context: context,
                targetUser: widget.friend,
                currentUser: currentUser,
                callType: CallType.video,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () async {
              final currentUser = model.User(
                uid: currentUserId,
                email: FirebaseAuth.instance.currentUser!.email ?? '',
                name: FirebaseAuth.instance.currentUser!.displayName ?? 'أنا',
                phone: '',
              );
              
              await CallManager.initiateCall(
                context: context,
                targetUser: widget.friend,
                currentUser: currentUser,
                callType: CallType.voice,
              );
            },
          ),
        ],
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
                    var message = Message.fromMap(messageDoc.data() as Map<String, dynamic>);

                    // Mark message as read
                    if (message.receiverId == currentUserId && message.status != MessageStatus.read) {
                      chatController.markAsRead(message.id, widget.friend.uid);
                    }

                    bool isMe = message.senderId == currentUserId;
                    return _buildMessageBubble(
                      context,
                      message,
                      isMe,
                    );
                  },
                );
              },
            ),
          ),
          MessageComposer(
            onSendMessage: (text) {
              Provider.of<ChatController>(context, listen: false)
                  .sendTextMessage(widget.friend.uid, text);
            },
            onSendVoiceMessage: (file, duration) {
              Provider.of<ChatController>(context, listen: false)
                  .sendVoiceMessage(widget.friend.uid, file, duration);
            },
            onSendContact: (contact) {
              Provider.of<ChatController>(context, listen: false)
                  .sendContactMessage(widget.friend.uid, contact);
            },
            onSendImage: (file) {
              Provider.of<ChatController>(context, listen: false)
                  .sendImageMessage(widget.friend.uid, file);
            },
            onSendDocument: (file) {
              final chatController = Provider.of<ChatController>(context, listen: false);
              chatController.sendDocumentMessage(widget.friend.uid, file);
            },
            onSendAudio: (file) {
              final chatController = Provider.of<ChatController>(context, listen: false);
              chatController.sendAudioMessage(widget.friend.uid, file);
            },
            onSendLocation: (position) {
              final chatController = Provider.of<ChatController>(context, listen: false);
              chatController.sendLocationMessage(widget.friend.uid, position);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, Message message, bool isMe) {
    final time = DateFormat('hh:mm a').format(message.timestamp.toDate());

    Widget messageContent;
    if (message.type == MessageType.text) {
      messageContent = Text(message.text);
    } else if (message.type == MessageType.voice) {
      final duration = message.duration ?? 0;
      final minutes = (duration / 60).floor();
      final seconds = duration % 60;
      final durationString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      messageContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () async {
              if (message.url != null) {
                await _audioPlayer.play(UrlSource(message.url!));
              }
            },
          ),
          Text(durationString),
        ],
      );
    } else if (message.type == MessageType.contact) {
      messageContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message.contactName ?? 'Unknown Contact', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(message.contactNumber ?? ''),
        ],
      );
    } else if (message.type == MessageType.image) {
      messageContent = _buildImageMessage(message);
    } else if (message.type == MessageType.document) {
      messageContent = Row(
        children: [
          const Icon(Icons.insert_drive_file),
          const SizedBox(width: 8),
          Text(message.fileName ?? 'Document'),
        ],
      );
    } else if (message.type == MessageType.audio) {
      messageContent = Row(
        children: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () async {
              if (message.url != null) {
                await _audioPlayer.play(UrlSource(message.url!));
              }
            },
          ),
          Text(message.fileName ?? 'Audio'),
        ],
      );
    } else if (message.type == MessageType.location) {
      messageContent = InkWell(
        onTap: () async {
          final url = 'https://www.google.com/maps/search/?api=1&query=${message.latitude},${message.longitude}';
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url));
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Image.network(
              'https://maps.googleapis.com/maps/api/staticmap?center=${message.latitude},${message.longitude}&zoom=15&size=200x200&key=YOUR_API_KEY',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ],
        ),
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
                        message.status == MessageStatus.read ? Icons.done_all : Icons.check,
                        size: 16,
                        color: message.status == MessageStatus.read ? Colors.blue : Colors.grey,
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

  Widget _buildImageMessage(Message message) {
    if (message.localFile != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.file(
            message.localFile!,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
          const CircularProgressIndicator(),
        ],
      );
    } else if (message.imageUrl != null) {
      return Image.network(
        message.imageUrl!,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else {
      return const SizedBox(
        width: 200,
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
  }
}
