import 'package:flutter/material.dart';
import 'package:myplace/data/models/user_model.dart' as model;
import 'package:myplace/features/auth/controller/auth_controller.dart';
import 'package:myplace/features/chat/screens/add_friend_screen.dart';
import 'package:myplace/features/chat/screens/chat_screen.dart';
import 'package:myplace/features/chat/screens/create_group_screen.dart';
import 'package:provider/provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    // Friends are now loaded in AuthController's loadCurrentUser
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الرسائل'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_friend') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddFriendScreen(),
                  ),
                );
              } else if (value == 'create_group') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateGroupScreen(),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'add_friend',
                  child: Row(
                    children: [
                      Icon(Icons.person_add_alt_1_outlined),
                      SizedBox(width: 8),
                      Text('إضافة صديق'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'create_group',
                  child: Row(
                    children: [
                      Icon(Icons.group_add_outlined),
                      SizedBox(width: 8),
                      Text('إنشاء مجموعة'),
                    ],
                  ),
                ),
              ];
            },
            icon: const Icon(Icons.add_circle),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'البحث',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          if (authController.friendRequests.isNotEmpty)
            _buildFriendRequestsSection(context, authController),
          if (authController.sentFriendRequests.isNotEmpty)
            _buildSentFriendRequestsSection(context, authController),
          Expanded(
            child: authController.friends.isEmpty
                ? const Center(child: Text('لا يوجد أصدقاء بعد'))
                : ListView.builder(
                    itemCount: authController.friends.length,
                    itemBuilder: (context, index) {
                      final friend = authController.friends[index];
                      return _buildMessageTile(
                          context, friend, friend.phone, '...', false);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendRequestsSection(
      BuildContext context, AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('طلبات الصداقة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: authController.friendRequests.length,
          itemBuilder: (context, index) {
            final requester = authController.friendRequests[index];
            return _buildFriendRequestTile(context, requester, authController);
          },
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildFriendRequestTile(BuildContext context, model.User requester,
      AuthController authController) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      title: Text('${requester.name} يريد إضافتك كصديق'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              authController.acceptFriendRequest(requester.uid);
            },
            child: const Text('قبول'),
          ),
          TextButton(
            onPressed: () {
              authController.declineFriendRequest(requester.uid);
            },
            child: const Text('رفض', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSentFriendRequestsSection(
      BuildContext context, AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('طلبات الصداقة المرسلة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: authController.sentFriendRequests.length,
          itemBuilder: (context, index) {
            final receiver = authController.sentFriendRequests[index];
            return _buildSentFriendRequestTile(context, receiver);
          },
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildSentFriendRequestTile(
      BuildContext context, model.User receiver) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      title: Text('تم إرسال طلب صداقة إلى ${receiver.name}'),
      trailing: const Text('بانتظار القبول'),
    );
  }

  Widget _buildMessageTile(
      BuildContext context, model.User friend, String message, String time, bool unread) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(friend: friend),
          ),
        );
      },
      leading: const CircleAvatar(
        radius: 30,
        child: Icon(Icons.person),
      ),
      title: Text(friend.name),
      subtitle: Text(message),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time),
          if (unread)
            const CircleAvatar(
              radius: 10,
              backgroundColor: Colors.orange,
              child: Text(
                '1',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
