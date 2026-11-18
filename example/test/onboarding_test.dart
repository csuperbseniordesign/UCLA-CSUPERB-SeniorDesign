import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telematics_sdk_example/screens/onboarding_screen.dart';
 
Widget _host() => MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    const OnboardingScreen(userId: 'u1', isPhysician: false))),
            child: const Text('open'),
          ),
        ),
      ),
    );
 
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
 
  testWidgets('new user has not seen onboarding', (tester) async {
    expect(await OnboardingScreen.hasSeen('u1'), isFalse);
  });
 
  testWidgets('going through every page saves it and closes', (tester) async {
    await tester.pumpWidget(_host());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to EyeMyWay'), findsOneWidget);
 
    for (int i = 0; i < 3; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Home and Settings'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
 
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(await OnboardingScreen.hasSeen('u1'), isTrue);
  });
 
  testWidgets('skip saves it and closes', (tester) async {
    await tester.pumpWidget(_host());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
 
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(await OnboardingScreen.hasSeen('u1'), isTrue);
  });
}
