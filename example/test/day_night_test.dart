import 'package:flutter_test/flutter_test.dart';
import 'package:telematics_sdk_example/services/day_night.dart';
 
void main() {
  // Daylight from 6:00 AM to 7:00 PM for all tests
  const dayStart = 6 * 60;
  const nightStart = 19 * 60;
 
  DayNightSplit split(DateTime a, DateTime b) => splitDayNight(a, b,
      dayStartMinute: dayStart, nightStartMinute: nightStart);
 
  test('afternoon trip is all day', () {
    final s = split(DateTime(2026, 11, 10, 14, 0), DateTime(2026, 11, 10, 14, 30));
    expect(s.dayMinutes, 30);
    expect(s.nightMinutes, 0);
    expect(s.label, 'Day');
  });
 
  test('late night trip is all night', () {
    final s = split(DateTime(2026, 11, 10, 22, 0), DateTime(2026, 11, 10, 22, 45));
    expect(s.nightMinutes, 45);
    expect(s.label, 'Night');
  });
 
  test('trip across 7 PM is split', () {
    final s = split(DateTime(2026, 11, 10, 18, 40), DateTime(2026, 11, 10, 19, 20));
    expect(s.dayMinutes, 20);
    expect(s.nightMinutes, 20);
    expect(s.label, 'Day + Night');
  });
 
  test('trip across midnight is all night', () {
    final s = split(DateTime(2026, 11, 10, 23, 50), DateTime(2026, 11, 11, 0, 10));
    expect(s.nightMinutes, 20);
    expect(s.label, 'Night');
  });
 
  test('trip across 6 AM is split', () {
    final s = split(DateTime(2026, 11, 11, 5, 50), DateTime(2026, 11, 11, 6, 5));
    expect(s.nightMinutes, 10);
    expect(s.dayMinutes, 5);
  });
 
  test('zero length trip has no minutes', () {
    final t = DateTime(2026, 11, 10, 12, 0);
    final s = split(t, t);
    expect(s.dayMinutes + s.nightMinutes, 0);
    expect(s.label, 'Day');
  });
}
