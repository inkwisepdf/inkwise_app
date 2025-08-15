plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.inkwise_pdf"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.example.inkwise_pdf"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        getByName("release") {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Flutter dependencies are handled by the Flutter plugin
    // Rely on Flutter Gradle plugin to inject embedding artifacts
    // (removed explicit embedding dependencies to avoid hash/version mismatches)
    
    // Alternative OCR implementation using Google ML Kit (already in dependencies)
    // This will provide OCR functionality without the problematic tesseract dependency
}

