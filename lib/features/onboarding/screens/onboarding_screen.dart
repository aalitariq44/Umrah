import 'package:flutter/material.dart';
import 'package:myplace/features/onboarding/model/onboard.dart';
import 'package:myplace/features/auth/screens/login_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  late PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<OnBoard> _onBoardData = [
    OnBoard(
      icon: Icons.people,
      title: 'اعرف أماكن أحبائك بسهولة',
      description:
          'تتبع أماكن الأشخاص المهمين في حياتك مباشرة من هاتفك. التطبيق يتيح لك معرفة موقعهم بدقة وفي الوقت.',
    ),
    OnBoard(
      icon: Icons.location_on,
      title: 'استغاثة بنقرة واحدة',
      description:
          'إذا كنت في موقف خطر أو حالة طارئة، يمكنك إرسال استغاثة بضغطة زر، ليصل تنبيه سريع إليهم.',
    ),
    OnBoard(
      icon: Icons.security,
      title: 'آمان أكثر لعائلتك وأصدقائك',
      description:
          'بإمكانك الاطمئنان على سلامة أحبائك في أي وقت، وتكون على دراية بمواقعهم عند الحاجة.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const LoginScreen(),
                    //   ),
                    // );
                  },
                  child: const Text(
                    'تخطي',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _pageIndex = index;
                    });
                  },
                  itemCount: _onBoardData.length,
                  itemBuilder: (context, index) {
                    return OnBoardContent(
                      icon: _onBoardData[index].icon,
                      title: _onBoardData[index].title,
                      description: _onBoardData[index].description,
                    );
                  },
                ),
              ),
              Row(
                children: [
                  ...List.generate(
                    _onBoardData.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: DotIndicator(isActive: index == _pageIndex),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_pageIndex < _onBoardData.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        } else {
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const LoginScreen(),
                          //   ),
                          // );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                      ),
                      child: const Icon(Icons.arrow_forward),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    this.isActive = false,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isActive ? 12 : 4,
      width: 4,
      decoration: BoxDecoration(
        color: isActive ? Colors.orange : Colors.grey,
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
      ),
    );
  }
}

class OnBoardContent extends StatelessWidget {
  const OnBoardContent({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 150,
          color: Colors.orange,
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
