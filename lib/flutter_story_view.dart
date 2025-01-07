import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'widgets/story_indicator.dart';

class FlutterStoryView extends StatefulWidget {
  final List<dynamic> images;
  final Function(int)? onPageChanged;
  final VoidCallback? onComplete;
  final double indicatorHeight;
  final Color? indicatorColor;
  final Color? indicatorValueColor;
  final EdgeInsets? indicatorPadding;
  final ValueChanged<int>? onStoryIndexChanged;

  const FlutterStoryView({
    super.key,
    required this.images,
    this.onPageChanged,
    this.onComplete,
    this.indicatorHeight = 2,
    this.indicatorColor,
    this.indicatorValueColor,
    this.indicatorPadding,
    this.onStoryIndexChanged,
  });

  @override
  State<FlutterStoryView> createState() => _FlutterStoryViewState();
}

class _FlutterStoryViewState extends State<FlutterStoryView>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  int _currentIndex = 0;

  final Map<int, bool> _loadedImages = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadImages();
    });
  }

  void _preloadImages() {
    for (int i = 0; i < widget.images.length; i++) {
      if (widget.images[i] is String) {
        precacheImage(
          CachedNetworkImageProvider(widget.images[i] as String),
          context,
        ).then((_) {
          setState(() {
            _loadedImages[i] = true;
          });
        });
      }
    }
  }

  void _nextStory() {
    if (_currentIndex < widget.images.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.jumpToPage(_currentIndex);
    } else {
      widget.onComplete?.call();
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.jumpToPage(_currentIndex);
    }
  }

  void _updateIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
    widget.onPageChanged?.call(index);
    widget.onStoryIndexChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTapDown: (details) {
              final screenWidth = MediaQuery.of(context).size.width;
              if (details.globalPosition.dx < screenWidth / 2) {
                _previousStory();
              } else {
                _nextStory();
              }
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: _updateIndex,
              itemBuilder: (context, index) {
                final image = widget.images[index];
                if (image is String) {
                  return SizedBox.expand(
                    child: CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      memCacheWidth: 1080,
                      memCacheHeight: 1920,
                      fadeInDuration: const Duration(milliseconds: 0),
                      fadeOutDuration: const Duration(milliseconds: 0),
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  );
                } else {
                  return SizedBox.expand(child: image);
                }
              },
            ),
          ),
          Positioned(
            top: 26,
            left: 0,
            right: 0,
            child: StoryIndicators(
              itemCount: widget.images.length,
              currentIndex: _currentIndex,
              progress: 1.0,
              indicatorColor: widget.indicatorColor,
              indicatorValueColor: widget.indicatorValueColor,
              indicatorHeight: widget.indicatorHeight,
              padding: widget.indicatorPadding,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }
}
