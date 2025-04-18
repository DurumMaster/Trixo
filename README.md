# trixo_frontend

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 🔧 SDK Compatibility Note

This project uses `firebase_auth`, which requires a minimum Android SDK version of **23**.  
For that reason, the `minSdkVersion` has been explicitly set to 23 in the `android/app/build.gradle` file:

```gradle
defaultConfig {
  minSdk = 23 // Required by Firebase Auth
  ...
}