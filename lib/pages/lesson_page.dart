import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'audio_player_page.dart'; // إستيراد صفحة المشغل

// صفحة عرض الدروس
class LessonsPage extends StatefulWidget {
  final String seriesTitle;
  final String seriesId;

  const LessonsPage({
    super.key,
    required this.seriesTitle,
    required this.seriesId,
  });

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  List<Map<String, dynamic>> lessons = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadLessons();
  }

  // تحميل الدروس من الإنترنت
  Future<void> loadLessons() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://gist.githubusercontent.com/MahmoudBarakat15/0765fdeb99cd61e770c89f286bb354c4/raw/series_sound',
        ),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['series'].containsKey(widget.seriesId)) {
          List<dynamic> seriesLessons =
              jsonData['series'][widget.seriesId]['lessons'];
          setState(() {
            lessons = seriesLessons.cast<Map<String, dynamic>>();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'السلسلة غير موجودة';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'فشل في تحميل البيانات';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'خطأ في الاتصال بالإنترنت';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/80.jpg"), // نفس الخلفية
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.black.withOpacity(0.5),
              elevation: 0,
              title: Text(
                widget.seriesTitle,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (errorMessage != null)
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });
                      loadLessons();
                    },
                  ),
              ],
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            "جاري تحميل الدروس...",
                            style: TextStyle(
                              fontFamily: "Cairo",
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            errorMessage!,
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                                errorMessage = null;
                              });
                              loadLessons();
                            },
                            icon: const Icon(Icons.refresh),
                            label: Text(
                              "إعادة المحاولة",
                              style: GoogleFonts.cairo(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3E6259),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : lessons.isEmpty
                  ? const Center(
                      child: Text(
                        "لا توجد دروس متاحة",
                        style: TextStyle(
                          fontFamily: "Cairo",
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: lessons.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final lesson = lessons[index];
                        return InkWell(
                          onTap: () => playLesson(lesson),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3E6259).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                // أيقونة التشغيل
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: const Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // معلومات الدرس
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        lesson['title'] ?? 'الدرس ${index + 1}',
                                        style: GoogleFonts.cairo(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      const SizedBox(height: 6),
                                      if (lesson['description'] != null)
                                        Text(
                                          lesson['description'],
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            color: Colors.white70,
                                          ),
                                          textAlign: TextAlign.right,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      const SizedBox(height: 4),
                                      if (lesson['duration'] != null)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              lesson['duration'],
                                              style: GoogleFonts.cairo(
                                                fontSize: 11,
                                                color: Colors.white60,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Icon(
                                              Icons.access_time,
                                              size: 14,
                                              color: Colors.white60,
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
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
      ),
    );
  }

  // دالة تشغيل الدرس باستخدام AudioPlayerPage
  void playLesson(Map<String, dynamic> lesson) {
    String audioUrl = lesson['audio_url'] ?? '';
    String lessonTitle = lesson['title'] ?? 'درس غير معروف';

    if (audioUrl.isNotEmpty && !audioUrl.contains('example.com')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioPlayerPage(
            audioUrl: audioUrl,
            title: lessonTitle,
            imagePath: "assets/80.jpg", // ✅ التعديل هنا
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "رابط الصوت غير متوفر أو تجريبي",
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
