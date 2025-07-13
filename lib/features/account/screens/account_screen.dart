import 'package:flutter/material.dart';
import 'package:myplace/features/account/screens/contact_us_screen.dart';
import 'package:myplace/features/account/screens/edit_profile_screen.dart';
import 'package:myplace/features/account/screens/language_selection_sheet.dart';
import 'package:myplace/features/account/screens/legal_page.dart';
import 'package:country_picker/country_picker.dart';
import 'package:myplace/features/auth/controller/auth_controller.dart';
import 'package:myplace/features/auth/screens/login_screen.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  Country _selectedCountry = Country.parse('IQ');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authController = Provider.of<AuthController>(context, listen: false);
      if (authController.user == null) {
        await authController.loadCurrentUser();
      }
      if (mounted) {
        _nameController.text = authController.user?.name ?? '';
        _phoneController.text = authController.user?.phone ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showEditNameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل الاسم'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'ادخل اسمك'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('الغاء'),
            ),
            TextButton(
              onPressed: () async {
                await Provider.of<AuthController>(context, listen: false)
                    .updateUserName(_nameController.text);
                Navigator.of(context).pop();
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _showEditPhoneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل رقم الهاتف'),
          content: TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              hintText: 'ادخل رقم هاتفك',
              prefixIcon: InkWell(
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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('${_selectedCountry.flagEmoji} +${_selectedCountry.phoneCode}'),
                ),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('الغاء'),
            ),
            TextButton(
              onPressed: () async {
                await Provider.of<AuthController>(context, listen: false)
                    .updateUserPhone('+${_selectedCountry.phoneCode}${_phoneController.text}');
                Navigator.of(context).pop();
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.user;

    ImageProvider<Object>? backgroundImage;
    if (user?.photoUrl != null && user!.photoUrl.isNotEmpty) {
      backgroundImage = NetworkImage(user.photoUrl);
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: backgroundImage,
                      child: backgroundImage == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.orange,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _showEditNameDialog(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user?.name ?? 'اضف اسمك',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _showEditPhoneDialog(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user?.phone ?? 'اضف رقم هاتفك',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildSectionTitle('حسابي'),
                _buildListTile(context, 'تعديل بياناتك الشخصيه', Icons.person_outline, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                }),
                const Divider(),
                _buildSectionTitle('الخصائص'),
                _buildListTile(context, 'اللغه', Icons.language_outlined, () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => const LanguageSelectionSheet(),
                  );
                }),
                _buildListTile(context, 'تواصل معنا', Icons.chat_bubble_outline, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactUsScreen(),
                    ),
                  );
                }),
                _buildListTile(context, 'الشروط و الاحكام', Icons.help_outline, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LegalPage(
                        title: 'الشروط و الاحكام',
                        content: 'هذا النص هو مثال لنص يمكن أن يستبدل في نفس المساحة، لقد تم توليد هذا النص من مولد النصوص العربى، حيث يمكنك أن تولد مثل هذا النص أو العديد من النصوص الأخرى إضافة إلى زيادة عدد الحروف التى يولدها التطبيق.\n\nإذا كنت تحتاج إلى عدد أكبر من الفقرات يتيح لك مولد النصوص العربى زيادة عدد الفقرات كما تريد، النص لن يبدو مقسما ولا يحوي أخطاء لغوية، مولد النصوص العربى مفيد لمصممي المواقع على وجه الخصوص، حيث يحتاج العميل في كثير من الأحيان أن يطلع على صورة حقيقية لتصميم الموقع.',
                      ),
                    ),
                  );
                }),
                _buildListTile(context, 'السياسه و الخصوصيه', Icons.shield_outlined, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LegalPage(
                        title: 'السياسه و الخصوصيه',
                        content: 'هذا النص هو مثال لنص يمكن أن يستبدل في نفس المساحة، لقد تم توليد هذا النص من مولد النصوص العربى، حيث يمكنك أن تولد مثل هذا النص أو العديد من النصوص الأخرى إضافة إلى زيادة عدد الحروف التى يولدها التطبيق.\n\nإذا كنت تحتاج إلى عدد أكبر من الفقرات يتيح لك مولد النصوص العربى زيادة عدد الفقرات كما تريد، النص لن يبدو مقسما ولا يحوي أخطاء لغوية، مولد النصوص العربى مفيد لمصممي المواقع على وجه الخصوص، حيث يحتاج العميل في كثير من الأحيان أن يطلع على صورة حقيقية لتصميم الموقع.',
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        title: const Text('هل تريد تسجيل الخروج؟', textAlign: TextAlign.center),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('لا ، أريد'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await Provider.of<AuthController>(context, listen: false).signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            },
                            child: const Text('نعم', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                        actionsAlignment: MainAxisAlignment.spaceAround,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('تسجيل الخروج'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      title: Text(title, textAlign: TextAlign.right),
      trailing: Icon(icon),
      leading: const Icon(Icons.arrow_back_ios),
      onTap: onTap,
    );
  }
}
