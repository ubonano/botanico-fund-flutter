import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart'; // For kDebugMode
import 'app.dart';
import 'core/config/locator.dart';
import 'core/config/secret/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Setup Firebase Emulators in Debug Mode
  // if (kDebugMode) {
  //   try {
  //     await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  //     FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  //     print('Connected to Firebase Emulators');
  //   } catch (e) {
  //     print('Error connecting to Firebase Emulators: $e');
  //   }
  // }

  setupLocator();
  runApp(const MyApp());
}
