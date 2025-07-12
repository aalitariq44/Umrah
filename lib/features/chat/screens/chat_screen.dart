import 'package:flutter/material.dart';
import 'package:myplace/features/chat/screens/call_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {},
        ),
        title: const Text('رسالة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  // backgroundImage: ...
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('لعبة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('3 أعضاء', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.call_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CallScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.videocam_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CallScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildMessageBubble(context, 'مرحباً!', '1:10', true),
                _buildMessageBubble(context, 'رائع، شكراً لإعلامي! أتطلع حقاً إلى تجربته قريباً.', '1:11', true),
                _buildMessageBubble(context, 'هل يصلح هذا التحديث الخطأ ٣٥٢ لشخصية المهندس؟', '1:11', false, name: 'ديفيد واين'),
                _buildMessageBubble(context, 'أوه! لقد أصلحوه وقاموا بتعزيز الأمان بشكل أكبر. 🚀', '1:14', false, name: 'إدوارد ديفيدسون'),
                _buildMessageBubble(context, 'رائع! 😊', '1:20', true),
              ],
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, String text, String time, bool isMe, {String? name}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (name != null)
            Padding(
              padding: const EdgeInsets.only(left: 48.0, bottom: 4.0),
              child: Text(name, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe) const CircleAvatar(radius: 15 /*backgroundImage: ...*/),
              const SizedBox(width: 8),
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                decoration: BoxDecoration(
                  color: isMe ? Colors.orange[300] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(time, style: const TextStyle(fontSize: 10)),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.check, size: 12),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'اكتب رسالة...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.attach_file),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
