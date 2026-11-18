import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
 
/// One page of the onboarding walkthrough.
class _OnboardingPage {
  final IconData icon;
  final String title;
  final String body;
 
  const _OnboardingPage(this.icon, this.title, this.body);
}
 
const _patientPages = [
  _OnboardingPage(
    Icons.remove_red_eye_outlined,
    'Welcome to EyeMyWay',
    'EyeMyWay records your driving habits so you and your doctor can see '
        'how your vision affects your driving over time.',
  ),
  _OnboardingPage(
    Icons.directions_car_outlined,
    'Tracking Is Automatic',
    'Trips are recorded in the background, so you do not need to open the '
        'app before you drive. Keep location permissions on and turn off '
        'battery optimization for this app so no trips are missed.',
  ),
  _OnboardingPage(
    Icons.help_outline,
    'Were You Driving?',
    'When a trip ends, the app may ask if you were the driver. Answer this '
        'so trips where you were a passenger are not counted.',
  ),
  _OnboardingPage(
    Icons.home_outlined,
    'Home and Settings',
    'Home shows whether tracking is on. Settings lets you edit your profile, '
        'request your data, and read the privacy policy. Tap the info icon on '
        'Home any time to see the tutorial.',
  ),
];
 
const _physicianPages = [
  _OnboardingPage(
    Icons.remove_red_eye_outlined,
    'Welcome to EyeMyWay',
    'EyeMyWay lets you review the driving habits of your glaucoma patients.',
  ),
  _OnboardingPage(
    Icons.people_outline,
    'Your Patients',
    'Your patients appear on the Home screen. Tap a patient to see their '
        'total trips, mileage, time driven, and summary scores.',
  ),
  _OnboardingPage(
    Icons.analytics_outlined,
    'Drive Analytics',
    'Tap View More Drive Analytics to see each trip from the past two weeks, '
        'including how much of it was driven at night.',
  ),
  _OnboardingPage(
    Icons.settings_outlined,
    'Settings',
    'Use Settings to manage your profile and view information about the app.',
  ),
];
 
/// Full screen walkthrough shown the first time a user reaches the home
/// screen after signing in or signing up.
class OnboardingScreen extends StatefulWidget {
  final String userId;
  final bool isPhysician;
 
  const OnboardingScreen({
    super.key,
    required this.userId,
    required this.isPhysician,
  });
 
  static String _key(String userId) => 'hasSeenOnboarding_$userId';
 
  /// Whether this user already finished or skipped onboarding on this device.
  static Future<bool> hasSeen(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(userId)) ?? false;
  }
 
  static Future<void> markSeen(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(userId), true);
  }
 
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}
 
class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _accent = Color.fromARGB(255, 103, 139, 183);
 
  final PageController _controller = PageController();
  int _index = 0;
 
  List<_OnboardingPage> get _pages =>
      widget.isPhysician ? _physicianPages : _patientPages;
 
  bool get _isLastPage => _index == _pages.length - 1;
 
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
 
  Future<void> _finish() async {
    await OnboardingScreen.markSeen(widget.userId);
    if (!mounted) return;
    Navigator.of(context).pop();
  }
 
  void _next() {
    if (_isLastPage) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Make the user tap Skip or Get Started so the choice is saved.
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _isLastPage
                    ? const SizedBox(height: 48)
                    : TextButton(
                        onPressed: _finish,
                        child: const Text('Skip',
                            style: TextStyle(color: _accent)),
                      ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) => _PageContent(page: _pages[i]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final bool active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: active ? 24 : 8,
                    decoration: BoxDecoration(
                      color: active ? _accent : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _next,
                    child: Text(_isLastPage ? 'Get Started' : 'Next'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 
class _PageContent extends StatelessWidget {
  final _OnboardingPage page;
 
  const _PageContent({required this.page});
 
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(page.icon,
              size: 110, color: const Color.fromARGB(255, 103, 139, 183)),
          const SizedBox(height: 40),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
