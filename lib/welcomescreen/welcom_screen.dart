import 'package:flutter/material.dart';
import 'package:media_player/app_route.dart';
import 'package:media_player/welcomescreen/welcome_screen_widget.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(
        context,
        AppRoute.playerScreen.name,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const WelcomeScreenWidget();
  }
}