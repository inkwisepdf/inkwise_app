pluginManagement {
    repositories {
        google()
        gradlePluginPortal()
        mavenCentral()
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

// Flutter plugin configuration
apply(from = "${settingsDir.parentFile}/packages/flutter_tools/gradle/app_plugin_loader.gradle")
