import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'presentation/pages/home/home_page.dart';
import 'util/app_colors.dart';
import 'util/app_flavor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await AppFlavorConfig.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppFlavorConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(),
        useMaterial3: true,
        actionIconTheme: const ActionIconThemeData(
          backButtonIconBuilder: _buildBackButtonIcon,
        ),
      ),
      home: const HomePage(),
    );
  }
}

Widget _buildBackButtonIcon(BuildContext context) {
  return const Icon(Icons.arrow_back_ios_new, color: AppColors.onBackground);
}
