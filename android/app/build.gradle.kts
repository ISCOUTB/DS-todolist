plugins {
    id("com.android.application")
<<<<<<< HEAD
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
=======
    id("com.google.gms.google-services") // FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter Gradle Plugin
>>>>>>> origin/Jesus
}

android {
    namespace = "com.example.to_do_list"
    compileSdk = flutter.compileSdkVersion
<<<<<<< HEAD
    ndkVersion = flutter.ndkVersion
=======
    ndkVersion = "29.0.13113456"
>>>>>>> origin/Jesus

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
<<<<<<< HEAD
=======
        isCoreLibraryDesugaringEnabled = true // Habilitar desugaring
>>>>>>> origin/Jesus
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
<<<<<<< HEAD
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.to_do_list"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
=======
        applicationId = "com.example.to_do_list"
        minSdk = 33
>>>>>>> origin/Jesus
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
<<<<<<< HEAD
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
=======
>>>>>>> origin/Jesus
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

<<<<<<< HEAD
flutter {
    source = "../.."
}
=======
dependencies {
    // Agregar la dependencia para core library desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}
flutter {
    source = "../.."
}
>>>>>>> origin/Jesus
