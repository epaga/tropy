# Build Instructions for Tropy App

This document provides instructions for building the Tropy app for iOS and Android platforms.

## Version Information

Current app version: **1.0.1+11**

## Prerequisites

- Flutter SDK (version 3.3.9 or compatible)
- Xcode (for iOS builds)
- Android Studio (for Android builds)
- Java Development Kit (JDK) 11 or higher

## Building for iOS

1. **Update Pods**:
   ```bash
   cd ios
   pod install
   cd ..
   ```

2. **Build the iOS app**:
   ```bash
   flutter build ios --release
   ```
   
   If you don't have a signing certificate, you can build without code signing:
   ```bash
   flutter build ios --release --no-codesign
   ```

3. **Open in Xcode for distribution**:
   ```bash
   open ios/Runner.xcworkspace
   ```
   
   In Xcode:
   - Select the appropriate team for signing
   - Build and archive the app for distribution
   - Use App Store Connect to distribute the app

## Building for Android

The Android build requires specific Java and Gradle configurations. Due to compatibility issues with newer Java versions, follow these steps:

1. **Ensure JDK 11 is installed and set as the default**:
   ```bash
   java -version
   ```
   
   If you need to install JDK 11:
   ```bash
   brew install openjdk@11
   ```

2. **Set JAVA_HOME environment variable**:
   ```bash
   export JAVA_HOME=$(/usr/libexec/java_home -v 11)
   ```

3. **Clean the project**:
   ```bash
   flutter clean
   flutter pub get
   ```

4. **Build the APK**:
   ```bash
   flutter build apk --release
   ```
   
   Alternatively, build an App Bundle for Google Play:
   ```bash
   flutter build appbundle --release
   ```

5. **Find the built APK**:
   The APK will be located at:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

## Troubleshooting

### iOS Build Issues

- If you encounter minimum deployment target issues, ensure the Podfile has:
  ```ruby
  platform :ios, '12.0'
  ```
  
- In the post_install hook, add:
  ```ruby
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      flutter_additional_ios_build_settings(target)
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
  end
  ```

### Android Build Issues

- If you encounter Gradle compatibility issues, try using a specific version of the Flutter SDK that's compatible with your project's Gradle configuration.

- You may need to update the Java version in `android/app/build.gradle`:
  ```gradle
  compileOptions {
      sourceCompatibility JavaVersion.VERSION_11
      targetCompatibility JavaVersion.VERSION_11
  }

  kotlinOptions {
      jvmTarget = '11'
  }
  ```

- Update the Gradle version in `android/gradle/wrapper/gradle-wrapper.properties`:
  ```
  distributionUrl=https\://services.gradle.org/distributions/gradle-7.6.3-all.zip
  ```

## Distribution

### iOS App Store

1. Create an app record in App Store Connect
2. Use Xcode to archive and upload the build
3. Complete the submission process in App Store Connect

### Google Play Store

1. Create an app in the Google Play Console
2. Upload the signed AAB (Android App Bundle)
3. Complete the store listing and release the app

## Notes

- The app uses SharedPreferences for data storage
- Make sure to test the app thoroughly before distribution
- Consider implementing a beta testing phase using TestFlight (iOS) or Google Play Beta Testing (Android) 