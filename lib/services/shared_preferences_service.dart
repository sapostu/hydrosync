import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String _reminderIntervalKey = 'reminder_interval';

  Future<int> getReminderInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_reminderIntervalKey) ?? 5; // Default to 5 minutes
  }

  Future<void> setReminderInterval(int interval) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderIntervalKey, interval);
  }
}
