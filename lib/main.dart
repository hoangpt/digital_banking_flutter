import 'package:flutter/material.dart';
import 'core/env.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!AppEnv.isMock) {
    // TODO: Initialize Firebase
    // await Firebase.initializeApp();
    // import 'firebase_options.dart';
  }
  runApp(const DigitalBankingApp());
}
