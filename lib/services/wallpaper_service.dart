import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

/// Where to apply the wallpaper.
enum WallpaperTarget {
  homeScreen,
  lockScreen,
  both,
}

abstract class WallpaperService {
  Future<bool> setWallpaper(String imageUrl, WallpaperTarget target);
}

class AndroidWallpaperService implements WallpaperService {
  static final _manager = WallpaperManagerFlutter();

  @override
  Future<bool> setWallpaper(String imageUrl, WallpaperTarget target) async {
    try {
      // Download image to local cache
      final file = await DefaultCacheManager().getSingleFile(imageUrl);

      // Map target enum to plugin constant
      final location = switch (target) {
        WallpaperTarget.homeScreen => WallpaperManagerFlutter.homeScreen,
        WallpaperTarget.lockScreen => WallpaperManagerFlutter.lockScreen,
        WallpaperTarget.both       => WallpaperManagerFlutter.bothScreens,
      };

      final result = await _manager.setWallpaper(File(file.path), location);
      return result;
    } catch (e) {
      debugPrint('WallpaperService error: $e');
      return false;
    }
  }
}

class MockWallpaperService implements WallpaperService {
  @override
  Future<bool> setWallpaper(String imageUrl, WallpaperTarget target) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return true;
  }
}

final wallpaperServiceProvider = Provider<WallpaperService>((ref) {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return AndroidWallpaperService();
  }
  return MockWallpaperService();
});
