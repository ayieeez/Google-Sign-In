# Google Sign-In

A new Flutter project for integrating Google Sign-In functionality.

## 2410-ICT602 Lab Work 9 - Google Sign In

### Accessing The Hardware

This project is a starting point for a Flutter application that focuses on accessing hardware features and integrating Google Sign-In functionality.

## Initialization Steps for Google Sign-In

### 1. Add Dependencies

To use Google Sign-In, add the following dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  firebase_auth: ^3.3.0
  google_sign_in: ^5.2.1
```

### 2. Configure Firebase Project

1. Go to the [Firebase Console].
2. Create a new project or select an existing one.
3. Click on "Add app" and choose Android.

### 3. Register Your App with Firebase

1. Enter your Android package name (found in `AndroidManifest.xml`).
2. Download the `google-services.json` file and place it in the `android/app` directory of your Flutter project.
3. In your `android/build.gradle` file, add the Google services classpath:

```gradle
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.3.10'
    }
}
```

4. In your `android/app/build.gradle` file, apply the Google services plugin at the bottom:

```gradle
apply plugin: 'com.google.gms.google-services'
```

### 4. Request Internet Permission

Request internet permissions in your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### 5. Initialize Firebase in Your Flutter App

In your `main.dart`, initialize Firebase:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

### 6. Implement Google Sign-In

Here’s how to implement Google Sign-In in your Dart code:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    if (googleAuth == null) return null;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
```

### 7. Create a Sign-In Button

You can create a simple button to trigger the Google Sign-In process:

```dart
ElevatedButton(
  onPressed: () async {
    User? user = await AuthService().signInWithGoogle();
    if (user != null) {
      print('User signed in: ${user.displayName}');
    }
  },
  child: Text('Sign in with Google'),
)
```

### Running the Application

- Ensure to run the application on an Android Virtual Device (AVD) or a physical smartphone.
- Test the Google Sign-In functionality by tapping the button you created.

### Conclusion

You have successfully integrated Google Sign-In into your Flutter application. If you encounter any issues or have further questions, feel free to ask!
