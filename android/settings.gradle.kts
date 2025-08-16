pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
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

// Read Flutter SDK path from local.properties
val localPropertiesFile = file("local.properties")
val properties = java.util.Properties()

if (localPropertiesFile.exists()) {
    localPropertiesFile.reader().use { reader ->
        properties.load(reader)
    }
}

val flutterSdkPath = properties.getProperty("flutter.sdk")
    ?: throw GradleException("flutter.sdk not set in local.properties")

// Instead of using apply(), use the settings plugin approach
plugins {
    id("dev.flutter.flutter-plugin-loader").version("1.0.0")
}

// Optionally set the Flutter SDK path property (if needed by plugin)
gradle.rootProject {
    extensions.extraProperties["flutter.sdk"] = flutterSdkPath
}