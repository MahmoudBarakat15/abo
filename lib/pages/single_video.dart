import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SingleVideoPage extends StatefulWidget {
  const SingleVideoPage({super.key});

  @override
  State<SingleVideoPage> createState() => _SingleVideoPageState();
}

class _SingleVideoPageState extends State<SingleVideoPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;

  final String jsonUrl =
      "https://gist.githubusercontent.com/MahmoudBarakat15/986d31186051fb1f3249024d48fe2d64/raw/single_video";

  late List<Map<String, dynamic>> _videos;
  late List<Map<String, dynamic>> _categories;
  String _selectedCategory = "الكل";
  List<Map<String, dynamic>> _filteredVideos = [];
  bool _isLoading = true;
  String _errorMessage = '';

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

  void _showVideoPlayer(String url, String title, String description) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _VideoPlayerDialog(url: url, title: title, description: description),
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
                color: isSelected
                    ? Colors
                          .blue // في حالة التحديد
                    : Theme.of(context).brightness == Brightness.dark
                    ? Colors
                          .white // الوضع الليلي
                    : Colors.black, // الوضع النهاري (أغمق من black87)
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: () => _showVideoPlayer(
          video["url"]!,
          video["title"]!,
          video["description"]!,
        ),
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
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      video["description"]!,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() =>
      const Center(child: CircularProgressIndicator());

  Widget _buildErrorWidget() => Center(
    child: Text(_errorMessage, style: GoogleFonts.cairo(color: Colors.white)),
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎬 المكتبة المرئية"),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
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
                          return _buildVideoCard(_filteredVideos[index], index);
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

class _VideoPlayerDialog extends StatefulWidget {
  final String url;
  final String title;
  final String description;
  const _VideoPlayerDialog({
    required this.url,
    required this.title,
    required this.description,
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
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoController,
            autoPlay: true,
            looping: false,
          );
          _isLoading = false;
        });
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
