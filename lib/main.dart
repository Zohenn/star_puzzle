import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:star_puzzle/bootstrap.dart';
import 'package:star_puzzle/models/constellation_progress.dart';
import 'package:star_puzzle/widgets/theme_provider.dart';

void main() async {
  LicenseRegistry.addLicense(() async* {
    final licenses = [
      await rootBundle.loadString('google_fonts/JosefinSlab.txt'),
      await rootBundle.loadString('google_fonts/Poppins.txt'),
      await rootBundle.loadString('google_fonts/Raleway.txt'),
    ];
    for (var license in licenses) {
      yield LicenseEntryWithLineBreaks(['google_fonts'], license);
    }
  });

  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ConstellationProgressAdapter());

  runApp(const ThemeProvider(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Stazzle',
      theme: Theme.of(context),
      home: const Bootstrap(),
    );
  }
}
