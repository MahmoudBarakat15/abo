import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// --- الحزم الجديدة المطلوبة ---
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingleVideoPage extends StatefulWidget {
  const SingleVideoPage({super.key});

  @override
  State<SingleVideoPage> createState() => _SingleVideoPageState();
}

class _SingleVideoPageState extends State<SingleVideoPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // ← تم التعديل هنا: إزالة المسافة الزائدة من الرابط
  final String jsonUrl =
      "https://gist.githubusercontent.com/MahmoudBarakat15/986d31186051fb1f3249024d48fe2d64/raw/single_video";

  late List<Map<String, dynamic>> _videos;
  late List<Map<String, dynamic>> _categories;
  String _selectedCategory = "الكل";
  List<Map<String, dynamic>> _filteredVideos = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // ← جديد: قائمة لحفظ مسارات الفيديوهات المُنزّلة
  List<String?> _localFiles = [];

  // ← جديد: لتتبع تقدم التحميل
  final Map<int, double> _downloadProgress = {};
  final Map<int, bool> _isDownloading = {};

  @override
  void initState() {
    super.initState();
    _loadJsonData();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  Future<void> _loadJsonData() async {
    try {
      final response = await http.get(Uri.parse(jsonUrl));

      if (response.statusCode == 200) {
        _parseJsonData(response.body);
        await _loadLocalFilePaths(); // ← تحميل المسارات بعد تحليل البيانات
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'فشل في تحميل البيانات: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'خطأ في الاتصال: $e';
      });
    }
  }

  void _parseJsonData(String jsonString) {
    final Map<String, dynamic> data = json.decode(jsonString);
    _videos = List<Map<String, dynamic>>.from(data['videos']);

    for (var video in _videos) {
      video['thumbnail'] ??=
          'https://img.freepik.com/free-photo/islamic-pattern-background_23-2148882877.jpg';
      video['description'] ??= 'فيديو إسلامي مفيد';
      video['views'] ??= '0';
    }

    _categories = List<Map<String, dynamic>>.from(data['categories']);
    _filteredVideos = List.from(_videos);
    _localFiles = List.filled(_videos.length, null); // ← تهيئة القائمة
  }

  void _filterVideosByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == "الكل") {
        _filteredVideos = List.from(_videos);
      } else {
        _filteredVideos = _videos
            .where((video) => video['category'] == category)
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ← جديد: دالة لطلب الصلاحيات
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
      if (await Permission.videos.isDenied) {
        await Permission.videos.request();
      }
    }
  }

  // ← جديد: الحصول على مجلد التنزيل
  Future<Directory> _getDownloadDirectory() async {
    Directory? directory;

    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download/SheikhHuwayni');
      if (!(await directory.exists())) {
        try {
          await directory.create(recursive: true);
        } catch (e) {
          final appDir = await getExternalStorageDirectory();
          directory = Directory('${appDir?.path}/SheikhHuwayni');
          await directory.create(recursive: true);
        }
      }
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      directory = Directory('${appDir.path}/SheikhHuwayni');
      await directory.create(recursive: true);
    }

    return directory;
  }

  // ← جديد: حفظ مسارات الملفات المحلية
  Future<void> _saveLocalFilePaths() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, String> fileMap = {};

    for (int i = 0; i < _localFiles.length; i++) {
      if (_localFiles[i] != null && _videos.length > i) {
        fileMap[_videos[i]["url"]!] = _localFiles[i]!;
      }
    }

    await prefs.setString('local_video_files_single', jsonEncode(fileMap));
  }

  // ← جديد: تحميل مسارات الملفات المحلية
  Future<void> _loadLocalFilePaths() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedFiles = prefs.getString('local_video_files_single');

    if (savedFiles != null) {
      final Map<String, dynamic> fileMap = jsonDecode(savedFiles);

      for (int i = 0; i < _videos.length; i++) {
        final videoUrl = _videos[i]["url"];
        if (fileMap.containsKey(videoUrl)) {
          final filePath = fileMap[videoUrl] as String;
          if (await File(filePath).exists()) {
            _localFiles[i] = filePath;
          }
        }
      }
    }
  }

  // ← معدل: دالة تحميل الفيديو مع تتبع التقدم وزر "فتح الملف"
  Future<void> _downloadVideo(int index) async {
    if (!mounted) return;

    // التحقق من الصلاحيات
    bool hasPermission = true;
    if (Platform.isAndroid) {
      if (await Permission.storage.isDenied &&
          await Permission.videos.isDenied) {
        hasPermission = false;
        await _requestPermissions();
        if (await Permission.storage.isDenied &&
            await Permission.videos.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ يجب السماح بصلاحيات التخزين")),
          );
          return;
        }
      }
    }

    setState(() {
      _isDownloading[index] = true;
      _downloadProgress[index] = 0.0;
    });

    try {
      final video = _videos[index];
      final url = video["url"]!;
      final request = await http.Client().send(
        http.Request('GET', Uri.parse(url)),
      );

      if (request.statusCode != 200) {
        throw Exception('فشل التحميل: ${request.statusCode}');
      }

      final totalBytes = request.contentLength ?? -1;
      int receivedBytes = 0;

      final downloadDir = await _getDownloadDirectory();

      String title = video["title"] ?? "فيديو";
      title = title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
      if (title.isEmpty) title = 'video';

      final fileName = "${title}_${DateTime.now().millisecondsSinceEpoch}.mp4";
      final file = File('${downloadDir.path}/$fileName');

      final sink = file.openWrite();

      await request.stream.listen((chunk) {
        receivedBytes += chunk.length;
        if (totalBytes > 0 && mounted) {
          setState(() {
            _downloadProgress[index] = receivedBytes / totalBytes;
          });
        }
        sink.add(chunk);
      }).asFuture();

      await sink.close();

      if (!mounted) return;

      setState(() {
        _localFiles[index] = file.path;
        _isDownloading.remove(index);
        _downloadProgress.remove(index);
      });

      await _saveLocalFilePaths();

      // ← SnackBar مخصص مع زر "فتح الملف"
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ تم حفظ: ${video["title"]}"),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'فتح الملف',
            textColor: Colors.greenAccent,
            onPressed: () {
              _showVideoPlayer(
                video["url"]!,
                video["title"]!,
                video["description"]!,
                index,
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDownloading.remove(index);
        _downloadProgress.remove(index);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ فشل التحميل: $e")));
    }
  }

  // ← جديد: التحقق مما إذا كان الفيديو مُنزّلًا
  bool _isVideoDownloaded(int index) {
    if (_localFiles[index] == null) return false;
    return File(_localFiles[index]!).existsSync();
  }

  // ← معدل: عند عرض المشغل، نمرر أيضًا المسار المحلي إن وُجد
  void _showVideoPlayer(
    String url,
    String title,
    String description,
    int index,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _VideoPlayerDialog(
        url: url,
        title: title,
        description: description,
        localPath: _localFiles[index], // ← نمرر المسار المحلي
      ),
    );
  }

  Widget _buildCategoryChip(String category, String icon, Color color) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              category,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                // ← تم التعديل هنا: لون أغمق وأكثر وضوحًا في الوضع النهاري
                color: isSelected
                    ? Colors.blue[800]
                    : Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(
                        0xFF0D1B2A,
                      ), // ← لون أزرق-أسود غامق للوضع النهاري
              ),
            ),
          ],
        ),
        onSelected: (_) => _filterVideosByCategory(category),
        backgroundColor: Colors.white.withOpacity(0.1),
        selectedColor: color.withOpacity(0.8),
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? color : color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video, int index) {
    final isDownloaded = _isVideoDownloaded(index);
    final actualIndex = _videos.indexOf(video);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                video["thumbnail"]!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video["title"]!,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      // ← تم التعديل هنا: لون العنوان في الوضع النهاري
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF0D1B2A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    video["description"]!,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      // ← تم التعديل هنا: لون الوصف في الوضع النهاري
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : const Color(0xFF415A77), // ← رمادي-أزرق متوسط
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ← زر التنزيل الجديد
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadVideo(actualIndex),
                      icon: Icon(
                        isDownloaded
                            ? Icons.download_done
                            : Icons.download_for_offline,
                        size: 18,
                        // ← تم التعديل هنا: لون الأيقونة في الوضع النهاري
                        color: Theme.of(context).brightness == Brightness.dark
                            ? null
                            : Colors.white,
                      ),
                      label: Text(
                        isDownloaded ? "محفوظ" : "تنزيل",
                        style: TextStyle(
                          fontSize: 13,
                          // ← تم التعديل هنا: لون النص في الوضع النهاري
                          color: Theme.of(context).brightness == Brightness.dark
                              ? null
                              : Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDownloaded
                            ? Colors.green.withOpacity(0.8)
                            : Colors
                                  .blue[800], // ← تم التعديل هنا: لون أغمق في الوضع النهاري
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() =>
      const Center(child: CircularProgressIndicator());

  Widget _buildErrorWidget() => Center(
    child: Text(
      _errorMessage,
      style: GoogleFonts.cairo(
        // ← تم التعديل هنا: لون رسالة الخطأ في الوضع النهاري
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : const Color(0xFF0D1B2A),
      ),
    ),
  );

  Widget _buildDownloadProgressBar() {
    final activeDownloads = _isDownloading.entries
        .where((e) => e.value)
        .toList();
    if (activeDownloads.isEmpty) return const SizedBox.shrink();

    final index = activeDownloads.first.key;
    final progress = _downloadProgress[index] ?? 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      // ← تم التعديل هنا: لون شريط التقدم في الوضع النهاري
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.blueGrey[900]
          : Colors.blue[100],
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white12
                : Colors.blue[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 4,
          ),
          const SizedBox(height: 4),
          Text(
            "جارٍ التحميل... ${progress != null ? '${(progress * 100).toStringAsFixed(0)}%' : ''}",
            style: TextStyle(
              // ← تم التعديل هنا: لون نص التقدم في الوضع النهاري
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF0D1B2A),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎬 المكتبة المرئية"),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: _buildDownloadProgressBar(), // ← شريط التقدم في أعلى الصفحة
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0A0E27), const Color(0xFF1A1F3A)]
                : [Colors.blue[50]!, Colors.blue[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? _buildLoadingIndicator()
              : _errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : Column(
                  children: [
                    SizedBox(
                      height: 60,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildCategoryChip(
                            "الكل",
                            "📱",
                            const Color(0xFF795548),
                          ),
                          ..._categories.map(
                            (category) => _buildCategoryChip(
                              category["name"]!,
                              category["icon"]!,
                              Color(
                                int.parse(
                                  category["color"]!.replaceAll('#', '0xFF'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredVideos.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _showVideoPlayer(
                              _filteredVideos[index]["url"]!,
                              _filteredVideos[index]["title"]!,
                              _filteredVideos[index]["description"]!,
                              _videos.indexOf(_filteredVideos[index]),
                            ),
                            child: _buildVideoCard(
                              _filteredVideos[index],
                              index,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ← معدل: نضيف معلمة localPath
class _VideoPlayerDialog extends StatefulWidget {
  final String url;
  final String title;
  final String description;
  final String? localPath; // ← جديد

  const _VideoPlayerDialog({
    required this.url,
    required this.title,
    required this.description,
    this.localPath,
  });

  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // ← نستخدم الملف المحلي إذا وُجد، وإلا نستخدم الرابط
    if (widget.localPath != null && File(widget.localPath!).existsSync()) {
      _videoController = VideoPlayerController.file(File(widget.localPath!));
    } else {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
      );
    }

    _videoController
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() {
            _chewieController = ChewieController(
              videoPlayerController: _videoController,
              autoPlay: true,
              looping: false,
            );
            _isLoading = false;
          });
        })
        .catchError((error) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ خطأ في تشغيل الفيديو: $error")),
          );
        });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // العنوان
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.green, Colors.teal],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Chewie(controller: _chewieController!),
                  ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.description,
                style: GoogleFonts.cairo(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
