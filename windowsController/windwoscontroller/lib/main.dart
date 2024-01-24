import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windwoscontroller/Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  windowManager.waitUntilReadyToShow(const WindowOptions(), () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remote Control',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}
