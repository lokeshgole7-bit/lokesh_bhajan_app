import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Naya aur compatible package
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

void main() {
  runApp(const LokeshBhajanApp());
}

class LokeshBhajanApp extends StatelessWidget {
  const LokeshBhajanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bhajan Marg',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.orange,
      ),
      home: const BhajanHomePage(),
    );
  }
}

class BhajanHomePage extends StatefulWidget {
  const BhajanHomePage({super.key});

  @override
  State<BhajanHomePage> createState() => _BhajanHomePageState();
}

class _BhajanHomePageState extends State<BhajanHomePage> {
  
  // Naya function jo purane setup ke saath mix hai
  Future<void> setWallpaper(String imageUrl) async {
    try {
      // Home screen par set karne ke liye
      int location = WallpaperManagerFlutter.HOME_SCREEN; 
      
      // Wallpaper set karne ka command
      await WallpaperManagerFlutter.setWallpaperFromAsset(imageUrl, location);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("जय श्री राधा रानी! वॉलपेपर सेट हो गया।")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("क्षमा करें, एरर आया: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("श्री प्रेमानंद जी महाराज भजन मार्ग"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "राधे राधे, लोकेश भाई!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => setWallpaper("assets/wallpaper.jpg"), // Apni image ka path sahi rakhein
              icon: const Icon(Icons.wallpaper),
              label: const Text("वॉलपेपर सेट करें"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
