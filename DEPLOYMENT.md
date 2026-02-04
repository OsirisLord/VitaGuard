# Deployment & Release Guide 🚀

This guide explains how to use the implemented CI/CD tools to deploy VitaGuard.

## 1. Automated CI/CD (GitHub Actions)
A workflow file is located at `.github/workflows/main.yml`.
- **Triggers**: On push to `main` or Pull Requests.
- **Actions**:
    1.  Setup Java & Flutter.
    2.  Lint & Analyze code.
    3.  Run Unit & Widget tests.
    4.  Build debug APK.

**Setup**:
1.  Push your code to GitHub.
2.  Go to the "Actions" tab to see the pipeline running.
3.  To build Release APKs, you must add your Keystore as a GitHub Secret and update the yaml file to use signing config.

## 2. Fastlane (Store Deployment)
Fastlane is set up for both Android and iOS to automate screenshots, beta deployment, and production releases.

### Android Setup (`android/fastlane`)
1.  **Google Play Key**: Get a Service Account JSON key from Google Play Console.
2.  Save it as `android/fastlane/fastlane-json-key.json` (DO NOT commit this file).
3.  **Run**:
    - `cd android`
    - `fastlane beta` (Deploy to internal track)
    - `fastlane deploy` (Deploy to production)

### iOS Setup (`ios/fastlane`)
1.  **App Store Connect**: Ensure your Apple ID has access.
2.  **Run**:
    - `cd ios`
    - `fastlane beta` (Upload to TestFlight)
    - `fastlane release` (Upload to App Store)

## 3. Manual Release Build
To build manually on your local machine:

**Android**:
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**iOS** (Requires Mac):
```bash
flutter build ipa --release
# Output: build/ios/ipa/VitaGuard.ipa
```

## 4. Environment Variables
Ensure you have a `.env` file or environment variables set for:
- `FIREBASE_API_KEY`
- `TFLITE_MODEL_PATH` (if dynamic)
