# Flutter Deferred Components: R8 sucht Play-Core-Klassen,
# die Hevjin nicht nutzt. Warnungen unterdruecken statt Build abbrechen.
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Flutter Engine schuetzen
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Supabase / OkHttp / Gson
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn org.conscrypt.**

# Kotlin Coroutines
-dontwarn kotlinx.coroutines.**
