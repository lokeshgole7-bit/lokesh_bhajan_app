import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: CounterPage()));
}

class GitaPage extends StatelessWidget {
  const GitaPage({super.key});
  final List<String> chapters = const [
    "1. अर्जुनविषादयोग", "2. सांख्ययोग", "3. कर्मयोग", "4. ज्ञानकर्मसंन्यासयोग",
    "5. कर्मसंन्यासयोग", "6. आत्मसंयमयोग", "7. ज्ञानविज्ञानयोग", "8. अक्षरब्रह्मयोग",
    "9. राजविद्याराजगुह्ययोग", "10. विभूतियोग", "11. विश्वरूपदर्शनयोग", "12. भक्तियोग",
    "13. क्षेत्र-क्षेत्रज्ञविभागयोग", "14. गुणत्रयविभागयोग", "15. पुरुषोत्तमयोग",
    "16. दैवासुरसम्पद्विभागयोग", "17. श्रद्धात्रयविभागयोग", "18. मोक्षसंन्यासयोग"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("श्रीमद्भगवद्गीता"), backgroundColor: Colors.orange[900]),
      body: ListView.builder(
        itemCount: chapters.length,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.orange, child: Text("${index + 1}")),
            title: Text(chapters[index], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("अध्याय के श्लोक जल्द ही जुड़ेंगे"),
            onTap: () {},
          ),
        ),
      ),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});
  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _mainCounter = 0;
  int _bgIndex = 0;
  String _currentQuote = "राधे-राधे! अपनी साधना शुरू करें।";
  final List<Color> _bgColors = [const Color(0xFF2E004E), const Color(0xFF1B5E20), const Color(0xFFBF360C), Colors.black];
  final List<String> _quotes = [
    "नाम जप ही असली धन है, इसे व्यर्थ न जाने दें।",
    "श्री राधा नाम का आश्रय लो, सब मंगल होगा।",
    "भगवान के नाम में असीम शक्ति है, बस जपते रहो।",
    "मन को राधा नाम में लगाओ, शांति अपने आप आएगी।"
  ];

  @override
  void initState() { super.initState(); _loadCount(); _getRandomQuote(); }
  void _getRandomQuote() { setState(() { _currentQuote = _quotes[Random().nextInt(_quotes.length)]; }); }
  _loadCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() { _mainCounter = prefs.getInt('count') ?? 0; });
  }
  _incrementCount() async {
    HapticFeedback.vibrate();
    setState(() { _mainCounter++; });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('count', _mainCounter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColors[_bgIndex],
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        title: const Text("Lokesh Gole | साधना रत्न"),
        actions: [
          IconButton(icon: const Icon(Icons.color_lens), onPressed: () {
            setState(() { _bgIndex = (_bgIndex + 1) % _bgColors.length; });
          }),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
              child: InkWell(onTap: _getRandomQuote, child: Text(_currentQuote, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic))),
            ),
          ),
          const Spacer(),
          Center(
            child: Container(
              width: 250, height: 320,
              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(50), border: Border.all(color: Colors.orange, width: 2)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("कुल नाम जप", style: TextStyle(color: Colors.white70)),
                  Text(_mainCounter.toString().padLeft(6, '0'), style: const TextStyle(fontSize: 50, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                  const SizedBox(height: 30),
                  GestureDetector(onTap: _incrementCount, child: const CircleAvatar(radius: 60, backgroundColor: Colors.white, child: Icon(Icons.touch_app, size: 50, color: Colors.orange))),
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.black38,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(icon: const Icon(Icons.menu_book, color: Colors.white), onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const GitaPage())); }),
                IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () { Share.share("राधे-राधे! आज मैंने $_mainCounter नाम जप किए।"); }),
              ],
            ),
          ),
          const Text("Dev: Lokesh Gole | Indore", style: TextStyle(color: Colors.white24, fontSize: 10)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
