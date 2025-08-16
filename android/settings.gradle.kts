pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        // Add the Flutter repository - this is essential
        val flutterRoot = System.getenv("FLUTTER_ROOT") ?: file("local.properties")
            .takeIf { it.exists() }
            ?.let { props -> 
                java.util.Properties().apply { load(java.io.FileInputStream(props)) }
                    .getProperty("flutter.sdk") 
            }
        
        if (flutterRoot != null) {
            maven {
                url = uri("$flutterRoot/packages/flutter_tools/gradle/")
            }
        }
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
    }
}

// Read Flutter SDK path
val localPropertiesFile = file("local.properties")
val properties = java.util.Properties()
if (localPropertiesFile.exists()) {
    localPropertiesFile.reader().use { reader ->
        properties.load(reader)
    }
}

val flutterSdkPath = properties.getProperty("flutter.sdk")
    ?: System.getenv("FLUTTER_ROOT")
    ?: throw GradleException("Flutter SDK not found. Define location with flutter.sdk in local.properties or FLUTTER_ROOT environment variable.")

// Define the Flutter SDK path as a Gradle property for use in build scripts
gradle.rootProject {
    ext["flutter.sdk"] = flutterSdkPath
}

// Use the new declarative syntax for the Flutter plugin
include(":app")

// Apply the Flutter plugin using the recommended approach for Kotlin DSL
gradle.beforeProject {
    it.apply {
        from("${flutterSdkPath}/packages/flutter_tools/gradle/app_plugin_loader.gradle")
    }
}