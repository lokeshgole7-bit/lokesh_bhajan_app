import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: GitaPage(),
  ));
}

class GitaPage extends StatelessWidget {
  const GitaPage({super.key});

  final List<String> chapters = const [
    "1. अर्जुनविषादयोग", 
    "2. सांख्ययोग", 
    "3. कर्मयोग", 
    "4. ज्ञानकर्मसंन्यासयोग",
    "5. कर्मसंन्यासयोग", 
    "6. आत्मसंयमयोग", 
    "7. ज्ञानविज्ञानयोग", 
    "8. अक्षरब्रह्मयोग",
    "9. राजविद्याराजगुह्ययोग", 
    "10. विभूतियोग", 
    "11. विश्वरूपदर्शनयोग", 
    "12. भक्तियोग",
    "13. क्षेत्र-क्षेत्रज्ञविभागयोग", 
    "14. गुणत्रयविभागयोग", 
    "15. पुरुषोत्तमयोग",
    "16. दैवासुरसम्पद्विभागयोग", 
    "17. श्रद्धात्रयविभागयोग", 
    "18. मोक्षसंन्यासयोग"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("श्रीमद्भगवद्गीता"),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        itemCount: chapters.length,
        itemBuilder: (context, index) => Card(
          child: ListTile(
            title: Text(chapters[index]),
            leading: const Icon(Icons.book, color: Colors.orange),
            onTap: () {
              // यहाँ आप अध्याय खोलने का कोड डाल सकते हैं
            },
          ),
        ),
      ),
    );
  }
}
