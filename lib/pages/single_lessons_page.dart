import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'audio_player_page.dart';

class SingleLessonsPage extends StatefulWidget {
  const SingleLessonsPage({super.key});
  @override
  State<SingleLessonsPage> createState() => _SingleLessonsPageState();
}

class _SingleLessonsPageState extends State<SingleLessonsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> lessons = [];
  List<Map<String, String>> filteredLessons = [];

  final List<Color> lessonColors = [
    Colors.red,
    Colors.purple,
    Colors.pink,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    _loadLessons();
    _searchController.addListener(_filterLessons);
  }

  /// 🔹 تحميل الملف سواء من الإنترنت أو من التخزين
  Future<void> _loadLessons() async {
    try {
      // نجرب نجيب من الإنترنت
      final response = await http.get(
        Uri.parse(
          'https://gist.githubusercontent.com/MahmoudBarakat15/d0a4a606bae82080fd6a04dd8b1da227/raw/singel_sound',
        ),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          lessons = data
              .map(
                (e) => {
                  'title': e['title'].toString(),
                  'audioUrl': e['audioUrl'].toString(),
                },
              )
              .toList();
          filteredLessons = lessons;
        });

        // ✅ حفظ نسخة أوفلاين
        final file = await _getLocalFile();
        await file.writeAsString(json.encode(lessons));
        return;
      }
    } catch (e) {
      debugPrint("No internet, will try offline file...");
    }

    // ✅ لو النت مش موجود أو فشل → نقرأ النسخة المحفوظة
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        final List data = json.decode(content);
        setState(() {
          lessons = List<Map<String, String>>.from(data);
          filteredLessons = lessons;
        });
      }
    } catch (e) {
      debugPrint("Error reading local lessons: $e");
    }
  }

  /// 🔹 مكان حفظ الملف
  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/single_lessons.json');
  }

  void _filterLessons() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredLessons = lessons
          .where((lesson) => lesson['title']!.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الدروس المنفردة',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.tealAccent : Colors.blue[800],
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: isDark ? Colors.black : const Color(0xFFF2F2F2),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'ابحث عن درس...',
                hintStyle: const TextStyle(fontFamily: 'Cairo'),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: lessons.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredLessons.length,
                    itemBuilder: (context, index) {
                      final lesson = filteredLessons[index];
                      final color = lessonColors[index % lessonColors.length];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AudioPlayerPage(
                                audioUrl: lesson['audioUrl']!,
                                title: lesson['title']!,
                                imagePath: "assets/audio_cover.jpg",
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isDark ? Colors.grey[900] : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black54
                                    : Colors.grey.shade300,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                child: Container(
                                  width: 10,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 16),
                                  Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: color,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Center(
                                      child: Icon(
                                        Icons.mic,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      lesson['title']!,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
