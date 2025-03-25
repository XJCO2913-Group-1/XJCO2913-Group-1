plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.shared_ebike_fe"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
 
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.shared_ebike_fe"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 22
        targetSdk = 35
        compileSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndkVersion = "29.0.13113456"
        
        ndk {
            // 设置支持的SO库架构（开发者可以根据需要，选择一个或多个平台的so）
            abiFilters.add("armeabi-v7a")
            abiFilters.add("arm64-v8a")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.jar"))))
    // 3D地图so及jar,已经包含定位和搜索功能无需单独引用
    implementation("com.amap.api:3dmap-location-search:latest.integration")
}

flutter {
    source = "../.."
}
