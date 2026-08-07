# Hevjîn — Yezidi Dating App

Eine moderne Dating-App exklusiv für die êzîdische Community.

## 🎯 Features (MVP)
- ✅ SMS-Verifizierung (Anti-Fake)
- ✅ Profil mit Kaste (Scheich/Pir/Murid) & Stamm/Ashiret
- ✅ Suche: Heirat / Dating / Beides
- ✅ Swipe-System (Like/Dislike)
- ✅ Match-System (gegenseitiges Like)
- ✅ Chat nach Match
- ✅ Modernes Clean-Design

## 🛠 Tech Stack
- **Frontend:** Flutter (Dart) — iOS + Android aus einer Codebase
- **Backend:** Supabase (PostgreSQL, Auth, Realtime, Storage)
- **Design:** Material 3, Inter Font, Gold/Navy Farbschema

## 📱 Screens
1. **Splash** — Logo + Animation
2. **Login** — SMS OTP Verifizierung
3. **Profil erstellen** — 3-Step Wizard (Grunddaten → Êzîdische Identität → Bio)
4. **Home/Entdecken** — Swipe-Cards mit Profil-Info
5. **Matches** — Liste der Matches
6. **Profil** — Eigenes Profil anzeigen/bearbeiten

## 🚀 Setup

### 1. Flutter installieren
```bash
# https://docs.flutter.dev/get-started/install
flutter doctor
```

### 2. Supabase Projekt erstellen
1. Gehe zu https://supabase.com → Neues Projekt
2. Kopiere URL + Anon Key
3. Ersetze in `lib/main.dart`:
   - `YOUR_SUPABASE_URL`
   - `YOUR_SUPABASE_ANON_KEY`

### 3. Datenbank-Schema laden
- Gehe im Supabase Dashboard auf SQL Editor
- Füge `database_schema.sql` ein und führe es aus

### 4. Phone Auth aktivieren
- Supabase Dashboard → Authentication → Providers → Phone
- Twilio Account verknüpfen (für SMS-Versand)

### 5. App starten
```bash
cd hevjin-app
flutter pub get
flutter run
```

## 📂 Projektstruktur
```
lib/
├── main.dart                    # App Entry Point
├── models/
│   └── user_profile.dart        # User/Profile Datenmodell
├── screens/
│   ├── splash_screen.dart       # Splash/Loading
│   ├── auth/
│   │   └── login_screen.dart    # SMS Login
│   ├── profile/
│   │   └── create_profile_screen.dart  # Profil-Wizard
│   ├── home/
│   │   └── home_screen.dart     # Discover + Matches + Profil Tabs
│   └── chat/                    # (Next: Chat-Screen)
├── services/
│   ├── auth_service.dart        # Auth Logic (OTP)
│   └── profile_service.dart     # Profile + Discovery + Matching
├── utils/
│   └── theme.dart               # Design-System (Farben, Fonts)
└── widgets/                     # (Shared Widgets)
```

## 🎨 Design
- **Primary:** Deep Navy (#1A1A2E)
- **Accent:** Warm Gold (#E8B931)
- **Background:** Clean White-Grey (#F8F9FA)
- **Font:** Inter (Google Fonts)
- **Style:** Modern/Clean, minimalistisch, dezente kulturelle Akzente

## 📋 Roadmap
- [ ] Chat-System (Realtime Messages nach Match)
- [ ] Foto-Upload (mehrere Bilder)
- [ ] Filter (nach Kaste, Stadt, Alter)
- [ ] Push Notifications
- [ ] Profilverifizierung (ID-Check)
- [ ] Block/Report System
- [ ] Dark Mode
- [ ] Kurmanji Sprachsupport
