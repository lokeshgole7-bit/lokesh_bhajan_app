import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Naya aur compatible package (v1.0.1)
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
  
  // Naya Set Wallpaper Function (v1.0.1 ke liye)
  Future<void> setWallpaper(String imageUrl) async {
    try {
      // Naye version 1.0.1 mein 'WallpaperHome' constant use hota hai
      await WallpaperManagerFlutter.setWallpaperFromAsset(
        imageUrl, 
        WallpaperManagerFlutter.WallpaperHome
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("जय श्री राधा रानी! वॉलपेपर सेट हो गया।"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("क्षमा करें, एरर आया: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("श्री प्रेमानंद जी महाराज भजन मार्ग"),
        centerTitle: true,
        backgroundColor: Colors.orange.shade100,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade50, Colors.white],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.brightness_7,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Text(
              "राधे राधे, लोकेश भाई!",
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "आपका भजन मार्ग ऐप तैयार है",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => setWallpaper("assets/wallpaper.jpg"), // Apni image path check karein
              icon: const Icon(Icons.wallpaper_rounded),
              label: const Text("वॉलपेपर सेट करें"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
