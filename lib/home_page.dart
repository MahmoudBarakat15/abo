import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'pages/full_bio_page.dart';
import 'pages/audio_page.dart';
import 'pages/books_page.dart';
import 'pages/reels_page.dart';
import 'pages/video_view.dart';
import 'pages/articles_page.dart';
import 'pages/fatawa_page.dart';
import 'pages/social_media_page.dart';
import 'pages/quran_page.dart';

// تعريف الألوان والثيمات
class AppTheme {
  // ألوان الثيم الفاتح
  static const Color lightPrimary = Color(0xFF1A237E);
  static const Color lightSecondary = Color(0xFF3F51B5);
  static const Color lightAccent = Color(0xFFFFD700);
  static const Color lightBackground = Color(0xFFFFFDF7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const List<Color> lightGradient = [
    Color(0xFFFFFDF7),
    Color(0xFFF8F9FA),
    Color(0xFFE3F2FD),
  ];

  // ألوان الثيم الداكن
  static const Color darkPrimary = Color(0xFF0A0E27);
  static const Color darkSecondary = Color(0xFF1A1F3A);
  static const Color darkAccent = Color(0xFFFFD700);
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF121212);
  static const List<Color> darkGradient = [
    Color(0xFF0A0E27),
    Color(0xFF1A1F3A),
    Color(0xFF2A2D47),
  ];
}

class Section {
  final String id;
  final String title;
  final String image;
  final IconData icon;
  final Color accentColor;

  const Section({
    required this.id,
    required this.title,
    required this.image,
    required this.icon,
    required this.accentColor,
  });
}

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final void Function(Widget)? onOpenPage;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    this.onOpenPage,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AudioPlayer _audioPlayer;
  late final AnimationController _floatingController;
  late final AnimationController _pulseController;
  late final Animation<double> _floatingAnimation;
  late final Animation<double> _pulseAnimation;

  bool isAudioPlaying = true;
  DateTime? lastBackPressTime;
  int currentIndex = 0;

  static const List<Section> sections = [
    Section(
      id: '1',
      title: 'السيرة والمسيرة',
      image: 'assets/22.jpg',
      icon: Icons.person_outline_rounded,
      accentColor: Color(0xFF4CAF50),
    ),
    Section(
      id: '2',
      title: 'مقاطع فيديو قصيرة',
      image: 'assets/23.png',
      icon: Icons.video_library_rounded,
      accentColor: Color(0xFFFF5722),
    ),
    Section(
      id: '3',
      title: 'الصوتيات',
      image: 'assets/24.png',
      icon: Icons.library_music_rounded,
      accentColor: Color(0xFF2196F3),
    ),
    Section(
      id: '4',
      title: 'المرئيات',
      image: 'assets/25.png',
      icon: Icons.ondemand_video_rounded,
      accentColor: Color(0xFF9C27B0),
    ),
    Section(
      id: '5',
      title: 'الكتب',
      image: 'assets/26.jpg',
      icon: Icons.menu_book_rounded,
      accentColor: Color(0xFF795548),
    ),
    Section(
      id: '6',
      title: 'المقالات',
      image: 'assets/27.png',
      icon: Icons.article_rounded,
      accentColor: Color(0xFF607D8B),
    ),
    Section(
      id: '7',
      title: 'الفتاوى',
      image: 'assets/28.png',
      icon: Icons.gavel_rounded,
      accentColor: Color(0xFF8BC34A),
    ),
    Section(
      id: '8',
      title: 'التفريغات',
      image: 'assets/29.png',
      icon: Icons.transcribe_rounded,
      accentColor: Color(0xFFFF9800),
    ),
    Section(
      id: '9',
      title: 'مواقع التواصل الاجتماعي',
      image: 'assets/30.png',
      icon: Icons.category_rounded,
      accentColor: Color(0xFF3F51B5),
    ),
    Section(
      id: '10',
      title: 'القران الكريم',
      image: 'assets/57.png',
      icon: Icons.auto_stories_rounded,
      accentColor: Color(0xFF009688),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _audioPlayer = AudioPlayer();

    // تهيئة الأنيميشن
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _floatingAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _playWelcomeAudio();
  }

  Future<void> _playWelcomeAudio() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('audio/welcome.mp3'), volume: 0.03);
      if (mounted) {
        setState(() => isAudioPlaying = true);
      }
    } catch (e) {
      debugPrint('خطأ في تشغيل الصوت الترحيبي: $e');
    }
  }

  Future<void> _stopWelcomeAudio() async {
    try {
      await _audioPlayer.stop();
      if (mounted) {
        setState(() => isAudioPlaying = false);
      }
    } catch (e) {
      debugPrint('خطأ في إيقاف الصوت: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopWelcomeAudio();
    } else if (state == AppLifecycleState.resumed) {
      _playWelcomeAudio();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent && !isAudioPlaying) {
      _playWelcomeAudio();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleSectionTap(Section section) async {
    // تأثير haptic feedback
    HapticFeedback.lightImpact();

    await _stopWelcomeAudio();

    // خريطة للصفحات لتجنب if-else الطويلة
    final pageBuilders = <String, Widget Function()>{
      'السيرة والمسيرة': () => const FullBioPage(),
      'الصوتيات': () => const AudioPage(),
      'الكتب': () => const BooksPage(),
      'مقاطع فيديو قصيرة': () => const ReelsPage(),
      'المرئيات': () => const VideoViewPage(),
      'المقالات': () => ArticlesPage(),
      'الفتاوى': () => FatawaPage(),
      'مواقع التواصل الاجتماعي': () => SocialMediaPage(),
      'القران الكريم': () => QuranPage(),
    };

    final page =
        pageBuilders[section.title.trim()]?.call() ??
        DetailScreen(section: section);

    if (mounted) {
      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );

      // إعادة تشغيل الصوت عند العودة
      if (isAudioPlaying) {
        _playWelcomeAudio();
      }
    }
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (lastBackPressTime == null ||
        now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
      lastBackPressTime = now;

      // عرض رسالة أنيقة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(Icons.exit_to_app_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'اضغط مرة أخرى للخروج من التطبيق',
                style: GoogleFonts.cairo(),
              ),
            ],
          ),
          backgroundColor: widget.isDarkMode
              ? AppTheme.darkSecondary
              : AppTheme.lightSecondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDarkMode
                ? [
                    AppTheme.darkGradient[0].withOpacity(0.9),
                    AppTheme.darkGradient[1].withOpacity(0.7),
                  ]
                : [
                    AppTheme.lightGradient[0].withOpacity(0.9),
                    AppTheme.lightGradient[1].withOpacity(0.7),
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FlexibleSpaceBar(
          centerTitle: true,
          title: AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatingAnimation.value),
                child: Text(
                  'مكتبة الشيخ الحويني',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode
                        ? AppTheme.darkAccent
                        : AppTheme.lightPrimary,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      leading: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isAudioPlaying ? _pulseAnimation.value : 1.0,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (widget.isDarkMode
                            ? AppTheme.darkAccent
                            : AppTheme.lightAccent)
                        .withOpacity(0.8),
                    (widget.isDarkMode
                        ? AppTheme.darkAccent
                        : AppTheme.lightAccent),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        (widget.isDarkMode
                                ? AppTheme.darkAccent
                                : AppTheme.lightAccent)
                            .withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: isAudioPlaying ? 2 : 0,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  isAudioPlaying
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  isAudioPlaying ? _stopWelcomeAudio() : _playWelcomeAudio();
                },
              ),
            ),
          );
        },
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (widget.isDarkMode
                        ? AppTheme.darkSecondary
                        : AppTheme.lightSecondary)
                    .withOpacity(0.8),
                (widget.isDarkMode
                    ? AppTheme.darkSecondary
                    : AppTheme.lightSecondary),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color:
                    (widget.isDarkMode
                            ? AppTheme.darkSecondary
                            : AppTheme.lightSecondary)
                        .withOpacity(0.4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onToggleTheme();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselItem(Section section, int index) {
    final isActive = index == currentIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal: isActive ? 8 : 12,
        vertical: isActive ? 8 : 16,
      ),
      child: GestureDetector(
        onTap: () => _handleSectionTap(section),
        child: Hero(
          tag: section.id,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  section.accentColor.withOpacity(0.1),
                  section.accentColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: isActive
                    ? section.accentColor.withOpacity(0.5)
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: section.accentColor.withOpacity(0.2),
                  blurRadius: isActive ? 20 : 10,
                  spreadRadius: isActive ? 2 : 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  // صورة الخلفية
                  Positioned.fill(
                    child: Image.asset(
                      section.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              section.accentColor,
                              section.accentColor.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: Icon(
                          section.icon,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // طبقة التدرج
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // أيقونة القسم
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: section.accentColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: section.accentColor.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(section.icon, color: Colors.white, size: 24),
                    ),
                  ),

                  // عنوان القسم
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            section.title,
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black.withOpacity(0.8),
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: section.accentColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'اكتشف المزيد',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: widget.isDarkMode
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: widget.isDarkMode
            ? Brightness.dark
            : Brightness.light,
        statusBarColor: Colors.transparent,
      ),
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDarkMode
                ? AppTheme.darkGradient
                : AppTheme.lightGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverFillRemaining(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: CarouselSlider.builder(
                    itemCount: sections.length,
                    options: CarouselOptions(
                      height: 380,
                      viewportFraction: 0.85,
                      enlargeCenterPage: true,
                      enlargeFactor: 0.3,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 4),
                      autoPlayAnimationDuration: const Duration(
                        milliseconds: 800,
                      ),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      scrollDirection: Axis.horizontal,
                      onPageChanged: (index, reason) {
                        setState(() => currentIndex = index);
                      },
                    ),
                    itemBuilder: (context, index, realIndex) {
                      return _buildCarouselItem(sections[index], index);
                    },
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

class DetailScreen extends StatelessWidget {
  final Section section;

  const DetailScreen({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          section.title,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.8),
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Hero(
            tag: section.id,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: section.accentColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  section.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          section.accentColor,
                          section.accentColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Icon(section.icon, size: 100, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
