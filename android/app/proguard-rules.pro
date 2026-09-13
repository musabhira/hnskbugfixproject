# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Serialization & Reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# WebRTC
-dontwarn org.webrtc.**
-keep class org.webrtc.** { *; }

# Audio plugins (just_audio, audioplayers, record)
-dontwarn com.ryanheise.**
-keep class com.ryanheise.just_audio.** { *; }

# Camera
-keep class com.apparence.camerawesome.** { *; }

# In-App Purchase
-keep class com.android.billingclient.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# Suppress warnings
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
-dontwarn org.bouncycastle.**
-keep class org.xmlpull.v1.** { *; }

# Play Core (Deferred Components)
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Kotlin Coroutines & Ktor
-dontwarn kotlinx.coroutines.**
-dontwarn io.ktor.**

# Flutter Local Notifications
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# Desugaring
-keep class j$.** { *; }

# Supabase & Networking
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }

# AndroidX & Multidex
-keep class androidx.multidex.** { *; }
