buildscript {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
    
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.22")
    }
}

// Global configuration for all subprojects including Flutter plugins
subprojects {
    // Force all Java compilation to use Java 17
    tasks.withType<JavaCompile> {
        sourceCompatibility = JavaVersion.VERSION_17.toString()
        targetCompatibility = JavaVersion.VERSION_17.toString()
    }
    
    // Force all Kotlin compilation to use Java 17
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
        kotlinOptions {
            jvmTarget = "17"
        }
    }
    
    // Configure Android projects specifically
    afterEvaluate {
        if (plugins.hasPlugin("com.android.library") || plugins.hasPlugin("com.android.application")) {
            extensions.findByType<com.android.build.gradle.BaseExtension>()?.let { android ->
                android.compileSdk = 36
                android.compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                    isCoreLibraryDesugaringEnabled = true
                }
                
                // Force multidex for all Android projects
                android.defaultConfig {
                    multiDexEnabled = true
                }
                
                // Add core library desugaring dependency to all Android projects
                project.dependencies {
                    "coreLibraryDesugaring"("com.android.tools:desugar_jdk_libs:2.0.4")
                    "implementation"("androidx.multidex:multidex:2.0.1")
                }
            }
        }
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}