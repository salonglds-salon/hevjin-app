# Hevjîn — To-Do (Stand: 09.08.2026, 17:00)

## 1. Deploy der heutigen Änderungen (ZUERST)
Fertig im Code, aber noch NICHT live auf hevjin.app:
- [ ] `flutter build web --release --base-href="/"` (~110s, Start-Process + Log-Polling)
- [ ] `Set-Content build/web/CNAME 'hevjin.app' -NoNewline`
- [ ] `index.html` → `404.html` kopieren
- [ ] `cd build/web && git add -A && git commit && git push` (gh-pages, GitHub Token)
- [ ] 2x Reload im Browser (1. Reload killt alten Service Worker), CDN 5-20 Min abwarten

Enthaltene Fixes:
- match_screen.dart: Hint-Text lesbar (#E8DCD2), Name kapitalisiert (_cap), Eingabefeld-Kontrast
- home_screen.dart: Discover Empty-State sichtbar + "Neu laden"-Button + Tipp-Zeile
- main.dart: ErrorWidget.builder — zeigt Fehlermeldung statt grauem Kasten

## 2. Discover-Crash finden (grauer Block)
- [ ] Nach Deploy: Discover auf dem Handy öffnen
- [ ] Fehlermeldung ablesen (steht klein unter "Hier ist etwas schiefgelaufen")
- [ ] Ursache fixen — Verdacht: _photoCard / _buildNarrowLayout bei Profil mit unvollständigen Daten
- [ ] Danach prüfen, ob der neue Empty-State korrekt erscheint

## 2b. Match-Screen mit echten Daten testen (nach Test-Account, siehe Block 4)
- [ ] Als Test-Account einloggen -> Hauptprofil liken
- [ ] Ausloggen, als Hauptaccount einloggen -> Test-Profil liken
- [ ] Match-Screen muss erscheinen: Eingabefeld weiß mit dunklem Text (lesbar),
      Name kapitalisiert ("Test-Account" statt "test-account"), Avatare mit echten Fotos
- [ ] Sofort-Nachricht senden -> muss im Chat landen

## 3. E-Mail / Spam-Problem
DNS ist sauber (SPF, DKIM, DMARC alle vorhanden und korrekt). Offene Punkte:
- [ ] Original-Header einer Spam-Mail prüfen (Gmail → "Original anzeigen" → Authentication-Results)
- [ ] Resend Dashboard → Logs: Bounce-/Complaint-Rate, spf=/dkim= Ergebnisse
- [ ] DKIM-Key von 1024 auf 2048 bit upgraden (Resend → Domains → Regenerate, neuen TXT bei IONOS)
- [ ] DMARC von p=none auf p=quarantine (erst wenn RUA-Reports sauber):
      v=DMARC1; p=quarantine; sp=quarantine; adkim=s; aspf=r; rua=mailto:hevjinsupport@gmail.com; fo=1
- [ ] Supabase Custom Auth Domain (Pro ~25$/Mon) → Links auf auth.hevjin.app statt lrmoxfjuhqesjoxjkftw.supabase.co
      (Hauptverdacht für Spam-Einordnung: fremde Domain im Bestätigungslink)
- [ ] E-Mail-Templates: Plaintext-Variante + sichtbare URL als Text zusätzlich zum Button
- [ ] Domain-Reputation: braucht Zeit, nicht konfigurierbar

## 4. Google Play Store (in Reihenfolge)
- [ ] TEST-ACCOUNTS anlegen (BLOCKER fuer Review + noetig fuer Match-Test)
      Supabase Dashboard -> Authentication -> Users -> Add user -> "Auto Confirm User"
      (umgeht Resend/Spam komplett, kein Warten auf Bestaetigungsmail)
      - Account 1: Geschlecht female (sonst nicht im Discover sichtbar, Gender-Filter)
      - Profil komplett ausfuellen: Kaste, Stamm, Foto, Bio
      - Feste Mail + festes Passwort waehlen und BEHALTEN
      - Alternative bei normaler Registrierung: Gmail-Alias dalshkas+test1@gmail.com
- [ ] Play Console -> App-Zugriff -> Testzugangsdaten eintragen
      OHNE das wird die App im Review ABGELEHNT (Pruefer kommen nicht hinter den Login)
- [ ] SMS-Verifikation: +49 1525 1322992 in Play Console bestätigen (PFLICHT vor Publish)
- [ ] Identitätsverifizierung: Ausweis hochladen (1-3 Tage Wartezeit)
- [ ] Data-Safety-Formular: Supabase, Resend, Google, GitHub als Subprozessoren;
      US-Datentransfer; DSGVO Art. 9 besondere Kategorien (Kaste/Stamm) — sorgfältig dokumentieren
- [ ] Store-Listing: Screenshots + Beschreibung
- [ ] Neue AAB bauen MIT Match-Screen (die in Drive ist älter, ohne Match-Screen)
      → nur zu Hause / Lenovo, Android Studio auf Arbeitslaptop gesperrt
      → vorher `flutter analyze lib` (web-only Imports brechen Android-Build)

## 5. Offene Bugs / Verbesserungen
- [ ] display_name zeigt manchmal E-Mail-Prefix
- [ ] Chat-Liste flackert bei neuer Nachricht
- [x] Match-Screen Eingabefeld-Kontrast — ERLEDIGT 09.08. (opak weiß + Text #1A1A1A, Hint #8A8A8A)
- [ ] Aufräumen (optional): unused imports (main.dart google_fonts, register_screen, welcome_screen,
      chat_screen dart:typed_data), withOpacity → withValues, ungenutzte Methoden

## Wichtige Notizen
- Umlaute in Dart/ARB immer als \uXXXX schreiben — PowerShell zerstört UTF-8
- Backup home_screen.dart liegt unter %TEMP%\home_screen.dart.backup
- flutter analyze lib läuft fehlerfrei (273 Meldungen, alle nur warnings/infos)
