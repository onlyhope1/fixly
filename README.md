# LocalServe

A local services marketplace app (like Urban Company) built with Flutter, Firebase, and Riverpod.

## Features

- **Phone OTP Authentication** via Firebase Auth
- **Role-based users** — Customer or Service Provider
- **Cloud Firestore** for user data
- **Firebase Cloud Messaging** for push notifications
- **Clean Architecture** with feature-based folder structure
- **Riverpod** for state management
- **GoRouter** for declarative navigation

## Project Structure

```
lib/
├── main.dart                        # Entry point — Firebase init + ProviderScope
├── app.dart                         # MaterialApp.router with theme & GoRouter
├── firebase_options.dart            # Firebase config (placeholder)
├── core/
│   ├── services/firebase_service.dart  # FCM setup helper
│   ├── utils/constants.dart            # App constants & Firestore paths
│   ├── utils/validators.dart           # Input validators
│   └── widgets/loading_indicator.dart  # Reusable loading spinner
├── models/
│   └── app_user.dart                # AppUser model (uid, phone, role, createdAt)
├── features/
│   ├── auth/                        # Authentication feature
│   │   ├── data/auth_repository.dart
│   │   ├── providers/auth_providers.dart
│   │   └── screens/
│   │       ├── splash_screen.dart
│   │       ├── phone_entry_screen.dart
│   │       ├── otp_verification_screen.dart
│   │       └── role_selection_screen.dart
│   ├── home/screens/home_screen.dart
│   ├── booking/screens/bookings_screen.dart
│   ├── messages/screens/messages_screen.dart
│   └── profile/screens/profile_screen.dart
└── routing/
    ├── app_router.dart              # GoRouter route definitions
    └── customer_shell.dart          # Bottom nav scaffold (4 tabs)
```

## Prerequisites

- **Flutter SDK** ≥ 3.11 — [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Firebase CLI** — `npm install -g firebase-tools`
- **FlutterFire CLI** — `dart pub global activate flutterfire_cli`
- A **Firebase project** with Phone Authentication enabled

## Setup Instructions

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd localserve
```

### 2. Install Flutter dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

```bash
# Log in to Firebase
firebase login

# Generate firebase_options.dart with your project's config
flutterfire configure
```

This will overwrite the placeholder `lib/firebase_options.dart` with your real Firebase credentials.

### 4. Enable Phone Authentication

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project → **Authentication** → **Sign-in method**
3. Enable **Phone** provider
4. (Optional) Add test phone numbers for development

### 5. Set up Firestore

1. In Firebase Console → **Firestore Database** → **Create database**
2. Start in **test mode** (or set up security rules)
3. The app will create a `users` collection automatically

### 6. Run the app

```bash
flutter run
```

## Authentication Flow

1. **Splash Screen** — checks if user is already signed in
2. **Phone Entry** — user enters their phone number
3. **OTP Verification** — user enters the 6-digit SMS code
4. **Role Selection** — first-time users choose Customer or Provider
5. **Home** — bottom navigation with 4 tabs

## Firestore Data Model

### `users` collection

| Field         | Type      | Description                          |
|---------------|-----------|--------------------------------------|
| `phoneNumber` | `string`  | User's phone number (e.g. +91...)    |
| `role`        | `string`  | `"customer"` or `"provider"`         |
| `createdAt`   | `timestamp`| When the account was created        |

Document ID = Firebase Auth UID.

## License

This project is private and not published to pub.dev.
