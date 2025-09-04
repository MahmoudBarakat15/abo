import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _rotateController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // إعداد الأنيميشنات
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_rotateController);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // بدء الأنيميشنات
    _fadeController.forward();
    _slideController.forward();
    _rotateController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ألوان إسلامية راقية
  static const Color islamicGreen = Color(0xFF2E7D32);
  static const Color islamicGold = Color(0xFFD4AF37);
  static const Color islamicBlue = Color(0xFF1565C0);
  static const Color islamicCream = Color(0xFFFFF8E1);
  static const Color islamicDarkGreen = Color(0xFF1B4332);
  static const Color islamicBrown = Color(0xFF8D6E63);

  Widget _buildIslamicPattern() {
    return AnimatedBuilder(
      animation: _rotateAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateAnimation.value * 2 * 3.14159,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  islamicGold.withOpacity(0.1),
                  islamicGreen.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
            child: CustomPaint(painter: IslamicPatternPainter()),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Column(
            children: [
              // بسم الله الرحمن الرحيم
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      islamicGold.withOpacity(0.2),
                      islamicGreen.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: islamicGold.withOpacity(0.3)),
                ),
                child: Text(
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  style: GoogleFonts.amiriQuran(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: islamicDarkGreen,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),

              // عنوان القرآن الكريم
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [islamicGreen, islamicDarkGreen],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: islamicGreen.withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 2,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.auto_stories_rounded,
                              color: islamicGold,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '  القرآن  بصوت الشيخ ',
                            style: GoogleFonts.cairo(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuranSections() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          // أيقونة القرآن المركزية
          Container(
            margin: const EdgeInsets.symmetric(vertical: 30),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // الزخرفة الدائرية الخلفية
                _buildIslamicPattern(),

                // أيقونة القرآن
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [islamicGold, islamicGold.withOpacity(0.8)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: islamicGold.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // أقسام القرآن
          _buildQuranGrid(),
        ],
      ),
    );
  }

  Widget _buildQuranGrid() {
    final surahs = [
      {
        'title': 'سورة البقرة 1',
        'icon': Icons.play_circle_filled_rounded,
        'color': islamicGreen,
        'audioUrl':
            'https://ia601603.us.archive.org/8/items/way2allah_482/albkrah1.mp3',
      },

      {
        'title': 'سورة البقرة 2',
        'icon': Icons.play_circle_filled_rounded,
        'color': islamicBlue,
        'audioUrl':
            'https://ia801603.us.archive.org/8/items/way2allah_482/albkrah2.mp3',
      },
      {
        'title': 'سورة النساء',
        'icon': Icons.play_circle_filled_rounded,
        'color': islamicBrown,
        'audioUrl':
            'https://ia601603.us.archive.org/8/items/way2allah_482/alnesaa.mp3',
      },
      {
        'title': 'سورة التوبة',
        'icon': Icons.play_circle_filled_rounded,
        'color': islamicDarkGreen,
        'audioUrl':
            'https://ia601603.us.archive.org/8/items/way2allah_482/tawba.mp3',
      },
      {
        'title': 'سورة يونس',
        'icon': Icons.play_circle_filled_rounded,
        'color': islamicGreen,
        'audioUrl':
            'https://ia801603.us.archive.org/8/items/way2allah_482/yonos.mp3',
      },

      {
        'title': 'سورة الاسراء',
        'icon': Icons.play_circle_filled_rounded,
        'color': islamicBlue,
        'audioUrl':
            'https://ia801603.us.archive.org/8/items/way2allah_482/alesra2.mp3',
      },
      {
        'title': 'سورة مريم',
        'icon': Icons.play_circle_filled_rounded,
        'color': islamicBrown,
        'audioUrl':
            'https://ia801603.us.archive.org/8/items/way2allah_482/mariam1.mp3',
      },
      {
        'title': 'سورة النمل',
        'icon': Icons.play_circle_filled_rounded,
        'color': islamicDarkGreen,
        'audioUrl':
            'https://ia801603.us.archive.org/8/items/way2allah_482/naml.mp3',
      },
      {
        'title': 'سورة الروم',
        'icon': Icons.play_circle_filled_rounded,
        'color': islamicGreen,
        'audioUrl':
            'https://ia801603.us.archive.org/8/items/way2allah_482/4aroom.mp3',
      },

      {
        'title': 'سورة غافر',
        'icon': Icons.play_circle_filled_rounded,
        'color': islamicBlue,
        'audioUrl':
            'https://ia801603.us.archive.org/8/items/way2allah_482/ghafer.mp3',
      },
      {
        'title': 'سورة الزخرف',
        'icon': Icons.play_circle_filled_rounded,
        'color': islamicBrown,
        'audioUrl':
            'https://ia801603.us.archive.org/8/items/way2allah_482/zokhrof.mp3',
      },
      {
        'title': 'سورة ق',
        'icon': Icons.play_circle_filled_rounded,
        'color': islamicDarkGreen,
        'audioUrl':
            'https://ia801603.us.archive.org/8/items/way2allah_482/kaf.mp3',
      },
      {
        'title': 'تلاوات رائعة',
        'icon': Icons.play_circle_filled_rounded,
        'color': islamicBrown,
        'audioUrl':
            'https://ia801603.us.archive.org/8/items/way2allah_482/kesar_sowar.mp3',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return _buildSurahCard(
          title: surah['title'] as String,
          icon: surah['icon'] as IconData,
          color: surah['color'] as Color,
          audioUrl: surah['audioUrl'] as String,
          delay: Duration(milliseconds: 200 * index),
        );
      },
    );
  }

  // دالة لتحديد لون مناسب للأيقونة بناءً على لون الخلفية
  Color _getContrastColor(Color backgroundColor) {
    // حساب سطوع اللون (صيغة W3C)
    final brightness =
        (backgroundColor.red * 299 +
            backgroundColor.green * 587 +
            backgroundColor.blue * 114) /
        1000;
    return brightness > 128 ? Colors.black : Colors.white;
  }

  Widget _buildSurahCard({
    required String title,
    required IconData icon,
    required Color color,
    required String audioUrl,
    required Duration delay,
  }) {
    // تحديد لون مناسب للأيقونة بناءً على لون الخلفية
    final iconColor = _getContrastColor(color);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // التنقل لمشغل الصوت
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      QuranAudioPlayer(
                        surahTitle: title,
                        audioUrl: audioUrl,
                        surahColor: color,
                      ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
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
                  transitionDuration: const Duration(milliseconds: 600),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          color.withOpacity(0.3),
                          color.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withOpacity(0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 35, color: iconColor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'القرآن الكريم',
          style: GoogleFonts.cairo(
            color: islamicGreen,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: islamicGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: islamicGreen.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: islamicGreen),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              islamicCream,
              Colors.white,
              islamicGreen.withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildQuranSections(),
                  const SizedBox(height: 40),

                  // آية قرآنية في النهاية
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                islamicGreen.withOpacity(0.1),
                                islamicBlue.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: islamicGold.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'وَنُنَزِّلُ مِنَ الْقُرْآنِ مَا هُوَ شِفَاءٌ وَرَحْمَةٌ لِّلْمُؤْمِنِينَ',
                                style: GoogleFonts.amiriQuran(
                                  fontSize: 18,
                                  color: islamicDarkGreen,
                                  height: 2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'سورة الإسراء - آية 82',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: islamicGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// رسام الزخارف الإسلامية
class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // رسم النجمة الثمانية
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * 3.14159) / 8;
      final outerRadius = radius;
      final innerRadius = radius * 0.6;

      final outerX = center.dx + outerRadius * math.cos(angle);
      final outerY = center.dy + outerRadius * math.sin(angle);

      final innerAngle = angle + (3.14159 / 8);
      final innerX = center.dx + innerRadius * math.cos(innerAngle);
      final innerY = center.dy + innerRadius * math.sin(innerAngle);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();

    canvas.drawPath(path, paint);

    // رسم دوائر متداخلة
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * i / 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// مشغل الصوت الراقي للقرآن الكريم - class منفصل
class QuranAudioPlayer extends StatefulWidget {
  final String surahTitle;
  final String audioUrl;
  final Color surahColor;

  const QuranAudioPlayer({
    super.key,
    required this.surahTitle,
    required this.audioUrl,
    required this.surahColor,
  });

  @override
  State<QuranAudioPlayer> createState() => _QuranAudioPlayerState();
}

class _QuranAudioPlayerState extends State<QuranAudioPlayer>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  late Animation<double> _waveAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_rotateController);

    _pulseController.repeat(reverse: true);
    _rotateController.repeat();

    // إعداد مستمعي الصوت
    _setupAudioListeners();

    // بدء تحميل الصوت
    _loadAudio();
  }

  void _setupAudioListeners() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _playerState = state;
          if (state == PlayerState.playing) {
            _waveController.repeat();
          } else {
            _waveController.stop();
          }
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _playerState = PlayerState.stopped;
          _currentPosition = Duration.zero;
          _waveController.stop();
        });
      }
    });
  }

  Future<void> _loadAudio() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _audioPlayer.setSourceUrl(widget.audioUrl);
      // الحصول على المدة بعد تحميل الصوت
      final duration = await _audioPlayer.getDuration();
      if (duration != null && mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    } catch (e) {
      debugPrint('خطأ في تحميل الصوت: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'خطأ في تحميل الصوت، تحقق من الاتصال بالإنترنت',
            ),
            backgroundColor: widget.surahColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _togglePlayPause() async {
    HapticFeedback.lightImpact();

    if (_isLoading) return;

    try {
      if (_playerState == PlayerState.playing) {
        await _audioPlayer.pause();
      } else {
        if (_currentPosition >= _totalDuration) {
          await _audioPlayer.seek(Duration.zero);
        }
        await _audioPlayer.resume();
      }
    } catch (e) {
      debugPrint('خطأ في التحكم بالصوت: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('خطأ في تشغيل الصوت'),
            backgroundColor: widget.surahColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      debugPrint('خطأ في التقديم: $e');
    }
  }

  Future<void> _skip(Duration duration) async {
    final newPosition = _currentPosition + duration;
    if (newPosition <= _totalDuration && newPosition >= Duration.zero) {
      await _seekTo(newPosition);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildPlayButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _playerState == PlayerState.playing
              ? _pulseAnimation.value
              : 1.0,
          child: GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    widget.surahColor,
                    widget.surahColor.withOpacity(0.8),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.surahColor.withOpacity(0.4),
                    blurRadius: _playerState == PlayerState.playing ? 20 : 10,
                    spreadRadius: _playerState == PlayerState.playing ? 5 : 2,
                  ),
                ],
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    )
                  : Icon(
                      _playerState == PlayerState.playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveforms() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(20, (index) {
            final height = _playerState == PlayerState.playing
                ? (30 +
                      40 *
                          math.sin(
                            (_waveAnimation.value * 4 * math.pi) + index * 0.5,
                          ))
                : 20.0;

            final safeHeight = math.max(height, 5.0);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 3,
              height: safeHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.surahColor.withOpacity(0.8),
                    widget.surahColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    final progress = _totalDuration.inMilliseconds > 0
        ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
        : 0.0;

    return Column(
      children: [
        GestureDetector(
          onTapDown: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final localPosition = box.globalToLocal(details.globalPosition);
            final progress = localPosition.dx / box.size.width;
            final newPosition = Duration(
              milliseconds: (_totalDuration.inMilliseconds * progress).round(),
            );
            _seekTo(newPosition);
          },
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: widget.surahColor.withOpacity(0.2),
            ),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(widget.surahColor),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_currentPosition),
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: widget.surahColor.withOpacity(0.8),
              ),
            ),
            Text(
              _formatDuration(_totalDuration),
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: widget.surahColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(Icons.replay_10_rounded, () {
          HapticFeedback.lightImpact();
          _skip(const Duration(seconds: -10));
        }),
        _buildControlButton(Icons.skip_previous_rounded, () {
          HapticFeedback.lightImpact();
          _seekTo(Duration.zero);
        }),
        _buildPlayButton(),
        _buildControlButton(Icons.skip_next_rounded, () {
          HapticFeedback.lightImpact();
          // يمكن إضافة وظيفة السورة التالية هنا
        }),
        _buildControlButton(Icons.forward_10_rounded, () {
          HapticFeedback.lightImpact();
          _skip(const Duration(seconds: 10));
        }),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.surahColor.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.surahColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(icon, color: widget.surahColor, size: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.surahTitle,
          style: GoogleFonts.cairo(
            color: widget.surahColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.surahColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.surahColor.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: widget.surahColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.surahColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.surahColor.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: Icon(Icons.refresh_rounded, color: widget.surahColor),
              onPressed: _loadAudio,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFF8E1),
              Colors.white,
              widget.surahColor.withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // أيقونة السورة مع الزخارف
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // الزخرفة الدوارة
                    AnimatedBuilder(
                      animation: _rotateAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotateAnimation.value * 2 * math.pi,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  widget.surahColor.withOpacity(0.1),
                                  widget.surahColor.withOpacity(0.05),
                                  Colors.transparent,
                                ],
                              ),
                              border: Border.all(
                                color: widget.surahColor.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // أيقونة المصحف
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            widget.surahColor.withOpacity(0.2),
                            widget.surahColor.withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 50,
                        color: widget.surahColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // معلومات السورة
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.surahColor.withOpacity(0.1),
                        widget.surahColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.surahColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.surahTitle,
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: widget.surahColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // موجات الصوت
                Container(
                  height: 80,
                  padding: const EdgeInsets.all(20),
                  child: _buildWaveforms(),
                ),

                const SizedBox(height: 20),

                // شريط التقدم
                _buildProgressBar(),

                const SizedBox(height: 30),

                // أزرار التحكم
                _buildControlButtons(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
