import 'package:flutter/material.dart';
import 'screens/now_playing_screen.dart';

void main() {
  runApp(const SpotifyActivityApp());
}

class SpotifyActivityApp extends StatelessWidget {
  const SpotifyActivityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Now Playing Activity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const NowPlayingScreen(),
    );
  }
}
