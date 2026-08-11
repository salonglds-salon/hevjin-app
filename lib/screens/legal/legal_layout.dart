import 'package:flutter/material.dart';

/// Wrapper fuer alle Rechtstext-Seiten (Impressum, Datenschutz, AGB).
///
/// Der Inhalt dieser Seiten ist bewusst immer auf Deutsch, weil die
/// deutsche Fassung die rechtlich verbindliche ist. Damit der deutsche
/// Fliesstext auch bei RTL-Sprachen (ar, fa) korrekt gerendert wird,
/// erzwingt dieses Widget TextDirection.ltr fuer den Body.
///
/// Zusaetzlich begrenzt es die Lesebreite auf 800px, damit der Text auf
/// Desktop nicht ueber die volle Bildschirmbreite laeuft.
class LegalBody extends StatelessWidget {
  final Widget child;

  const LegalBody({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}
