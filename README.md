# 🏥 VitaGuard - Smart Chest Disease Diagnosis & Monitoring

**VitaGuard** is a next-generation healthcare application designed to empower patients and doctors with AI-powered diagnostics and real-time vital sign monitoring for chest diseases (specifically Pneumonia).

![Flutter](https://img.shields.io/badge/Flutter-3.19-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Backend-Firebase-orange?logo=firebase)
![AI](https://img.shields.io/badge/AI-TensorFlow_Lite-orange?logo=tensorflow)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-green)

---

## ✨ Features

### 👤 For Patients
*   **AI Scan**: Upload or take photos of chest X-rays for instant Pneumonia analysis using on-device AI.
*   **Real-time Vitals**: Connect to ESP32-based IoT devices to monitor SpO2, Heart Rate, and Temperature in real-time.
*   **Emergency SOS**: One-tap alert to notify companions and doctors with your location and status.
*   **Chat**: Communicate directly with your assigned doctor.
*   **Reports**: Generate professional PDF reports of your diagnosis history.

### 👨‍⚕️ For Doctors
*   **Patient Dashboard**: Monitor multiple patients' vitals and alerts.
*   **Diagnosis Verification**: Review AI analysis results and add medical notes.
*   **Chat**: Secure messaging with patients.

### 👥 For Companions
*   **Remote Monitoring**: Keep track of loved ones' health status.
*   **Alerts**: Receive push notifications for critical health events (low SpO2, high temp, SOS).

---

## 🛠️ Technology Stack

*   **Frontend**: Flutter (Dart)
*   **State Management**: BLoC (Business Logic Component)
*   **Architecture**: Clean Architecture (Domain, Data, Presentation layers)
*   **Backend**: Firebase (Auth, Firestore, Storage, Cloud Messaging)
*   **AI/ML**: TensorFlow Lite (`tflite_flutter`) for on-device edge inference.
*   **IoT**: WebSockets (`web_socket_channel`) for ESP32 data streaming.
*   **Security**:
    *   `flutter_secure_storage` for token management.
    *   Biometric Authentication (`local_auth`).
    *   End-to-End Encryption for sensitive data.

---

## 🚀 Getting Started

### Prerequisites
*   [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
*   [Visual Studio Code](https://code.visualstudio.com/) or Android Studio.
*   A Firebase Project with `google-services.json` (Android) / `GoogleService-Info.plist` (iOS).

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/yourusername/vitaguard.git
    cd vitaguard
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Setup Firebase**
    *   Place `google-services.json` in `android/app/`.
    *   Place `GoogleService-Info.plist` in `ios/Runner/`.

4.  **Run the app**
    ```bash
    flutter run
    ```

---

## 📂 Project Structure

```
lib/
├── config/              # Routes, Themes
├── core/                # Shared utilities, Errors, Services (IoT, Report)
├── features/            # Feature-based modules
│   ├── auth/            # Authentication (Login, Register, BLoC)
│   ├── chat/            # Chat System
│   ├── patient/         # Patient Logic (Dashboard, Vitals, X-Ray)
│   ├── doctor/          # Doctor Logic
│   └── ...
├── injection_container.dart  # Dependency Injection Setup
└── main.dart            # Entry point
```

## 🧪 Testing

Run the full test suite:
```bash
flutter test
```
*   **Unit Tests**: Core logic, Repositories, BLoCs.
*   **Widget Tests**: UI components and Screens.
*   **Integration Tests**: App flow smoke tests.

## 📦 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ipa --release
```

See [DEPLOYMENT.md](DEPLOYMENT.md) for automated CI/CD and Fastlane instructions.

---

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.