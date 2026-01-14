import 'package:flutter/material.dart';
import 'package:media_player/playerscreen/player_screen.dart';
import 'package:media_player/welcomescreen/welcom_screen.dart';

import 'app_route.dart';

class MediaPlayerApp extends StatelessWidget {
  final GlobalKey<NavigatorState>? navigatorKey;

  const MediaPlayerApp({super.key, this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Player',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      navigatorKey: navigatorKey,
      routes: {
        AppRoute.welcomeScreen.name: (context) => WelcomeScreen(),
        AppRoute.playerScreen.name: (context) => PlayerScreen(),
      },
    );
  }
}