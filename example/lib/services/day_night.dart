import 'dart:convert';
 
import 'package:http/http.dart' as http;
 
/// How much of a trip happened in daylight vs at night.
enum TripLighting { day, night, mixed }
 
/// Result of splitting one trip into day minutes and night minutes.
class DayNightSplit {
  final int dayMinutes;
  final int nightMinutes;
 
  const DayNightSplit(this.dayMinutes, this.nightMinutes);
 
  /// Day = no night minutes, Night = only night minutes, Mixed = both.
  TripLighting get lighting {
    if (nightMinutes == 0) return TripLighting.day;
    if (dayMinutes == 0) return TripLighting.night;
    return TripLighting.mixed;
  }
 
  bool get hasNightDriving => nightMinutes > 0;
 
  String get label {
    switch (lighting) {
      case TripLighting.day:
        return 'Day';
      case TripLighting.night:
        return 'Night';
      case TripLighting.mixed:
        return 'Day + Night';
    }
  }
}
 
/// Fallback night hours used when the sunrise/sunset lookup fails (7 PM to 6 AM).
const int defaultDayStartMinute = 6 * 60;
const int defaultNightStartMinute = 19 * 60;
 
/// Splits a trip into day and night minutes.
///
/// [dayStartMinute] and [nightStartMinute] are minutes after local midnight
/// (for example 6:30 AM = 390). Any minute before [dayStartMinute] or at/after
/// [nightStartMinute] counts as night. Trips that cross midnight are handled
/// because the check is done on each minute's own time of day.
DayNightSplit splitDayNight(
  DateTime start,
  DateTime end, {
  int dayStartMinute = defaultDayStartMinute,
  int nightStartMinute = defaultNightStartMinute,
}) {
  DateTime t = start.toLocal();
  final DateTime last = end.toLocal();
  int day = 0;
  int night = 0;
 
  while (t.isBefore(last)) {
    final int minuteOfDay = t.hour * 60 + t.minute;
    final bool isNight =
        minuteOfDay < dayStartMinute || minuteOfDay >= nightStartMinute;
    if (isNight) {
      night++;
    } else {
      day++;
    }
    t = t.add(const Duration(minutes: 1));
  }
 
  return DayNightSplit(day, night);
}
 
/// Looks up when daylight starts and ends for a date and place, using
/// api.sunrise-sunset.org. Results are cached per date and location so a
/// list of trips only makes one request per day instead of two per trip.
class SunTimesService {
  final Map<String, (int, int)> _cache = {};
 
  /// Returns (dayStartMinute, nightStartMinute) in local time.
  ///
  /// Keeps the same rule the trips screen already used: daylight starts
  /// 30 minutes after sunrise and night starts 30 minutes before sunset.
  /// Falls back to 6 AM / 7 PM if the request fails.
  Future<(int, int)> getDayWindow(
      DateTime date, double latitude, double longitude) async {
    final DateTime local = date.toLocal();
    final String key = '${local.year}-${local.month}-${local.day}'
        '_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';
 
    final cached = _cache[key];
    if (cached != null) return cached;
 
    (int, int) window = (defaultDayStartMinute, defaultNightStartMinute);
 
    try {
      final response = await http.get(Uri.parse(
          'https://api.sunrise-sunset.org/json?lat=$latitude&lng=$longitude'
          '&date=${local.year}-${local.month}-${local.day}&formatted=0'));
 
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final DateTime sunrise =
              DateTime.parse(data['results']['sunrise']).toLocal();
          final DateTime sunset =
              DateTime.parse(data['results']['sunset']).toLocal();
 
          final DateTime dayStart = sunrise.add(const Duration(minutes: 30));
          final DateTime nightStart =
              sunset.subtract(const Duration(minutes: 30));
 
          window = (
            dayStart.hour * 60 + dayStart.minute,
            nightStart.hour * 60 + nightStart.minute,
          );
        }
      }
    } catch (e) {
      print('Error getting sunrise/sunset times, using 6 AM / 7 PM: $e');
    }
 
    _cache[key] = window;
    return window;
  }
}
