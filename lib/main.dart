import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const GitaApp());
}

class GitaApp extends StatefulWidget {
  const GitaApp({super.key});
  @override
  State<GitaApp> createState() => _GitaAppState();
}

class _GitaAppState extends State<GitaApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? ThemeData.dark() : ThemeData(primarySwatch: Colors.orange),
      home: MainScreen(
        isDark: _isDarkMode,
        onThemeToggle: () => setState(() => _isDarkMode = !_isDarkMode),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onThemeToggle;
  const MainScreen({super.key, required this.isDark, required this.onThemeToggle});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabIndex == 0 
          ? GitaList(onThemeToggle: widget.onThemeToggle, isDark: widget.isDark) 
          : const JapaTracker(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (index) => setState(() => _tabIndex = index),
        selectedItemColor: Colors.orange[900],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Gita"),
          BottomNavigationBarItem(icon: Icon(Icons.vibration), label: "Naam Jap"),
        ],
      ),
    );
  }
}

class GitaList extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final bool isDark;
  GitaList({super.key, required this.onThemeToggle, required this.isDark});

  final List<Map<String, dynamic>> chapters = [
    {
      "t": "1. Arjun Vishad Yog",
      "sh": "धृतराष्ट्र उवाच |\nधर्मक्षेत्रे कुरुक्षेत्रे समवेता युयुत्सवः |\nमामकाः पाण्डवाश्चैव किमकुर्वत सञ्जय ||१||",
      "m": "Dharam-bhumi Kurukshetra mein yuddh ki iccha se ekatra hue mere aur Pandu ke putro ne kya kiya?"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250, pinned: true, backgroundColor: Colors.orange[900],
          actions: [
            IconButton(icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode), onPressed: onThemeToggle),
            IconButton(
              icon: const Icon(Icons.camera_alt), 
              onPressed: () => launchUrl(Uri.parse("https://www.instagram.com/bhajanmarg_official")),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: const Text("Bhajan Marg", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            background: Image.network("https://www.bhaktiphotos.com/wp-content/uploads/2023/04/Premanand-Ji-Maharaj-Photo-Download.jpg", fit: BoxFit.cover),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(15),
            color: Colors.orange[50],
            child: const Text("आज का विचार: 'भजन बिना चैन नहीं।' - भजन मार्ग", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((c, i) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.orange, child: Text("${i+1}", style: const TextStyle(color: Colors.white))),
              title: Text(chapters[0]["t"], style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                HapticFeedback.mediumImpact();
                showModalBottomSheet(context: c, builder: (c) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(chapters[0]["sh"], textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Divider(),
                      Text("अर्थ: ${chapters[0]["m"]}", textAlign: TextAlign.center),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text("WhatsApp पर शेयर करें"),
                        onPressed: () => Share.share("${chapters[0]["sh"]}\n\nArth: ${chapters[0]["m"]}\n- Bhajan Marg App"),
                      )
                    ],
                  ),
                ));
              },
            ),
          ), childCount: 18),
        )
      ],
    );
  }
}

class JapaTracker extends StatefulWidget {
  const JapaTracker({super.key});
  @override
  State<JapaTracker> createState() => _JapaTrackerState();
}

class _JapaTrackerState extends State<JapaTracker> {
  int _count = 0;
  List<String> _history = [];
  String _lastDate = "";

  @override
  void initState() {
    super.initState();
    _loadAndCheckDate();
  }

  _loadAndCheckDate() async {
    final p = await SharedPreferences.getInstance();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    setState(() {
      _count = p.getInt('c') ?? 0;
      _history = p.getStringList('h') ?? [];
      _lastDate = p.getString('ld') ?? today;
    });

    if (_lastDate != today) {
      if (_count > 0) {
        _history.insert(0, "$_lastDate: $_count Jap (Auto-Saved)");
        _count = 0;
        await p.setInt('c', 0);
        await p.setStringList('h', _history);
      }
      await p.setString('ld', today);
      setState(() => _lastDate = today);
    }
  }

  void _increment() async {
    HapticFeedback.lightImpact();
    setState(() => _count++);
    final p = await SharedPreferences.getInstance();
    p.setInt('c', _count);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("नाम जप सेवा"), backgroundColor: Colors.orange[900], centerTitle: true),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("$_count", style: const TextStyle(fontSize: 90, fontWeight: FontWeight.bold, color: Colors.orange)),
                  const Text("आज का कुल जप", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: _increment,
                    child: Container(
                      height: 160, width: 160,
                      decoration: BoxDecoration(
                        color: Colors.orange[800], 
                        shape: BoxShape.circle,
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)]
                      ),
                      child: const Center(child: Text("जप करें", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(thickness: 2),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text("साधना इतिहास", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(
            flex: 4,
            child: _history.isEmpty 
              ? const Center(child: Text("अभी कोई इतिहास नहीं है"))
              : ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (c, i) => Card(
                    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: ListTile(
                      leading: const Icon(Icons.history, color: Colors.orange),
                      title: Text(_history[i].replaceAll("(Auto-Saved)", "(स्वयं सेवित)")),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
