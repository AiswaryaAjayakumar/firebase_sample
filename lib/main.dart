// ignore_for_file: prefer_const_constructors
import 'package:drawer_sample1/view/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyAfI2WelVw9hrJ8-Hqn7y8EOQLh34gqX4I",
          appId: "1:706390932467:android:153173bb0e9ed86bf33086",
          messagingSenderId: "",
          projectId: "sampleprjct-9c728",
          storageBucket: "sampleprjct-9c728.appspot.com"));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SplashScreen(
              isLogin: true,
            );
          } else {
            return SplashScreen();
          }
        },
      ),
    );
  }
}
