import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:myplace/data/models/user_model.dart' as model;
import 'package:myplace/features/auth/controller/auth_controller.dart';
import 'package:provider/provider.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _phoneController = TextEditingController();
  model.User? _searchedUser;
  bool _isLoading = false;
  String? _errorMessage;

  Country _selectedCountry = Country(
    phoneCode: '964',
    countryCode: 'IQ',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Iraq',
    example: '7123456789',
    displayName: 'Iraq (IQ) [+964]',
    displayNameNoCountryCode: 'Iraq (IQ)',
    e164Key: '964-IQ-0',
  );

  void _searchUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchedUser = null;
    });

    final authController = Provider.of<AuthController>(context, listen: false);
    final fullPhoneNumber =
        '+${_selectedCountry.phoneCode}${_phoneController.text}';

    try {
      final user = await authController.searchUserByPhone(fullPhoneNumber);
      setState(() {
        _searchedUser = user;
        if (user == null) {
          _errorMessage = 'لم يتم العثور على المستخدم';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء البحث';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة صديق'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: 'أدخل رقم الهاتف',
                prefixIcon: GestureDetector(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      onSelect: (Country country) {
                        setState(() {
                          _selectedCountry = country;
                        });
                      },
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 8),
                      Text(_selectedCountry.flagEmoji),
                      const SizedBox(width: 4),
                      Text('+${_selectedCountry.phoneCode}'),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchUser,
              child: const Text('بحث'),
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              )
            else if (_searchedUser != null)
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(_searchedUser!.name),
                subtitle: Text(_searchedUser!.phone),
                trailing: ElevatedButton(
                  onPressed: () async {
                    if (_searchedUser != null) {
                      final authController = Provider.of<AuthController>(context, listen: false);
                      await authController.addFriend(_searchedUser!.uid);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('إضافة'),
                ),
              )
            else
              Icon(
                Icons.contact_page_outlined,
                size: 150,
                color: Colors.grey[300],
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
