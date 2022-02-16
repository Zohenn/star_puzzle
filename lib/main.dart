import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_puzzle/bootstrap.dart';
import 'package:star_puzzle/widgets/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ThemeProvider(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: Theme.of(context),
      home: const Bootstrap(),
    );
  }
}