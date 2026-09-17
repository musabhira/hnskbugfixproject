# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Serialization, Reflection & JNI Native Methods
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepclasseswithmembernames class * {
    native <methods>;
}

# Flutter Pigeon Channels (Shared Preferences, Firebase, etc.)
-dontwarn dev.flutter.pigeon.**
-keep class dev.flutter.pigeon.** { *; }
-keep class * implements io.flutter.plugin.common.StandardMessageCodec { *; }
-keep class * extends io.flutter.plugin.common.StandardMessageCodec { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Dart JNI & Path Provider
-dontwarn com.github.dart_lang.jni.**
-keep class com.github.dart_lang.jni.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }

# WebRTC (Audio & Video Calls)
-dontwarn org.webrtc.**
-keep class org.webrtc.** { *; }
-keep class com.cloudwebrtc.webrtc.** { *; }
-keep interface org.webrtc.** { *; }

# Audio plugins (just_audio, audio_session, audioplayers, record)
-dontwarn com.ryanheise.**
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.ryanheise.audiosession.** { *; }
-keep class xyz.luan.audioplayers.** { *; }
-keep class com.record.** { *; }
-keep class com.llfbandit.record.** { *; }

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

# FFmpeg Kit
-dontwarn com.arthenica.ffmpegkit.**
-keep class com.arthenica.ffmpegkit.** { *; }

# Video Compress & Media Plugins
-dontwarn com.yellow.video_compress.**
-keep class com.yellow.video_compress.** { *; }
-dontwarn com.flarn2006.gal.**
-keep class com.flarn2006.gal.** { *; }

# Shorebird Code Push
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Hive
-dontwarn io.github.knights.**
-keep class io.github.knights.** { *; }

