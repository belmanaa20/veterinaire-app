import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformUtils {
  /// Check if running on desktop (Windows, macOS, Linux, or Web with wide screen)
  static bool get isDesktop {
    if (kIsWeb) {
      // On web, consider it desktop if screen is wide enough
      return true; // Will be refined in widget with MediaQuery
    }
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  /// Check if running on mobile (Android or iOS)
  static bool get isMobile {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Check if screen is wide enough for desktop layout (based on width)
  static bool isWideScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  /// Get responsive padding based on screen width
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1920) {
      return const EdgeInsets.all(32);
    } else if (width >= 1366) {
      return const EdgeInsets.all(24);
    } else if (width >= 768) {
      return const EdgeInsets.all(16);
    }
    return const EdgeInsets.all(12);
  }

  /// Get number of columns for grid based on screen width
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1920) return 4;
    if (width >= 1366) return 3;
    if (width >= 768) return 2;
    return 1;
  }
}
