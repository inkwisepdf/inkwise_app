# Flutter and Dart
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase (removed - using local analytics)
# -keep class com.google.firebase.** { *; }
# -dontwarn com.google.firebase.**
# -keep class com.google.android.gms.** { *; }
# -dontwarn com.google.android.gms.**

# Tesseract OCR support
-keep class com.googlecode.tesseract.** { *; }
-dontwarn com.googlecode.tesseract.**

# PDF processing (optional for packages like pdfbox/itext)
-keep class org.apache.pdfbox.** { *; }
-dontwarn org.apache.pdfbox.**
-keep class com.itextpdf.** { *; }

# JNI & native method support
-keepclasseswithmembers class * {
    native <methods>;
}

# General reflection support
-keepattributes *Annotation*
-keepattributes InnerClasses

# Useful for Crashlytics
-keepattributes SourceFile,LineNumberTable

