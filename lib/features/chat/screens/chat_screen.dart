import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myplace/data/models/user_model.dart' as model;
import 'package:myplace/features/chat/controller/chat_controller.dart';
import 'package:myplace/features/chat/widgets/message_composer.dart';
import 'package:myplace/features/call/services/call_manager.dart';
import 'package:myplace/data/models/message_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/clickable_text.dart';
import '../widgets/document_viewer.dart';
import '../widgets/location_message_widget.dart';
import 'image_viewer_screen.dart';

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
      messageContent = ClickableText(
        text: message.text,
        style: const TextStyle(fontSize: 16),
      );
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
          const SizedBox(height: 4),
          ClickableText(
            text: message.contactNumber ?? '',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      );
    } else if (message.type == MessageType.image) {
      messageContent = _buildImageMessage(message);
    } else if (message.type == MessageType.document) {
      messageContent = DocumentViewer(
        fileName: message.fileName,
        fileUrl: message.url,
      );
    } else if (message.type == MessageType.audio) {
      messageContent = Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: Row(
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
            const SizedBox(width: 8),
            Flexible(
              child: Text(message.fileName ?? 'Audio'),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.open_in_new, size: 16),
              onPressed: () async {
                if (message.url != null) {
                  final uri = Uri.parse(message.url!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
            ),
          ],
        ),
      );
    } else if (message.type == MessageType.location) {
      messageContent = LocationMessageWidget(
        latitude: message.latitude,
        longitude: message.longitude,
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
    Widget imageWidget;
    
    if (message.localFile != null) {
      imageWidget = Stack(
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
      imageWidget = Image.network(
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
      imageWidget = const SizedBox(
        width: 200,
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    return GestureDetector(
      onTap: () async {
        if (message.imageUrl != null) {
          // فتح في عارض الصور الداخلي
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewerScreen(
                imageUrl: message.imageUrl!,
                heroTag: message.id,
              ),
            ),
          );
        }
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageWidget,
          ),
          if (message.imageUrl != null)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.open_in_new,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
