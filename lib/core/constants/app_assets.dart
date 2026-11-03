/// Asset paths under [assets/images/].
abstract final class AppAssets {
  /// Full wordmark with emblem and tagline (in-app splash, login, headers).
  static const String logo = 'assets/images/logo.png';

  /// Emblem-only mark for compact layouts.
  static const String logoEmblem = 'assets/images/logo_emblem.png';

  /// Centered emblem for Android 12+ and native launch splash generation.
  static const String splashNative = 'assets/images/splash_native.png';

  /// Legacy square launcher source (reference).
  static const String launcherIcon = 'assets/images/launcher_icon.png';

  /// Adaptive launcher foreground layer.
  static const String launcherForeground =
      'assets/images/launcher_foreground.png';
}
