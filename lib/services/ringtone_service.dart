import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class RingtoneService {
  Future<bool> setRingtone(String audioUrl, String title);
}

class MockRingtoneService implements RingtoneService {
  @override
  Future<bool> setRingtone(String audioUrl, String title) async {
    // Simulate setting ringtone on Android native side
    await Future.delayed(const Duration(milliseconds: 1000));
    return true;
  }
}

final ringtoneServiceProvider = Provider<RingtoneService>((ref) {
  return MockRingtoneService();
});
