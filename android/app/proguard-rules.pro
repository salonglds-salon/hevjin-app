# ===== Flutter =====
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ===== Supabase / Ktor / kotlinx.serialization =====
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.**
-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# ===== Networking (OkHttp / Ktor) =====
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn io.ktor.**

# ===== image_picker / file access =====
-keep class androidx.core.content.FileProvider { *; }

# ===== Keep annotations used for reflection =====
-keepattributes Signature
-keepattributes EnclosingMethod

# ===== Suppress warnings for missing optional classes =====
-dontwarn java.lang.invoke.**
-dontwarn **$$serializer
