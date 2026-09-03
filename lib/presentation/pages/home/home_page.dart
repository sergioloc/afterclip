import 'package:flutter/material.dart';
import '../camera/camera_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CameraPage()),
        );
      },
      child: const Scaffold(
        backgroundColor: Colors.black,
      ),
    );
  }
}