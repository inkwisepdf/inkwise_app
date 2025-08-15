// Top-level build file where you can add configuration options common to all sub-projects/modules.
buildscript {
    repositories {
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
        maven { url = uri("https://jitpack.io") }
        maven { url = uri("https://dl.bintray.com/rmtheis/maven") }
        google()
        mavenCentral()
    }
    
    dependencies {
        // Firebase dependencies removed - using local analytics instead
    }
}

allprojects {
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
