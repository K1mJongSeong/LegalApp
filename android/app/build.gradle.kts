plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.dailyprogress.lawdecode"
    compileSdk = 34
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.dailyprogress.lawdecode"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Flutter가 기대하는 경로로 APK 복사
tasks.whenTaskAdded {
    if (name == "assembleDebug" || name == "assembleRelease" || name == "assembleProfile") {
        doLast {
            val buildType = name.removePrefix("assemble").lowercase()
            val sourceApk = file("${project.layout.buildDirectory.get()}/outputs/apk/$buildType/app-$buildType.apk")
            val targetDir = file("${project.rootDir}/../build/app/outputs/flutter-apk")
            
            if (sourceApk.exists()) {
                targetDir.mkdirs()
                sourceApk.copyTo(file("${targetDir}/app-$buildType.apk"), overwrite = true)
                println("✅ APK copied to: ${targetDir}/app-$buildType.apk")
            }
        }
    }
}
