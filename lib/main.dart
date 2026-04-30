import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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
      title: 'भजन मार्ग',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.orange,
        brightness: Brightness.light,
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
  // महाराज जी के अनमोल विचार
  final List<String> quotes = [
    "राधा नाम की महिमा अपरंपार है, बस जपते रहिये।",
    "संसार की सेवा करो, पर मन ठाकुर जी में लगाओ।",
    "क्रोध और अहंकार भक्ति के सबसे बड़े शत्रु हैं।",
    "प्रेम ही परमात्मा है, निस्वार्थ प्रेम ही सच्ची भक्ति है।",
    "प्रभु का नाम ही इस भवसागर से पार लगाने वाली नौका है।"
  ];

  // भजनों की सूची
  final List<Map<String, String>> bhajans = [
    {"title": "राधे राधे", "subtitle": "श्री प्रेमानंद जी महाराज"},
    {"title": "किशोरी कृपा", "subtitle": "वृंदावन महिमा"},
    {"title": "नाम संकीर्तन", "subtitle": "परम शांति"},
    {"title": "गुरु वंदना", "subtitle": "पावन पथ"},
  ];

  // वॉलपेपर सेट करने का फंक्शन
  Future<void> setWallpaper(String assetPath) async {
    try {
      await WallpaperManagerFlutter.setWallpaperFromAsset(
        assetPath, 
        WallpaperManagerFlutter.WallpaperHome
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🚩 जय श्री राधा! वॉलपेपर सेट हो गया।"),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("क्षमा करें, एरर आया: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("भजन मार्ग - श्री प्रेमानंद जी", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: CustomScrollView(
        slivers: [
          // टॉप बैनर
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const CircleAvatar(radius: 50, backgroundColor: Colors.orange, child: Icon(Icons.person, size: 60, color: Colors.white)),
                  const SizedBox(height: 15),
                  Text(quotes[0], textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),

          // वॉलपेपर बटन
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton.icon(
                onPressed: () => setWallpaper("assets/wallpaper.jpg"),
                icon: const Icon(Icons.wallpaper),
                label: const Text("महाराज जी का वॉलपेपर सेट करें", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ),

          // भजनों की लिस्ट
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text("पावन भजन", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.orangeAccent, child: Icon(Icons.music_note, color: Colors.white)),
                  title: Text(bhajans[index]['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(bhajans[index]['subtitle']!),
                  trailing: const Icon(Icons.play_arrow, color: Colors.orange),
                  onPressed: () { /* यहाँ ऑडियो प्लेयर लगा सकते हैं */ },
                ),
              ),
              childCount: bhajans.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Share.share("भजन मार्ग ऐप डाउनलोड करें और महाराज जी के सत्संग का लाभ उठाएं!"),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.share, color: Colors.white),
      ),
    );
  }
}
