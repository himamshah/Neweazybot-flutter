# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Keep Flutter classes and methods
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.embedding.engine.** { *; }

# Keep HTTP and network classes
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }
-keep class com.squareup.okhttp.** { *; }

# Keep JSON parsing classes
-keep class com.google.gson.** { *; }
-keep class org.json.** { *; }
-keep class dart.** { *; }

# Keep model classes
-keep class com.example.easybot_complete.models.** { *; }

# Keep SharedPreferences
-keep class android.content.SharedPreferences.** { *; }

# Prevent obfuscation of methods that are called via reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes *Methods*
-keepattributes *Fields*

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Google Play Core library classes for Flutter
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
