import 'package:client/common/view/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

// private 변수 선언하는 class는 underbar 붙인다.
class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '카무의 배달',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'NotoSans',
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
