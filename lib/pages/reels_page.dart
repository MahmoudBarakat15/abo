import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReelsPage extends StatefulWidget {
  const ReelsPage({super.key});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  final PageController _pageController = PageController();

  List<String> _videos = [];
  List<String> _titles = [];

  int currentIndex = 0;

  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, ChewieController> _chewieControllers = {};
  final Map<int, bool> _isOfflineMap = {};
  final Map<int, VoidCallback> _videoListeners = {};

  List<String?> _localFiles = [];
  Duration _videoPosition = Duration.zero;
  Duration _videoDuration = Duration.zero;

  final String jsonUrl =
      "https://gist.githubusercontent.com/MahmoudBarakat15/4549351733dce420eeffbe42f19f73f4/raw/reels.json";

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadJsonData();
  }

  // طلب الصلاحيات المطلوبة
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      // للأندرويد 13 وما فوق
      if (await Permission.videos.isDenied) {
        await Permission.videos.request();
      }
      if (await Permission.audio.isDenied) {
        await Permission.audio.request();
      }

      // للإصدارات الأقدم
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }

      // صلاحية الإشعارات
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    }
  }

  // الحصول على مجلد التنزيلات العام
  Future<Directory> _getDownloadDirectory() async {
    Directory? directory;

    if (Platform.isAndroid) {
      // محاولة الحصول على مجلد التنزيلات العام
      directory = Directory('/storage/emulated/0/Download/SheikhHuwayni');

      // إذا لم يوجد، إنشاؤه
      if (!(await directory.exists())) {
        try {
          await directory.create(recursive: true);
        } catch (e) {
          // في حالة فشل إنشاء المجلد العام، استخدم مجلد التطبيق
          final appDir = await getExternalStorageDirectory();
          directory = Directory('${appDir?.path}/SheikhHuwayni');
          await directory.create(recursive: true);
        }
      }
    } else {
      // لـ iOS
      final appDir = await getApplicationDocumentsDirectory();
      directory = Directory('${appDir.path}/SheikhHuwayni');
      await directory.create(recursive: true);
    }

    return directory;
  }

  // حفظ مسارات الملفات المحلية
  Future<void> _saveLocalFilePaths() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, String> fileMap = {};

    for (int i = 0; i < _localFiles.length; i++) {
      if (_localFiles[i] != null && _videos.length > i) {
        fileMap[_videos[i]] = _localFiles[i]!;
      }
    }

    await prefs.setString('local_video_files', jsonEncode(fileMap));
  }

  // تحميل مسارات الملفات المحلية
  Future<void> _loadLocalFilePaths() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedFiles = prefs.getString('local_video_files');

    if (savedFiles != null) {
      final Map<String, dynamic> fileMap = jsonDecode(savedFiles);

      for (int i = 0; i < _videos.length; i++) {
        if (fileMap.containsKey(_videos[i])) {
          final filePath = fileMap[_videos[i]] as String;
          // التحقق من وجود الملف
          if (await File(filePath).exists()) {
            _localFiles[i] = filePath;
          }
        }
      }
    }
  }

  Future<void> _loadJsonData() async {
    try {
      final response = await http.get(Uri.parse(jsonUrl));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        if (!mounted) return;
        setState(() {
          _videos = data.map((v) => v["url"] as String).toList();
          _titles = data.map((v) => v["title"] as String).toList();
          _localFiles = List.filled(_videos.length, null);
        });

        // تحميل مسارات الملفات المحفوظة سابقاً
        await _loadLocalFilePaths();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadVideo(0, autoPlay: true);
          _loadVideo(1);
        });
      } else {
        throw Exception('فشل في تحميل البيانات: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("خطأ في تحميل JSON: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ خطأ في تحميل البيانات: $e")));
      }
    }
  }

  Future<void> _loadVideo(int index, {bool autoPlay = false}) async {
    if (index < 0 || index >= _videos.length || !mounted) return;

    // التخلص من المُتحكم القديم إذا وُجد
    if (_videoControllers.containsKey(index)) {
      _disposeControllerAtIndex(index);
    }

    try {
      File? file;
      if (_localFiles[index] != null) {
        file = File(_localFiles[index]!);
      }

      VideoPlayerController videoController;
      bool offline = false;

      if (file != null && await file.exists()) {
        offline = true;
        videoController = VideoPlayerController.file(file);
      } else {
        videoController = VideoPlayerController.networkUrl(
          Uri.parse(_videos[index]),
        );
      }

      await videoController.initialize();

      if (!mounted) {
        videoController.dispose();
        return;
      }

      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: false,
        looping: false,
        showControls: false,
        allowFullScreen: false,
        allowMuting: false,
        aspectRatio: videoController.value.aspectRatio == 0
            ? 9 / 16
            : videoController.value.aspectRatio,
      );

      _videoControllers[index] = videoController;
      _chewieControllers[index] = chewieController;
      _isOfflineMap[index] = offline;

      // إنشاء listener منفصل لكل فيديو
      _videoListeners[index] = () {
        if (!mounted || !_videoControllers.containsKey(index)) return;
        if (index == currentIndex) {
          final pos = videoController.value.position;
          if (pos != _videoPosition) {
            setState(() {
              _videoPosition = pos;
            });
          }
        }
      };

      videoController.addListener(_videoListeners[index]!);

      if (index == currentIndex) {
        _videoDuration = videoController.value.duration;
        _videoPosition = videoController.value.position;
        if (autoPlay) {
          _pauseAllExcept(index);
          videoController.play();
        }
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("خطأ في تحميل الفيديو $index: $e");
      if (mounted) {
        if (index == currentIndex) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("❌ خطأ في تحميل الفيديو: $e")));
        }
      }
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (_videoListeners.containsKey(index)) {
      _videoControllers[index]?.removeListener(_videoListeners[index]!);
      _videoListeners.remove(index);
    }
    _videoControllers[index]?.dispose();
    _chewieControllers[index]?.dispose();
    _videoControllers.remove(index);
    _chewieControllers.remove(index);
    _isOfflineMap.remove(index);
  }

  void _onPageChanged(int index) async {
    if (!mounted) return;

    // تحميل الفيديو الحالي إذا لم يكن محملاً
    if (!_videoControllers.containsKey(index)) {
      await _loadVideo(index);
    }

    if (!mounted) return;

    setState(() {
      currentIndex = index;
      _videoDuration =
          _videoControllers[index]?.value.duration ?? Duration.zero;
      _videoPosition =
          _videoControllers[index]?.value.position ?? Duration.zero;
    });

    _pauseAllExcept(index);
    _videoControllers[index]?.seekTo(Duration.zero);
    _videoControllers[index]?.play();

    // تحميل الفيديوهات المجاورة للتجربة السلسة
    _loadVideo(index - 1);
    _loadVideo(index + 1);
    _loadVideo(index + 2);

    // تدمير الفيديوهات البعيدة
    _disposeFarControllers(index);
  }

  void _pauseAllExcept(int keepIndex) {
    for (var entry in _videoControllers.entries) {
      if (entry.key != keepIndex && entry.value.value.isPlaying) {
        entry.value.pause();
      }
    }
  }

  void _disposeFarControllers(int center) {
    final keys = List<int>.from(_videoControllers.keys);
    for (final i in keys) {
      if (i < center - 2 || i > center + 2) {
        _disposeControllerAtIndex(i);
      }
    }
  }

  Future<void> _downloadVideo(int index) async {
    if (!mounted) return;

    // التحقق من الصلاحيات أولاً
    bool hasPermission = true;
    if (Platform.isAndroid) {
      if (await Permission.videos.isDenied &&
          await Permission.storage.isDenied) {
        hasPermission = false;
        await _requestPermissions();

        // إعادة التحقق
        if (await Permission.videos.isDenied &&
            await Permission.storage.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("❌ يجب السماح بصلاحيات التخزين لتحميل الفيديو"),
            ),
          );
          return;
        }
      }
    }

    // إظهار مؤشر تحميل
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("⏳ جارٍ تحميل المقطع إلى مجلد التنزيلات..."),
        duration: Duration(seconds: 3),
      ),
    );

    try {
      final url = _videos[index];
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('فشل في تحميل الفيديو: ${response.statusCode}');
      }

      // الحصول على مجلد التنزيلات
      final downloadDir = await _getDownloadDirectory();

      // إنشاء اسم الملف
      String videoTitle = _getVideoTitle(index);
      // تنظيف العنوان من الرموز غير المسموحة
      videoTitle = videoTitle.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      videoTitle = videoTitle.replaceAll('🎥', '').trim();
      if (videoTitle.isEmpty) videoTitle = 'video';

      final fileName =
          "${videoTitle}_${DateTime.now().millisecondsSinceEpoch}.mp4";
      final file = File('${downloadDir.path}/$fileName');

      // كتابة الملف
      await file.writeAsBytes(response.bodyBytes);

      if (!mounted) return;

      setState(() {
        _localFiles[index] = file.path;
      });

      // حفظ مسار الملف
      await _saveLocalFilePaths();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("✅ تم حفظ المقطع بنجاح"),
              Text(
                "📁 المسار: ${file.path}",
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );

      // إعادة تحميل الفيديو لاستخدام النسخة المحلية
      if (index == currentIndex) {
        _loadVideo(index, autoPlay: true);
      }
    } catch (e) {
      debugPrint("خطأ في تحميل الفيديو: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ فشل التحميل: $e")));
    }
  }

  String _getVideoTitle(int index) {
    if (index < _titles.length && _titles[index].isNotEmpty) {
      return _titles[index];
    } else {
      return "مقطع بدون عنوان";
    }
  }

  bool _isVideoDownloaded(int index) {
    if (_localFiles[index] == null) return false;
    return File(_localFiles[index]!).existsSync();
  }

  void _togglePlayPause() {
    final controller = _videoControllers[currentIndex];
    if (controller == null || !mounted) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    setState(() {});
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    for (var index in List<int>.from(_videoControllers.keys)) {
      _disposeControllerAtIndex(index);
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_videoDuration.inMilliseconds > 0)
        ? _videoPosition.inMilliseconds / _videoDuration.inMilliseconds
        : 0.0;

    Duration remaining = _videoDuration - _videoPosition;
    if (remaining.isNegative) remaining = Duration.zero;

    if (_videos.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                "⏳ جارٍ تحميل البيانات...",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _videos.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final chewie = _chewieControllers[index];

              return GestureDetector(
                onTap: _togglePlayPause,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // عرض الفيديو أو مؤشر التحميل
                    chewie != null &&
                            chewie.videoPlayerController.value.isInitialized
                        ? Chewie(controller: chewie)
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16),
                                Text(
                                  "⏳ جارٍ تحميل الفيديو...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                    // زر التحميل
                    if (!_isVideoDownloaded(index))
                      Positioned(
                        bottom: 120,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: ElevatedButton.icon(
                            onPressed: () => _downloadVideo(index),
                            icon: const Icon(Icons.download_for_offline),
                            label: const Text("حفظ في الجهاز"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.withOpacity(0.9),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // عنوان الفيديو
                    Positioned(
                      bottom: 40,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getVideoTitle(index),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // مؤشر حالة التشغيل
                    Positioned(
                      left: 16,
                      top: MediaQuery.of(context).padding.top + 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isOfflineMap[index] == true
                                  ? Icons.download_done
                                  : Icons.wifi,
                              color: _isOfflineMap[index] == true
                                  ? Colors.green
                                  : Colors.blue,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isOfflineMap[index] == true
                                  ? "محفوظ في الجهاز"
                                  : "من الإنترنت",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // شريط التقدم والوقت المتبقي
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.redAccent,
                      ),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "- ${_formatDuration(remaining)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
