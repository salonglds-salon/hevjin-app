/// Erkennt, ob die App als installierte PWA laeuft (Homescreen / Standalone).
///
/// Absichtlich OHNE dart:html / dart:js_interop / package:web implementiert -
/// web-only Imports brechen den Android-Build (siehe dart:ui_web-Problem).
/// Stattdessen setzt manifest.json start_url auf "/?pwa=1"; nur ein Start ueber
/// das Homescreen-Icon oeffnet die App mit diesem Parameter.
class AppMode {
  AppMode._();

  static bool _isPwa = false;

  /// true = App wurde aus dem Homescreen/Standalone-Modus gestartet.
  static bool get isPwa => _isPwa;

  /// Einmalig in main() aufrufen, VOR runApp().
  static void init() {
    try {
      _isPwa = Uri.base.queryParameters['pwa'] == '1';
    } catch (_) {
      _isPwa = false;
    }
  }
}
