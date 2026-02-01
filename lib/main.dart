import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/audio_service.dart';
import 'services/track_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HummingMusicApp());
}

class HummingMusicApp extends StatelessWidget {
  const HummingMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioService()),
        ChangeNotifierProvider(create: (_) => TrackManager()),
      ],
      child: MaterialApp(
        title: 'Humming Music',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
