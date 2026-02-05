import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
android {
    namespace = "com.reda.mohtm2"
    compileSdk = flutter.compileSdkVersion
    // ndkVersion = flutter.ndkVersion
  //  ndkVersion = "27.0.12077973"
    ndkVersion="29.0.14206865"		


    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works. debug
            signingConfig = signingConfigs.getByName("release") 
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    // Kotlin compiler options: set jvmTarget via task configuration to keep compatibility
    // (Some Kotlin Gradle Plugin versions don't expose the newer compilerOptions DSL here.)

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.reda.mohtm2"
        // You can update the following values to match your application needs.
    // For more information, see: https://flutter.dev/to/review
    // Use Flutter-provided minSdkVersion when available
    minSdk = flutter.minSdkVersion
    // fallback (if the above is not available for some reason) could be uncommented:
    // minSdk = 23

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // versionCode = 14
        // versionName = "1.1.3"
    }

   
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // ...existing dependencies...
}

// Ensure Kotlin compiler JVM target is set for all Kotlin compile tasks using the
// new compilerOptions DSL (required by newer Kotlin Gradle plugin versions)
tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile::class.java).configureEach {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}



