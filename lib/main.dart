import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 
import 'package:async_wallpaper/async_wallpaper.dart';

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
  void initState() {
    super.initState();
    _checkAutoDarkMode(); // फीचर 5: ऑटो डार्क मोड
  }

  void _checkAutoDarkMode() {
    var hour = DateTime.now().hour;
    if (hour >= 19 || hour <= 6) {
      setState(() => _isDarkMode = true);
    }
  }

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
    final List<Widget> _screens = [
      GitaList(onThemeToggle: widget.onThemeToggle, isDark: widget.isDark),
      const JapaTracker(),
      const WallpaperGallery(),
    ];

    return Scaffold(
      body: _screens[_tabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (index) => setState(() => _tabIndex = index),
        selectedItemColor: Colors.orange[900],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Gita"),
          BottomNavigationBarItem(icon: Icon(Icons.vibration), label: "Naam Jap"),
          BottomNavigationBarItem(icon: Icon(Icons.image), label: "Wallpaper"),
        ],
      ),
    );
  }
}

class GitaList extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDark;
  const GitaList({super.key, required this.onThemeToggle, required this.isDark});

  @override
  State<GitaList> createState() => _GitaListState();
}

class _GitaListState extends State<GitaList> {
  List _chapters = [];
  List _filteredChapters = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchGitaData();
  }

  _fetchGitaData() async {
    try {
      final response = await http.get(Uri.parse('https://bhagavadgitaapi.herokuapp.com/chapters'));
      if (response.statusCode == 200) {
        setState(() {
          _chapters = json.decode(response.body);
          _filteredChapters = _chapters;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterChapters(String query) {
    setState(() {
      _filteredChapters = _chapters
          .where((ch) => 
              ch['name'].toString().toLowerCase().contains(query.toLowerCase()) || 
              ch['chapter_number'].toString().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250, pinned: true, backgroundColor: Colors.orange[900],
          actions: [
            IconButton(icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode), onPressed: widget.onThemeToggle),
            // फीचर 3: असली Instagram लोगो
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.instagram, color: Colors.white), 
              onPressed: () => launchUrl(Uri.parse("https://www.instagram.com/bhajanmarg_official")),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: const Text("Bhajan Marg", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            background: Image.network("https://www.bhaktiphotos.com/wp-content/uploads/2023/04/Premanand-Ji-Maharaj-Photo-Download.jpg", fit: BoxFit.cover),
          ),
        ),
        // फीचर 2: Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterChapters,
              decoration: InputDecoration(
                hintText: "अध्याय खोजें...",
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.orange[50],
              ),
            ),
          ),
        ),
        if (_isLoading)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((c, i) {
              final ch = _filteredChapters[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.orange, child: Text("${ch['chapter_number']}", style: const TextStyle(color: Colors.white))),
                  title: Text(ch['name_hindi'] ?? ch['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${ch['verses_count']} श्लोक"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
              );
            }, childCount: _filteredChapters.length),
          ),
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
  int _totalCount = 0; // फीचर 5: Lifetime Total
  int _lastDayCount = 0;
  List<String> _history = [];
  String _lastDate = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    final p = await SharedPreferences.getInstance();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    setState(() {
      _totalCount = p.getInt('total_c') ?? 0;
      _lastDayCount = p.getInt('last_day_c') ?? 0;
      _history = p.getStringList('h') ?? [];
      _lastDate = p.getString('ld') ?? today;
    });

    if (_lastDate != today) {
      int todayJap = _totalCount - _lastDayCount;
      if (todayJap > 0) _history.insert(0, "$_lastDate: $todayJap जप");
      await p.setStringList('h', _history);
      await p.setString('ld', today);
      await p.setInt('last_day_c', _totalCount);
      setState(() { _lastDate = today; _lastDayCount = _totalCount; });
    }
  }

  void _increment() async {
    HapticFeedback.lightImpact();
    setState(() => _totalCount++);
    final p = await SharedPreferences.getInstance();
    p.setInt('total_c', _totalCount);
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
                  Text("$_totalCount", style: const TextStyle(fontSize: 90, fontWeight: FontWeight.bold, color: Colors.orange)),
                  const Text("कुल महामंत्र जप", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: _increment,
                    child: Container(
                      height: 160, width: 160,
                      decoration: BoxDecoration(color: Colors.orange[800], shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)]),
                      child: const Center(child: Text("जप करें", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(thickness: 2),
          Expanded(
            flex: 4,
            child: ListView.builder(
              itemCount: _history.length,
              itemBuilder: (c, i) => ListTile(title: Text(_history[i])),
            ),
          ),
        ],
      ),
    );
  }
}

class WallpaperGallery extends StatelessWidget {
  const WallpaperGallery({super.key});

  Future<void> setWallpaper(BuildContext context, String url, int location) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("वॉलपेपर सेट हो रहा है...")));
    try {
      await AsyncWallpaper.setWallpaper(url: url, wallpaperLocation: location, goToHome: true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("सफलतापूर्वक सेट किया गया!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("त्रुटि!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // फीचर 20 वॉलपेपर्स (यहाँ लिंक जोड़ते जाएँ)
    final List<String> images = [
      "https://www.bhaktiphotos.com/wp-content/uploads/2023/04/Premanand-Ji-Maharaj-Photo-Download.jpg",
      "https://www.bhaktiphotos.com/wp-content/uploads/2018/04/Lord-Krishna-Images-HD-Wallpaper-Full-Size-Download.jpg",
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("दिव्य वॉलपेपर"), backgroundColor: Colors.orange[900]),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.7),
        itemCount: images.length,
        itemBuilder: (c, i) => GestureDetector(
          onTap: () {
            // फीचर 2: Set as Wallpaper बटन
            showModalBottomSheet(
              context: context,
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(leading: const Icon(Icons.home), title: const Text("Home Screen"), onTap: () { Navigator.pop(context); setWallpaper(context, images[i], AsyncWallpaper.HOME_SCREEN); }),
                  ListTile(leading: const Icon(Icons.lock), title: const Text("Lock Screen"), onTap: () { Navigator.pop(context); setWallpaper(context, images[i], AsyncWallpaper.LOCK_SCREEN); }),
                ],
              ),
            );
          },
          child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(images[i], fit: BoxFit.cover)),
        ),
      ),
    );
  }
}
