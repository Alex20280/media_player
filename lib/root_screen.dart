import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:media_player/media_player_app.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaPlayerApp();
  }
}