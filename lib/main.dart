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
    // Baaki adhyay yaha judenge...
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250, pinned: true, backgroundColor: Colors.orange[900],
          actions: [
            IconButton(icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode), onPressed: onThemeToggle),
            // Updated Instagram Link button
            IconButton(
              icon: const Icon(Icons.camera_alt), 
              onPressed: () => launchUrl(Uri.parse("https://www.instagram.com/bhajanmarg_official")),
              tooltip: "Bhajan Marg Official",
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
            child: const Text("Aaj ka Vichar: 'Bhajan Bina Chain Nahi.' - Bhajan Marg", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
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
                      Text("Arth: ${chapters[0]["m"]}", textAlign: TextAlign.center),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text("WhatsApp par Share karein"),
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

  @override
  void initState() { super.initState(); _load(); }

  _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() { _count = p.getInt('c') ?? 0; _history = p.getStringList('h') ?? []; });
  }

  void _increment() async {
    HapticFeedback.lightImpact();
    setState(() {
      _count++;
      if (_count == 100 || _count == 500 || (_count > 0 && _count % 1000 == 0)) {
        _showMilestone(_count);
      }
    });
    final p = await SharedPreferences.getInstance(); p.setInt('c', _count);
  }

  void _showMilestone(int count) {
    String msg = "Radhe Radhe! Naam japte rahein.";
    if (count == 100) msg = "Naam jap se hi shanti milegi.";
    if (count % 1000 == 0) msg = "Ek hazar jap purna! Maharaj ji ka aashirwad.";

    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("Bhajan Marg Milestone"),
      content: Text("$count Jap Purna!\n\n'$msg'"),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("Radhe Radhe"))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Naam Jap Seva"), backgroundColor: Colors.orange[900]),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("$_count", style: const TextStyle(fontSize: 100, fontWeight: FontWeight.bold, color: Colors.orange)),
          const Text("Total Jap", style: TextStyle(fontSize: 20)),
          const SizedBox(height: 50),
          GestureDetector(
            onTap: _increment,
            child: Container(
              height: 180, width: 180,
              decoration: BoxDecoration(
                color: Colors.orange[800], 
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)]
              ),
              child: const Center(child: Text("Jap Karein", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold))),
            ),
          ),
          const SizedBox(height: 40),
          TextButton(
            onPressed: () => setState(() => _count = 0), 
            child: const Text("Reset", style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    ),
      );
  }
}
