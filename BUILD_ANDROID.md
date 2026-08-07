# Hevjin - Android Build Anleitung

Alles was am Arbeitslaptop vorbereitet wurde ist fertig.
Zu Hause musst du nur noch diese Schritte machen.

---

## 0. Voraussetzungen pruefen

```powershell
flutter --version
git --version
flutter doctor
```

Wenn `flutter doctor` bei **Android toolchain** ein `[X]` zeigt:
Android Studio installieren -> https://developer.android.com/studio
Beim ersten Start die SDK-Komponenten mitinstallieren lassen.

Danach nochmal `flutter doctor` und einmal die Lizenzen bestaetigen:

```powershell
flutter doctor --android-licenses
```

---

## 1. Code holen (kein USB noetig)

```powershell
cd C:\Users\<DEINNAME>\Desktop
git clone -b main https://github.com/salonglds-salon/hevjin-app.git
cd hevjin-app
flutter pub get
```

---

## 2. Keystore erstellen (EINMALIG - sehr wichtig!)

> **WARNUNG**
> Diese Datei + Passwort sind fuer immer an die App gebunden.
> Verlust = du kannst die App im Play Store NIE mehr updaten.
> Sofort auf USB-Stick UND in die Cloud sichern.

```powershell
cd android
keytool -genkey -v -keystore hevjin-release.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias hevjin
```

Es werden Fragen gestellt. Beispielantworten:

| Frage | Antwort |
|---|---|
| Keystore-Passwort | *dein Passwort - NOTIEREN!* |
| Vor- und Nachname | Dalshad Kasim |
| Organisationseinheit | (leer, Enter) |
| Organisation | Hevjin |
| Ort | Dinklage |
| Bundesland | Niedersachsen |
| Laendercode | DE |
| Korrekt? | `ja` |

---

## 3. key.properties anlegen

Im Ordner `android/` eine Datei `key.properties` erstellen
(Vorlage liegt daneben: `key.properties.example`):

```properties
storePassword=DEIN_PASSWORT_AUS_SCHRITT_2
keyPassword=DEIN_PASSWORT_AUS_SCHRITT_2
keyAlias=hevjin
storeFile=../hevjin-release.jks
```

Diese Datei ist per `.gitignore` ausgeschlossen - landet also nie auf GitHub. Gut so.

---

## 4. Bauen

**Zum Testen auf dem eigenen Handy (APK):**

```powershell
cd C:\Users\<DEINNAME>\Desktop\hevjin-app
flutter build apk --release
```

Ergebnis: `build\app\outputs\flutter-apk\app-release.apk`
-> per USB/WhatsApp aufs Handy, installieren, testen.

**Fuer den Play Store (AAB - das brauchst du zum Upload):**

```powershell
flutter build appbundle --release
```

Ergebnis: `build\app\outputs\bundle\release\app-release.aab`

Erster Build dauert 10-20 Min, danach 2-5 Min.

---

## 5. Pruefen ob richtig signiert

```powershell
cd build\app\outputs\bundle\release
jarsigner -verify -verbose app-release.aab
```

Muss `jar verified` sagen. Wenn dort "CN=Android Debug" auftaucht,
wurde `key.properties` nicht gefunden -> Schritt 3 pruefen.

---

## 6. Version erhoehen bei jedem Store-Update

In `pubspec.yaml` Zeile 3:

```yaml
version: 1.0.0+1
```

- `1.0.0` = versionName (was der Nutzer sieht)
- `+1` = versionCode (**muss** bei jedem Upload hochgezaehlt werden)

Naechstes Update also z.B. `version: 1.0.1+2`

---

## Was bereits fertig konfiguriert ist

| Punkt | Wert |
|---|---|
| Package-Name (unveraenderbar!) | `app.hevjin` |
| App-Name auf dem Homescreen | Hevjin |
| minSdk | 23 (Android 6.0+) |
| Release-Signierung | liest `android/key.properties` |
| Code-Verkleinerung | aktiv (ProGuard-Regeln vorhanden) |
| App-Icons | generiert aus `assets/images/logo.png` |
| Internet-Berechtigung | gesetzt |
| Deep-Link fuer Login | `app.hevjin://login-callback` |

---

## Bekanntes Thema: Google-Login auf Android

Der Web-Login nutzt `redirectTo: 'https://hevjin.app'`.
Auf Android braucht Supabase zusaetzlich die Redirect-URL

```
app.hevjin://login-callback
```

Die muss in Supabase eingetragen werden:
**Authentication -> URL Configuration -> Redirect URLs -> hinzufuegen**

Der Intent-Filter in der App ist schon vorbereitet.
E-Mail-Login funktioniert ohne diesen Schritt.

---

## Troubleshooting

| Problem | Loesung |
|---|---|
| `Unable to locate Android SDK` | Android Studio installieren, dann `flutter doctor` |
| `Keystore was tampered with` | Falsches Passwort in `key.properties` |
| `SDK location not found` | In Android Studio einmal ein Projekt oeffnen |
| Build haengt bei "Running Gradle task" | Erster Build laedt Gradle - Geduld (bis 20 Min) |
| `Execution failed for task ':app:minifyReleaseWithR8'` | ProGuard-Problem: in `android/app/build.gradle.kts` `isMinifyEnabled = false` setzen und neu bauen |
