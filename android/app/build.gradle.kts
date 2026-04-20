plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

dependencies {
    implementation("com.google.android.play:core:1.10.3")
}

android {
    namespace = "com.example.easybot_complete"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.easybot_complete"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file("../keystore/tradebot-release.jks")
            storePassword = "tradebot123"
            keyAlias = "tradebot"
            keyPassword = "tradebot123"
        }
        getByName("debug") {
            // Use the same keystore for debug to ensure consistency
            storeFile = file("../keystore/tradebot-release.jks")
            storePassword = "tradebot123"
            keyAlias = "tradebot"
            keyPassword = "tradebot123"
        }
    }

    buildTypes {
        release {
            // Configure release build with proper signing
            signingConfig = signingConfigs.getByName("release")
            
            // Enable code shrinking to allow resource shrinking
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Set custom APK name
            setProperty("archivesBaseName", "TradeBot")
        }
    }
}

flutter {
    source = "../.."
}
