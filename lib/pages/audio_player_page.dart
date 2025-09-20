import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class AudioPlayerPage extends StatefulWidget {
  final String audioUrl;
  final String title;
  final String imagePath;

  const AudioPlayerPage({
    super.key,
    required this.audioUrl,
    required this.title,
    required this.imagePath,
  });

  static Route createRoute(String audioUrl, String title, String imagePath) {
    return PageTransition(
      type: PageTransitionType.bottomToTop,
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      child: AudioPlayerPage(
        audioUrl: audioUrl,
        title: title,
        imagePath: imagePath,
      ),
    );
  }

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _localFilePath;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
  }

  Future<void> _setupAudioPlayer() async {
    try {
      // طلب الصلاحيات أولاً
      await _requestPermissions();

      // إعداد المستمعين أولاً
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() => _isPlaying = state == PlayerState.playing);
        }
      });

      _audioPlayer.onDurationChanged.listen((d) {
        if (mounted && d != Duration.zero) {
          setState(() => _duration = d);
        }
      });

      _audioPlayer.onPositionChanged.listen((p) {
        if (mounted && p <= _duration) {
          setState(() => _position = p);
        }
      });

      // تحميل المسار المحلي
      await _loadLocalPath();

      // تهيئة الصوت
      await _initAudio();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      print('خطأ في إعداد مشغل الصوت: $e');
    }
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

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.release();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadLocalPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _localFilePath = prefs.getString(widget.audioUrl);
    } catch (e) {
      print('خطأ في تحميل المسار المحلي: $e');
    }
  }

  Future<void> _initAudio() async {
    try {
      if (_localFilePath != null && await File(_localFilePath!).exists()) {
        await _audioPlayer.setSourceDeviceFile(_localFilePath!);
      } else {
        await _audioPlayer.setSource(UrlSource(widget.audioUrl));
      }
    } catch (e) {
      print('خطأ في تهيئة الصوت: $e');
      rethrow;
    }
  }

  Future<void> _downloadFile() async {
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
              content: Text(
                "❌ يجب السماح بصلاحيات التخزين لتحميل الملف الصوتي",
              ),
            ),
          );
          return;
        }
      }
    }

    // إظهار مؤشر تحميل
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("⏳ جارٍ تحميل الملف الصوتي إلى مجلد التنزيلات..."),
        duration: Duration(seconds: 3),
      ),
    );

    try {
      final response = await http.get(Uri.parse(widget.audioUrl));

      if (response.statusCode != 200) {
        throw Exception('فشل في تحميل الملف الصوتي: ${response.statusCode}');
      }

      // الحصول على مجلد التنزيلات
      final downloadDir = await _getDownloadDirectory();

      // إنشاء اسم الملف
      String audioTitle = widget.title;
      // تنظيف العنوان من الرموز غير المسموحة
      audioTitle = audioTitle.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      audioTitle = audioTitle.replaceAll('🎵', '').trim();
      if (audioTitle.isEmpty) audioTitle = 'audio';

      final fileName =
          "${audioTitle}_${DateTime.now().millisecondsSinceEpoch}.mp3";
      final file = File('${downloadDir.path}/$fileName');

      // كتابة الملف
      await file.writeAsBytes(response.bodyBytes);

      if (!mounted) return;

      // حفظ مسار الملف في SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(widget.audioUrl, file.path);

      setState(() => _localFilePath = file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("✅ تم حفظ الملف الصوتي بنجاح"),
              Text(
                "📁 المسار: ${file.path}",
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );

      // إعادة تهيئة الصوت لاستخدام النسخة المحلية
      await _initAudio();
    } catch (e) {
      print("خطأ في تحميل الملف الصوتي: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ فشل التحميل: $e")));
    }
  }

  // التحقق من وجود الملف محلياً
  bool _isFileDownloaded() {
    if (_localFilePath == null) return false;
    return File(_localFilePath!).existsSync();
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } catch (e) {
      print('خطأ في تشغيل/إيقاف الصوت: $e');
    }
  }

  String _formatTime(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                'حدث خطأ في تحميل الملف الصوتي',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _setupAudioPlayer(),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    final double maxSliderValue = _duration.inSeconds > 0
        ? _duration.inSeconds.toDouble()
        : 1;
    final double currentSliderValue = _position.inSeconds.toDouble().clamp(
      0,
      maxSliderValue,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            ClipPath(
              clipper: OvalBottomClipper(),
              child: Container(
                height: 400,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _formatTime(_duration),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Slider(
                    value: currentSliderValue,
                    min: 0,
                    max: maxSliderValue,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white24,
                    onChanged: (value) async {
                      try {
                        final newPosition = Duration(seconds: value.toInt());
                        await _audioPlayer.seek(newPosition);
                      } catch (e) {
                        print('خطأ في تغيير موضع الصوت: $e');
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTime(_position),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        _formatTime(_duration),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _controlButton(
                        icon: Icons.play_arrow,
                        activeIcon: Icons.pause,
                        active: _isPlaying,
                        onTap: _togglePlayPause,
                        activeColors: [
                          Colors.blue.shade800,
                          Colors.blue.shade600,
                        ],
                        inactiveColors: [
                          Colors.blue.shade800,
                          Colors.blue.shade600,
                        ],
                      ),
                      const SizedBox(width: 20),
                      _controlButton(
                        icon: _isFileDownloaded()
                            ? Icons.download_done
                            : Icons.download,
                        activeIcon: _isFileDownloaded()
                            ? Icons.download_done
                            : Icons.download,
                        active: _isFileDownloaded(),
                        onTap: _isFileDownloaded()
                            ? () {} // لا تفعل شيئاً إذا كان محملاً
                            : _downloadFile,
                        activeColors: [
                          Colors.green.shade800,
                          Colors.green.shade600,
                        ],
                        inactiveColors: [
                          Colors.green.shade800,
                          Colors.green.shade600,
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required IconData activeIcon,
    required bool active,
    required VoidCallback onTap,
    required List<Color> activeColors,
    required List<Color> inactiveColors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: active ? activeColors : inactiveColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(active ? activeIcon : icon, size: 22, color: Colors.white),
      ),
    );
  }
}

class OvalBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 50,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
