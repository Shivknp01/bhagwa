import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ringtone_set_plus/ringtone_set_plus.dart';

enum RingtoneType {
  ringtone,
  notification,
  alarm,
}

abstract class RingtoneService {
  Future<bool> setRingtone(String audioUrl, String title, {RingtoneType type = RingtoneType.ringtone});
}

class AndroidRingtoneService implements RingtoneService {
  @override
  Future<bool> setRingtone(String audioUrl, String title, {RingtoneType type = RingtoneType.ringtone}) async {
    try {
      switch (type) {
        case RingtoneType.ringtone:
          await RingtoneSet.setRingtoneFromNetwork(audioUrl);
        case RingtoneType.notification:
          await RingtoneSet.setNotificationFromNetwork(audioUrl);
        case RingtoneType.alarm:
          await RingtoneSet.setAlarmFromNetwork(audioUrl);
      }
      return true;
    } catch (e) {
      debugPrint('RingtoneService error: $e');
      return false;
    }
  }
}

class MockRingtoneService implements RingtoneService {
  @override
  Future<bool> setRingtone(String audioUrl, String title, {RingtoneType type = RingtoneType.ringtone}) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return true;
  }
}

final ringtoneServiceProvider = Provider<RingtoneService>((ref) {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return AndroidRingtoneService();
  }
  return MockRingtoneService();
});
