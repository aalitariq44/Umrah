import 'package:flutter/material.dart';
import 'package:myplace/features/account/screens/change_email_screen.dart';
import 'package:myplace/features/account/screens/change_password_screen.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل بياناتك الشخصيه'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildEditTile(
              context,
              'البريد الالكتروني',
              Icons.email_outlined,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangeEmailScreen()),
                );
              },
            ),
            const Divider(),
            _buildEditTile(context, 'كلمه المرور', Icons.lock_outline, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            }),
            const Divider(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      title: Text(title, textAlign: TextAlign.right),
      trailing: Icon(icon),
      leading: const Icon(Icons.arrow_back_ios),
      onTap: onTap,
    );
  }
}
