import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  Country _selectedCountry = Country(
    phoneCode: '44',
    countryCode: 'GB',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'United Kingdom',
    example: '7123456789',
    displayName: 'United Kingdom (GB) [+44]',
    displayNameNoCountryCode: 'United Kingdom (GB)',
    e164Key: '44-GB-0',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة صديق'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              // Navigate back
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
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
            ),
            const Spacer(),
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
