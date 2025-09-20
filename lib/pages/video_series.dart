import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class VideoSeriesPage extends StatefulWidget {
  const VideoSeriesPage({super.key});

  @override
  State<VideoSeriesPage> createState() => _VideoSeriesPageState();
}

class _VideoSeriesPageState extends State<VideoSeriesPage>
    with TickerProviderStateMixin {
  // Core Data
  List<VideoItem> videos = [];
  List<VideoItem> filteredVideos = [];
  bool isLoading = true;
  bool hasError = false;

  // Search & Filter
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  // Network & Notifications
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Download Management (مبسط مثل ReelsPage)
  // تم إزالة متغيرات التحميل المعقدة

  // UI Controllers
  final ScrollController _scrollController = ScrollController();
  final PageController _featuredPageController = PageController();
  bool _showAppBarTitle = false;
  int _currentFeaturedIndex = 0;

  // Animations
  late AnimationController _mainAnimationController;
  late AnimationController _fabAnimationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _searchSlideAnimation;

  // Video Player
  VideoItem? _playingVideo;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  // Local Files Management (like ReelsPage)
  List<String?> _localFiles = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeNotifications();
    _setupScrollListener();
    _loadVideos();
    _startFeaturedAutoScroll();
    _searchController.addListener(_onSearchChanged);
    _requestPermissions();
  }

  // ✅ إضافة طلب الصلاحيات (مثل ReelsPage)
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.videos.isDenied) {
        await Permission.videos.request();
      }
      if (await Permission.audio.isDenied) {
        await Permission.audio.request();
      }
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    }
  }

  // ✅ إضافة دالة الحصول على مجلد التنزيلات (مثل ReelsPage)
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

  // ✅ إضافة دوال حفظ وتحميل مسارات الملفات المحلية (مثل ReelsPage)
  Future<void> _saveLocalFilePaths() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, String> fileMap = {};
    for (int i = 0; i < _localFiles.length; i++) {
      if (_localFiles[i] != null && videos.length > i) {
        fileMap[videos[i].url] = _localFiles[i]!;
      }
    }
    await prefs.setString('local_video_series_files', jsonEncode(fileMap));
  }

  Future<void> _loadLocalFilePaths() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedFiles = prefs.getString('local_video_series_files');
    if (savedFiles != null) {
      final Map<String, dynamic> fileMap = jsonDecode(savedFiles);
      for (int i = 0; i < videos.length; i++) {
        if (fileMap.containsKey(videos[i].url)) {
          final filePath = fileMap[videos[i].url] as String;
          if (await File(filePath).exists()) {
            _localFiles[i] = filePath;
          }
        }
      }
    }
  }

  // ✅ التحقق من تحميل الفيديو (مثل ReelsPage)
  bool _isVideoDownloaded(int index) {
    if (index >= _localFiles.length || _localFiles[index] == null) return false;
    return File(_localFiles[index]!).existsSync();
  }

  void _initializeAnimations() {
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainAnimationController,
            curve: Curves.elasticOut,
          ),
        );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _searchSlideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      if (offset > 150 && !_showAppBarTitle) {
        setState(() => _showAppBarTitle = true);
      } else if (offset <= 150 && _showAppBarTitle) {
        setState(() => _showAppBarTitle = false);
      }
      if (offset > 100) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    });
  }

  void _startFeaturedAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && videos.isNotEmpty && !_isSearching) {
        final int nextIndex =
            ((_currentFeaturedIndex + 1) % math.min(videos.length, 5)).toInt();
        _featuredPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
        _startFeaturedAutoScroll();
      }
    });
  }

  // ✅ إصلاح دالة البحث - إيقاف الفيديو عند البحث
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    // ✅ إيقاف الفيديو المُشغل عند البحث
    if (_playingVideo != null) {
      setState(() {
        _playingVideo = null;
      });
      _disposePlayer();
    }
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        filteredVideos = List.from(videos);
        _isSearching = false;
      } else {
        _isSearching = true;
        filteredVideos = videos
            .where(
              (video) =>
                  video.title.toLowerCase().contains(query) ||
                  video.description.toLowerCase().contains(query),
            )
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _fabAnimationController.dispose();
    _searchAnimationController.dispose();
    _scrollController.dispose();
    _featuredPageController.dispose();
    _searchController.dispose();
    _disposePlayer();
    super.dispose();
  }

  void _disposePlayer() {
    if (_chewieController != null) {
      _chewieController!.dispose();
      _chewieController = null;
    }
    if (_videoController != null) {
      _videoController!.dispose();
      _videoController = null;
    }
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _loadVideos() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://gist.githubusercontent.com/MahmoudBarakat15/3b6ae308804de1e552bedfa7ae9699fd/raw/gistfile1.txt',
        ),
      );
      if (response.statusCode == 200) {
        // ✅ هذا السطر صحيح تماماً ولا يحتوي على خطأ
        final dynamic responseData = jsonDecode(response.body);
        final List<dynamic> videoList = responseData['videos'] ?? [];
        setState(() {
          videos = videoList.map((json) => VideoItem.fromJson(json)).toList();
          filteredVideos = List.from(videos);
          _localFiles = List.filled(
            videos.length,
            null,
          ); // ✅ تهيئة قائمة الملفات المحلية
          isLoading = false;
          hasError = false;
        });
        await _loadLocalFilePaths();
        _mainAnimationController.forward();
      } else {
        throw Exception('Failed to load: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  // ✅ تحميل الفيديو (نفس طريقة ReelsPage بالضبط)
  Future<void> _downloadVideo(VideoItem video) async {
    if (!mounted) return;
    // العثور على فهرس الفيديو
    final videoIndex = videos.indexWhere((v) => v.url == video.url);
    if (videoIndex == -1) return;
    // التحقق من الصلاحيات أولاً
    if (Platform.isAndroid) {
      if (await Permission.videos.isDenied &&
          await Permission.storage.isDenied) {
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
      final url = video.url;
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('فشل في تحميل الفيديو: ${response.statusCode}');
      }
      // الحصول على مجلد التنزيلات
      final downloadDir = await _getDownloadDirectory();
      // إنشاء اسم الملف
      String videoTitle = video.title.isEmpty ? 'مقطع بدون عنوان' : video.title;
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
        _localFiles[videoIndex] = file.path;
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
    } catch (e) {
      debugPrint("خطأ في تحميل الفيديو: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ فشل التحميل: $e")));
    }
  }

  void _showSuccessSnackBar(String filePath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("✅ تم حفظ المقطع بنجاح"),
            Text(
              "📁 المسار: $filePath",
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("❌ $message"),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'download_channel',
      'تحميل الفيديوهات',
      channelDescription: 'إشعارات التحميل',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  // ✅ إزالة _openDownloadedFileSafe - غير مطلوبة مثل ReelsPage
  void _playVideo(VideoItem video) async {
    if (_playingVideo == video) {
      setState(() {
        _playingVideo = null;
      });
      _disposePlayer();
      return;
    }
    setState(() {
      _playingVideo = video;
    });
    _disposePlayer();
    // ✅ التحقق من وجود ملف محلي أولاً
    final videoIndex = videos.indexWhere((v) => v.url == video.url);
    String videoUrl = video.url;
    if (videoIndex != -1 && _isVideoDownloaded(videoIndex)) {
      // استخدام الملف المحلي
      _videoController = VideoPlayerController.file(
        File(_localFiles[videoIndex]!),
      );
    } else {
      // استخدام الرابط من الإنترنت
      _videoController = VideoPlayerController.networkUrl(Uri.parse(video.url));
    }
    await _videoController!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      allowFullScreen: false,
      allowMuting: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFF6366F1),
        handleColor: const Color(0xFF8B5CF6),
        backgroundColor: Colors.white24,
        bufferedColor: Colors.white38,
      ),
      placeholder: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                video.title,
                style: GoogleFonts.cairo(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              const CircularProgressIndicator(
                color: Color(0xFF6366F1),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
    setState(() {});
  }

  // ✅ إصلاح دالة إيقاف البحث
  void _toggleSearch() {
    setState(() {
      if (_isSearching) {
        _searchController.clear();
        _isSearching = false;
        filteredVideos = List.from(videos);
        _searchAnimationController.reverse();
        // ✅ إيقاف الفيديو عند إغلاق البحث أيضاً
        if (_playingVideo != null) {
          _playingVideo = null;
          _disposePlayer();
        }
      } else {
        _isSearching = true;
        _searchAnimationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_playingVideo != null) {
          setState(() {
            _playingVideo = null;
          });
          _disposePlayer();
          return false;
        }
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: _buildPremiumAppBar(),
        body: Stack(
          children: [
            if (_playingVideo == null) ...[
              _buildBody(),
            ] else ...[
              _buildInPagePlayer(),
            ],
          ],
        ),
        floatingActionButton: _playingVideo == null
            ? _buildFloatingActionButton()
            : null,
      ),
    );
  }

  PreferredSizeWidget _buildPremiumAppBar() {
    return AppBar(
      backgroundColor: _showAppBarTitle
          ? const Color(0xFF0A0A0A).withOpacity(0.95)
          : Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: _showAppBarTitle
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0A0A0A).withOpacity(0.95),
                    const Color(0xFF1A1A2E).withOpacity(0.95),
                  ],
                ),
              ),
            )
          : null,
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 400),
        child: Text(
          "المرئيات",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      centerTitle: true,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: IconButton(
          icon: Icon(
            _playingVideo != null
                ? Icons.close_rounded
                : Icons.arrow_back_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            if (_playingVideo != null) {
              setState(() {
                _playingVideo = null;
              });
              _disposePlayer();
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
      ),
      actions: [
        if (_playingVideo == null)
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: IconButton(
              icon: Icon(
                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                color: Colors.white,
              ),
              onPressed: _toggleSearch,
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutCubic,
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.keyboard_arrow_up_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) return _buildLoadingState();
    if (hasError) return _buildErrorState();
    return Stack(
      children: [
        _buildGradientBackground(),
        RefreshIndicator(
          color: const Color(0xFF6366F1),
          backgroundColor: const Color(0xFF1A1A2E),
          onRefresh: () async {
            setState(() => isLoading = true);
            await _loadVideos();
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildSearchBar()),
              if (!_isSearching) ...[
                SliverToBoxAdapter(child: _buildFeaturedSection()),
                SliverToBoxAdapter(child: _buildSectionHeader()),
              ],
              _buildVideoGrid(),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 2.0,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
            Color(0xFF0F3460),
            Color(0xFF0A0A0A),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedBuilder(
      animation: _searchAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _searchSlideAnimation.value * 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: _isSearching ? 80 : 0,
            margin: const EdgeInsets.fromLTRB(16, 100, 16, 0),
            child: _isSearching
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'البحث في المرئيات...',
                            hintStyle: GoogleFonts.cairo(color: Colors.white60),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Colors.white60,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedSection() {
    if (videos.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 320,
      margin: EdgeInsets.only(top: _isSearching ? 16 : 120),
      child: PageView.builder(
        controller: _featuredPageController,
        onPageChanged: (index) => setState(() => _currentFeaturedIndex = index),
        itemCount: math.min(videos.length, 5),
        itemBuilder: (context, index) {
          final video = videos[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildFeaturedCard(video, index),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCard(VideoItem video, int index) {
    return AnimatedBuilder(
      animation: _mainAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1).withOpacity(0.8),
                            const Color(0xFF8B5CF6).withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: video.thumbnail.isNotEmpty
                          ? Image.network(
                              video.thumbnail,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.white54,
                                      size: 50,
                                    ),
                                  ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.videocam_rounded,
                                color: Colors.white54,
                                size: 50,
                              ),
                            ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'مميز',
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                // ✅ إضافة مؤشر للفيديوهات المحملة
                                if (_isVideoDownloaded(index)) ...[
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.download_done,
                                    color: Colors.green,
                                    size: 14,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            video.title,
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          if (video.description.isNotEmpty)
                            Text(
                              video.description,
                              style: GoogleFonts.cairo(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6366F1),
                                        Color(0xFF8B5CF6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () => _playVideo(video),
                                    icon: const Icon(
                                      Icons.play_arrow_rounded,
                                      size: 20,
                                    ),
                                    label: Text(
                                      'تشغيل الآن',
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: _isVideoDownloaded(index)
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: IconButton(
                                  onPressed: () => _downloadVideo(video),
                                  icon: Icon(
                                    _isVideoDownloaded(index)
                                        ? Icons.download_done_rounded
                                        : Icons.download_rounded,
                                    color: _isVideoDownloaded(index)
                                        ? Colors.green
                                        : Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () => _playVideo(video),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 32, 16, 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _isSearching
                ? 'نتائج البحث (${filteredVideos.length})'
                : 'جميع المرئيات',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${filteredVideos.length} فيديو',
              style: GoogleFonts.cairo(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final video = filteredVideos[index];
          final videoIndex = videos.indexWhere((v) => v.url == video.url);
          return AnimatedBuilder(
            animation: _mainAnimationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - _fadeAnimation.value)),
                  child: _buildVideoCard(video, videoIndex),
                ),
              );
            },
          );
        }, childCount: filteredVideos.length),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
      ),
    );
  }

  Widget _buildVideoCard(VideoItem video, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _playVideo(video),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                gradient: video.thumbnail.isEmpty
                                    ? LinearGradient(
                                        colors: [
                                          const Color(
                                            0xFF6366F1,
                                          ).withOpacity(0.3),
                                          const Color(
                                            0xFF8B5CF6,
                                          ).withOpacity(0.3),
                                        ],
                                      )
                                    : null,
                              ),
                              child: video.thumbnail.isNotEmpty
                                  ? Image.network(
                                      video.thumbnail,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      const Color(
                                                        0xFF6366F1,
                                                      ).withOpacity(0.3),
                                                      const Color(
                                                        0xFF8B5CF6,
                                                      ).withOpacity(0.3),
                                                    ],
                                                  ),
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.white54,
                                                    size: 32,
                                                  ),
                                                ),
                                              ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.videocam_rounded,
                                        color: Colors.white54,
                                        size: 32,
                                      ),
                                    ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                            // Play Button
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF6366F1,
                                      ).withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            // Download Button (small, in corner)
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isVideoDownloaded(index)
                                      ? Colors.green.withOpacity(0.8)
                                      : Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  onPressed: () => _downloadVideo(video),
                                  icon: Icon(
                                    _isVideoDownloaded(index)
                                        ? Icons.download_done_rounded
                                        : Icons.download_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            // Duration badge
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  video.duration.isEmpty
                                      ? '--:--'
                                      : video.duration,
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            // ✅ مؤشر الحالة (محلي/إنترنت)
                            if (_isVideoDownloaded(index))
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.offline_pin,
                                        color: Colors.white,
                                        size: 10,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'محلي',
                                        style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Title only
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            video.title,
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInPagePlayer() {
    final videoIndex = videos.indexWhere((v) => v.url == _playingVideo!.url);
    final isLocalFile = videoIndex != -1 && _isVideoDownloaded(videoIndex);
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _chewieController != null
                  ? Chewie(controller: _chewieController!)
                  : const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6366F1),
                      ),
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _playingVideo!.title,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // ✅ مؤشر نوع التشغيل
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isLocalFile
                              ? Colors.green.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isLocalFile ? Icons.offline_pin : Icons.wifi,
                              color: isLocalFile ? Colors.green : Colors.blue,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isLocalFile ? 'محلي' : 'مباشر',
                              style: GoogleFonts.cairo(
                                color: isLocalFile ? Colors.green : Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_playingVideo!.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _playingVideo!.description,
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ إزالة _buildDownloadOverlay - غير مطلوب مثل ReelsPage

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0A0A0A)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'جارٍ تحميل المرئيات...',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'يرجى الانتظار قليلاً',
                    style: GoogleFonts.cairo(
                      color: Colors.white60,
                      fontSize: 14,
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

  Widget _buildErrorState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0A0A0A)],
        ),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  color: Colors.red,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'فشل في تحميل المرئيات',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'تحقق من اتصال الإنترنت وحاول مرة أخرى',
                style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      hasError = false;
                    });
                    _loadVideos();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text(
                    'إعادة المحاولة',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Video Item Model
class VideoItem {
  final String title;
  final String description;
  final String url;
  final String thumbnail;
  final String duration;

  VideoItem({
    required this.title,
    required this.description,
    required this.url,
    required this.thumbnail,
    required this.duration,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      url: json['url'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
    );
  }
}
