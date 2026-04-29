import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

class GitaList extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDark;
  const GitaList({super.key, required this.onThemeToggle, required this.isDark});

  @override
  State<GitaList> createState() => _GitaListState();
}

class _GitaListState extends State<GitaList> {
  List _chapters = [];
  List _filteredChapters = []; // Search के लिए Filtered List
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
          _filteredChapters = _chapters; // शुरुआत में सब दिखाओ
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Search Function
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
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: const Text("Bhajan Marg", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            background: Image.network("https://www.bhaktiphotos.com/wp-content/uploads/2023/04/Premanand-Ji-Maharaj-Photo-Download.jpg", fit: BoxFit.cover),
          ),
        ),
        // Search Bar Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterChapters,
              decoration: InputDecoration(
                hintText: "अध्याय का नाम या नंबर खोजें...",
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
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Loading Chapter ${ch['chapter_number']}...")));
                  },
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

    if (_lastDate != today && _count > 0) {
      _history.insert(0, "$_lastDate: $_count जप (स्वयं सेवित)");
      _count = 0;
      await p.setInt('c', 0);
      await p.setStringList('h', _history);
      await p.setString('ld', today);
      setState(() {});
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
                        color: Colors.orange[800], shape: BoxShape.circle,
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
          const Padding(padding: EdgeInsets.all(8), child: Text("साधना इतिहास", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
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
                      title: Text(_history[i]),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
