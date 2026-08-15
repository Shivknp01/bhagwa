import 'package:flutter_riverpod/flutter_riverpod.dart';

enum WallpaperTarget {
  homeScreen,
  lockScreen,
  both,
}

abstract class WallpaperService {
  Future<bool> setWallpaper(String imageUrl, WallpaperTarget target);
}

class MockWallpaperService implements WallpaperService {
  @override
  Future<bool> setWallpaper(String imageUrl, WallpaperTarget target) async {
    // Simulate setting wallpaper on Android native side
    await Future.delayed(const Duration(milliseconds: 1200));
    return true;
  }
}

final wallpaperServiceProvider = Provider<WallpaperService>((ref) {
  return MockWallpaperService();
});
