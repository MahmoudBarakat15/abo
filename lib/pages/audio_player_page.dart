import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';

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
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _localFilePath;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _loadLocalPath().then((_) => _initAudio());

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() => _isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onDurationChanged.listen((d) {
      if (d != Duration.zero) {
        setState(() => _duration = d);
      }
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (p <= _duration) {
        setState(() => _position = p);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.release();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadLocalPath() async {
    final prefs = await SharedPreferences.getInstance();
    _localFilePath = prefs.getString(widget.audioUrl);
  }

  Future<void> _initAudio() async {
    if (_localFilePath != null && await File(_localFilePath!).exists()) {
      await _audioPlayer.setSourceDeviceFile(_localFilePath!);
    } else {
      await _audioPlayer.setSource(UrlSource(widget.audioUrl));
    }
  }

  Future<void> _downloadFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final appDir = Directory("${dir.path}/alhouini_library");

      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
      }

      final savePath = "${appDir.path}/${widget.audioUrl.split('/').last}";
      await Dio().download(widget.audioUrl, savePath);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(widget.audioUrl, savePath);

      setState(() => _localFilePath = savePath);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ تم تنزيل الملف بنجاح!")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ فشل التنزيل: $e")));
    }
  }

  Future<void> _playAudio() async {
    if (_localFilePath != null && await File(_localFilePath!).exists()) {
      await _audioPlayer.setSourceDeviceFile(_localFilePath!);
    } else {
      await _audioPlayer.setSource(UrlSource(widget.audioUrl));
    }
    await _audioPlayer.resume();
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
                      final newPosition = Duration(seconds: value.toInt());
                      await _audioPlayer.seek(newPosition);
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
                        onTap: () async => _isPlaying
                            ? await _audioPlayer.pause()
                            : await _playAudio(),
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
                        icon: Icons.download,
                        activeIcon: Icons.download,
                        active: false,
                        onTap: _downloadFile,
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
