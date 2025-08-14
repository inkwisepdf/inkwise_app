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
        google()
        gradlePluginPortal()
        mavenCentral()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.2.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "inkwisepdf"
include(":app")