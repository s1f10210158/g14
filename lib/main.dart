import 'package:flutter/material.dart';
import 'package:g14/servise/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:g14/screens/onboding/components/custom_sign_in.dart';
import 'package:g14/screens/onboding/onboding_screen.dart';



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ... その他の設定 ...
      home: OnboardingScreen(),
    );
  }
}


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

