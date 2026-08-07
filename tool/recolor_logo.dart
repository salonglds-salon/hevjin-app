import 'dart:io';
import 'package:image/image.dart' as img;

// Replaces the dark navy background of logo.png with dark orange.
// Gold letter stays untouched.
void main() {
  final src = File('assets/images/logo.png');
  final bytes = src.readAsBytesSync();
  final image = img.decodePng(bytes);
  if (image == null) {
    print('ERROR: could not decode logo.png');
    return;
  }

  print('Size: ${image.width}x${image.height}');

  // Sample corner pixel to learn the background color
  final c = image.getPixel(2, 2);
  print('Corner RGB: ${c.r.toInt()}, ${c.g.toInt()}, ${c.b.toInt()}');

  // Target: dark orange
  const tr = 139; // 0x8B
  const tg = 58;  // 0x3A
  const tb = 15;  // 0x0F

  int changed = 0;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final p = image.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      final a = p.a.toInt();

      if (a < 10) continue; // transparent -> skip

      // Detect "dark bluish" pixels: blue dominant, overall dark
      final maxc = [r, g, b].reduce((v, e) => v > e ? v : e);
      final isDark = maxc < 110;
      final isBluish = b >= r && b >= g;

      if (isDark && isBluish) {
        // Preserve relative brightness for soft edges/antialiasing
        final f = maxc == 0 ? 0.0 : (maxc / 110.0).clamp(0.0, 1.0);
        // blend toward target based on darkness (keeps subtle shading)
        final nr = (tr * (0.55 + 0.45 * f)).round().clamp(0, 255);
        final ng = (tg * (0.55 + 0.45 * f)).round().clamp(0, 255);
        final nb = (tb * (0.55 + 0.45 * f)).round().clamp(0, 255);
        image.setPixelRgba(x, y, nr, ng, nb, a);
        changed++;
      }
    }
  }

  print('Changed pixels: $changed');

  // Backup original once
  final backup = File('assets/images/logo_navy_backup.png');
  if (!backup.existsSync()) {
    backup.writeAsBytesSync(bytes);
    print('Backup saved: logo_navy_backup.png');
  }

  src.writeAsBytesSync(img.encodePng(image));
  print('DONE: logo.png recolored to dark orange');
}
