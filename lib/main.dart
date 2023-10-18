import 'package:flutter/material.dart';
import 'package:g14/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Firebase を使う時に必要なコード 2
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // アプリを動かす
  const app = MyApp();
  const scope = ProviderScope(child: app);
  runApp(scope);

}

