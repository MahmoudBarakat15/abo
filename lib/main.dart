import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
}

class AppThemes {
  static const Color lightPrimary = Color(0xFF1A237E);
  static const Color lightSecondary = Color(0xFF3F51B5);
  static const Color lightAccent = Color(0xFFFFD700);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFFFFDF7);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1A1A1A);

  static const List<Color> lightGradientColors = [
    Color(0xFFFFFDF7),
    Color(0xFFF8F9FA),
    Color(0xFFE3F2FD),
    Color(0xFFBBDEFB),
  ];

  static const Color darkPrimary = Color(0xFF0A0E27);
  static const Color darkSecondary = Color(0xFF1A1F3A);
  static const Color darkAccent = Color(0xFFFFD700);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkOnPrimary = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFE0E0E0);

  static const List<Color> darkGradientColors = [
    Color(0xFF0A0E27),
    Color(0xFF1A1F3A),
    Color(0xFF2A2D47),
    Color(0xFF1A237E),
  ];

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: GoogleFonts.cairo().fontFamily,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: lightPrimary,
      onPrimary: lightOnPrimary,
      secondary: lightSecondary,
      onSecondary: lightOnPrimary,
      surface: lightSurface,
      onSurface: lightOnSurface,
      error: Color(0xFFD32F2F),
      onError: lightOnPrimary,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: lightPrimary,
      ),
      iconTheme: const IconThemeData(color: lightPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: lightOnPrimary,
        textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: lightPrimary.withOpacity(0.3),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 12,
      shadowColor: lightPrimary.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: lightSurface,
    ),
    textTheme: GoogleFonts.cairoTextTheme().apply(
      bodyColor: lightOnSurface,
      displayColor: lightPrimary,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.cairo().fontFamily,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: darkAccent,
      onPrimary: Color(0xFF000000),
      secondary: darkSecondary,
      onSecondary: darkOnPrimary,
      surface: darkSurface,
      onSurface: darkOnSurface,
      error: Color(0xFFCF6679),
      onError: Color(0xFF000000),
    ),
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: darkAccent,
      ),
      iconTheme: const IconThemeData(color: darkAccent),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkAccent,
        foregroundColor: Color(0xFF000000),
        textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: darkAccent.withOpacity(0.4),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 12,
      shadowColor: darkAccent.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: darkSurface,
    ),
    textTheme: GoogleFonts.cairoTextTheme().apply(
      bodyColor: darkOnSurface,
      displayColor: darkAccent,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateSystemUI();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateSystemUI();
    }
  }

  void _updateSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    _updateSystemUI();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مكتبة الشيخ أبو إسحاق الحويني',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: GlobalScaffold(isDarkMode: isDarkMode, onToggleTheme: _toggleTheme),
    );
  }
}

class GlobalScaffold extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const GlobalScaffold({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<GlobalScaffold> createState() => _GlobalScaffoldState();
}

class _GlobalScaffoldState extends State<GlobalScaffold>
    with TickerProviderStateMixin {
  int selectedIndex = 1;
  Widget? currentPage;
  late AnimationController _navAnimationController;
  late Animation<double> _navAnimation;

  @override
  void initState() {
    super.initState();
    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _navAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _navAnimationController, curve: Curves.easeInOut),
    );
    _navAnimationController.forward();
  }

  @override
  void dispose() {
    _navAnimationController.dispose();
    super.dispose();
  }

  List<Widget> get pages => [
    SupportPage(isDarkMode: widget.isDarkMode),
    HomePage(
      isDarkMode: widget.isDarkMode,
      onToggleTheme: widget.onToggleTheme,
      onOpenPage: _openPage,
    ),
    DeveloperMessagePage(isDarkMode: widget.isDarkMode),
  ];

  void _openPage(Widget page) {
    setState(() {
      currentPage = page;
    });
  }

  void _navigateToPage(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      selectedIndex = index;
      currentPage = null;
    });
    _navAnimationController.reset();
    _navAnimationController.forward();
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isDarkMode
              ? AppThemes.darkGradientColors
              : AppThemes.lightGradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    return AnimatedBuilder(
      animation: _navAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _navAnimation.value)),
          child: Opacity(
            opacity: _navAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: widget.isDarkMode
                        ? AppThemes.darkAccent.withOpacity(0.3)
                        : AppThemes.lightPrimary.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CurvedNavigationBar(
                  index: selectedIndex,
                  height: 65,
                  backgroundColor: Colors.transparent,
                  color: widget.isDarkMode
                      ? AppThemes.darkSurface.withOpacity(0.95)
                      : AppThemes.lightSurface.withOpacity(0.95),
                  buttonBackgroundColor: widget.isDarkMode
                      ? AppThemes.darkAccent
                      : AppThemes.lightPrimary,
                  animationDuration: const Duration(milliseconds: 400),
                  animationCurve: Curves.easeInOutCubic,
                  items: [
                    _buildNavItem(
                      icon: Icons.favorite_rounded,
                      label: 'ادعمنا',
                      isSelected: selectedIndex == 0,
                    ),
                    _buildNavItem(
                      icon: Icons.home_rounded,
                      label: 'الرئيسية',
                      isSelected: selectedIndex == 1,
                    ),
                    _buildNavItem(
                      icon: Icons.message_rounded,
                      label: 'رسالة المطور',
                      isSelected: selectedIndex == 2,
                    ),
                  ],
                  onTap: _navigateToPage,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final color = isSelected
        ? (widget.isDarkMode ? Colors.black : Colors.white)
        : (widget.isDarkMode ? AppThemes.darkAccent : AppThemes.lightPrimary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
          ),
          child: Icon(icon, color: color, size: isSelected ? 28 : 24),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: isSelected ? 11 : 9,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(child: _buildGradientBackground()),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 100,
              ),
              child: currentPage ?? pages[selectedIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }
}

class SupportPage extends StatelessWidget {
  final bool isDarkMode;

  const SupportPage({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'ادعمنا',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppThemes.darkAccent : AppThemes.lightPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppThemes.darkSurface.withOpacity(0.9)
                : AppThemes.lightSurface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? AppThemes.darkAccent.withOpacity(0.2)
                    : AppThemes.lightPrimary.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_rounded,
                size: 60,
                color: isDarkMode
                    ? AppThemes.darkAccent
                    : AppThemes.lightPrimary,
              ),
              const SizedBox(height: 20),
              Text(
                'ادعم المشروع',
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? AppThemes.darkAccent
                      : AppThemes.lightPrimary,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'شكراً لك على دعم مكتبة الشيخ الحويني\nدعمك يساعدنا على الاستمرار',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: isDarkMode
                      ? AppThemes.darkOnSurface
                      : AppThemes.lightOnSurface,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeveloperMessagePage extends StatelessWidget {
  final bool isDarkMode;

  const DeveloperMessagePage({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'رسالة المطور',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppThemes.darkAccent : AppThemes.lightPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppThemes.darkSurface.withOpacity(0.9)
                : AppThemes.lightSurface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? AppThemes.darkAccent.withOpacity(0.2)
                    : AppThemes.lightPrimary.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.code_rounded,
                size: 60,
                color: isDarkMode
                    ? AppThemes.darkAccent
                    : AppThemes.lightPrimary,
              ),
              const SizedBox(height: 20),
              Text(
                'رسالة من المطور',
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? AppThemes.darkAccent
                      : AppThemes.lightPrimary,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'تم تطوير هذا التطبيق بحب وشغف\nلنشر علم الشيخ الحويني حفظه الله',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: isDarkMode
                      ? AppThemes.darkOnSurface
                      : AppThemes.lightOnSurface,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
