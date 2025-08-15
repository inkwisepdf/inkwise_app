pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        val localPropertiesFile = file("../local.properties")
        
        if (localPropertiesFile.exists()) {
            localPropertiesFile.inputStream().use { properties.load(it) }
        }
        
        val flutterSdkPath = properties.getProperty("flutter.sdk")
            ?: System.getenv("FLUTTER_ROOT")
            ?: "C:\\flutter" // Default Flutter installation path on Windows
            
        if (flutterSdkPath.isNotEmpty()) {
            flutterSdkPath
        } else {
            throw GradleException("""
                Flutter SDK not found. Define flutter.sdk in the local.properties file.
                For example: flutter.sdk=C:\\flutter
                Or set the FLUTTER_ROOT environment variable.
            """.trimIndent())
        }
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
        maven { url = uri("https://jitpack.io") }
        maven { url = uri("https://maven.google.com") }
        maven { url = uri("https://repo1.maven.org/maven2") }
        maven { url = uri("https://dl.bintray.com/rmtheis/maven") }
        google()
        gradlePluginPortal()
        mavenCentral()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.2.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.23" apply false
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
        maven { url = uri("https://jitpack.io") }
        maven { url = uri("https://maven.google.com") }
        maven { url = uri("https://repo1.maven.org/maven2") }
        maven { url = uri("https://plugins.gradle.org/m2") }
        maven { url = uri("https://dl.bintray.com/rmtheis/maven") }
        google()
        mavenCentral()
    }
}

rootProject.name = "inkwisepdf"
include(":app")
