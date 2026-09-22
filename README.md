# Fixly

Fixly is a local services marketplace app connecting users with service professionals.

## Features
- User Authentication (Email/Password, Google Sign-In)
- Browse and search local service providers
- Real-time chat and notifications
- Secure payments integration
- Provider ratings and reviews
- Location-based service discovery

## Architecture Overview
Fixly is built using modern Flutter architecture principles and robust backend services:
- **State Management:** Riverpod for predictable and scalable state management.
- **Routing:** GoRouter for declarative routing.
- **Backend (Firebase):**
  - **Firebase Auth:** Secure user authentication.
  - **Firestore:** Real-time NoSQL database for user data, services, and chat.
  - **FCM (Firebase Cloud Messaging):** Push notifications for booking updates and chat.
- **Payments:** Razorpay integration for secure payment processing.

## Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   cd fixly
   ```

2. **Install dependencies:**
   Run the following command to fetch all required packages:
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration:**
   - Create a project on the Firebase Console.
   - Configure Android and iOS apps using the FlutterFire CLI:
     ```bash
     flutterfire configure
     ```
   - Make sure to enable Firebase Auth, Firestore, and Storage (if needed).

4. **Run the App:**
   ```bash
   flutter run
   ```

## Generating a Release Build (.aab)

To publish Fixly to the Google Play Store, you need to generate an Android App Bundle (.aab).

### 1. Create a Keystore
Run the following `keytool` command in your terminal to create a new keystore file (replace `my-release-key.jks` and `my-key-alias` as needed):

```bash
keytool -genkey -v -keystore ~/my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
```

### 2. Configure `keystore.properties`
Create a file named `keystore.properties` in your `android/` directory with the following content:

```properties
storePassword=<your_store_password>
keyPassword=<your_key_password>
keyAlias=my-key-alias
storeFile=<path_to_keystore_file>/my-release-key.jks
```
*Note: Do not commit `keystore.properties` to version control.*

### 3. Update `android/app/build.gradle`
Configure the `build.gradle` file in the `android/app` directory to use the keystore for the release build:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('keystore.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ...
    signingConfigs {
        release {
            keyAlias = keystoreProperties['keyAlias']
            keyPassword = keystoreProperties['keyPassword']
            storeFile = keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword = keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            // ...
        }
    }
}
```

### 4. Build the App Bundle
Run the following command to generate the release build:

```bash
flutter build appbundle
```

The output will be located at `build/app/outputs/bundle/release/app-release.aab`.
