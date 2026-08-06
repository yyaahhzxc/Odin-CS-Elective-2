import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// FullWidthTrackShape ensures the Slider track spans 100% of the parent width
/// so that the active progress line starts and ends with zero inset margin,
/// perfectly aligning with the Album Art and Text margins.
class FullWidthTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 3.0;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

/// NowPlayingScreen replicates the static layout and color palette of the
/// Spotify "Now Playing" screen from assigned image 2.png with perfect
/// vertical alignment on left/right sides and the lyrics card overlapping
/// flush to the bottom screen edge.
class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  // Playback & Toggle States
  bool _isPlaying = true;
  bool _isLiked = false;
  bool _isAdded = false;
  bool _isShuffle = false;
  int _repeatState = 0; // 0: off, 1: repeat all, 2: repeat one
  bool _isLyricsExpanded = false;

  // Interactive Song Duration States (in seconds)
  double _currentSeconds = 79.0; // Starts at 1:19
  final double _totalSeconds = 178.0; // Total duration 2:58

  // Helper formatting: seconds -> M:SS
  String _formatDuration(double seconds) {
    final int totalSec = seconds.clamp(0.0, _totalSeconds).toInt();
    final int minutes = totalSec ~/ 60;
    final int secs = totalSec % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  // Helper formatting: remaining seconds -> -M:SS
  String _formatRemaining(double seconds) {
    final double rem = (_totalSeconds - seconds).clamp(0.0, _totalSeconds);
    final int totalSec = rem.toInt();
    final int minutes = totalSec ~/ 60;
    final int secs = totalSec % 60;
    return '-$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    const double sideMargin = 24.0;

    return Scaffold(
      body: Container(
        // Dark warm brown gradient background matching 2.png palette
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.gradientTop, AppColors.gradientBottom],
          ),
        ),
        child: SafeArea(
          bottom: false, // Allows Lyrics card to extend flush to bottom screen edge
          child: Column(
            children: [
              // 1. Top Drag Handle Header (Clickable Chevron)
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Minimize Player'),
                      duration: Duration(milliseconds: 800),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.only(top: 6.0, bottom: 2.0),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textWhite,
                    size: 32,
                  ),
                ),
              ),

              // 2. Main Body Content Area bounded strictly by sideMargin (24.0)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: sideMargin),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Album Artwork Container
                      const Flexible(
                        flex: 6,
                        child: Center(child: AlbumArtWidget()),
                      ),

                      const SizedBox(height: 12),

                      // Track Info Header
                      TrackInfoHeader(
                        isAdded: _isAdded,
                        isLiked: _isLiked,
                        onToggleAdd: () => setState(() => _isAdded = !_isAdded),
                        onToggleLike: () => setState(() => _isLiked = !_isLiked),
                      ),

                      const SizedBox(height: 10),

                      // Playback Progress Bar
                      PlaybackProgressBar(
                        currentSeconds: _currentSeconds,
                        totalSeconds: _totalSeconds,
                        formattedCurrent: _formatDuration(_currentSeconds),
                        formattedRemaining: _formatRemaining(_currentSeconds),
                        onChanged: (double val) {
                          setState(() {
                            _currentSeconds = val;
                          });
                        },
                      ),

                      const SizedBox(height: 6),

                      // Playback Controls
                      PlaybackControls(
                        isPlaying: _isPlaying,
                        isShuffle: _isShuffle,
                        repeatState: _repeatState,
                        onTogglePlay: () =>
                            setState(() => _isPlaying = !_isPlaying),
                        onToggleShuffle: () =>
                            setState(() => _isShuffle = !_isShuffle),
                        onToggleRepeat: () {
                          setState(() {
                            _repeatState = (_repeatState + 1) % 3;
                          });
                        },
                        onPrevious: () {
                          setState(() {
                            _currentSeconds = 0.0;
                          });
                        },
                        onNext: () {
                          setState(() {
                            _currentSeconds = 0.0;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      // Device & Playlist Footer
                      const DeviceAndPlaylistFooter(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 3. Lyrics Bottom Card (Top corners rounded, overlapping flush to bottom edge)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: sideMargin),
                child: LyricsBottomCard(
                  isExpanded: _isLyricsExpanded,
                  onToggleExpand: () {
                    setState(() {
                      _isLyricsExpanded = !_isLyricsExpanded;
                    });
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

/// Widget for displaying the Album Artwork aligned to parent container boundaries
class AlbumArtWidget extends StatelessWidget {
  const AlbumArtWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Album: SAWAYAMA by Rina Sawayama'),
            duration: Duration(milliseconds: 1000),
          ),
        );
      },
      child: Container(
        constraints: const BoxConstraints(maxHeight: 340, maxWidth: 340),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Image.asset(
              'assets/images/artwork-1.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'artwork-1.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF4A3525),
                      child: const Icon(
                        Icons.music_note,
                        size: 80,
                        color: AppColors.textWhite,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Track Header with exact left alignment for Title/Artist and right alignment for Actions
class TrackInfoHeader extends StatelessWidget {
  final bool isAdded;
  final bool isLiked;
  final VoidCallback onToggleAdd;
  final VoidCallback onToggleLike;

  const TrackInfoHeader({
    super.key,
    required this.isAdded,
    required this.isLiked,
    required this.onToggleAdd,
    required this.onToggleLike,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column aligned flush to container left margin
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Akasaka Sad',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 3),
              Text(
                'Rina Sawayama',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Action Icons (Add & Heart) aligned flush right
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
              onPressed: onToggleAdd,
              icon: Icon(
                isAdded ? Icons.check_circle : Icons.add_circle_outline,
                color: isAdded ? AppColors.spotifyGreen : AppColors.textWhite,
                size: 26,
              ),
            ),
            const SizedBox(width: 18),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
              onPressed: onToggleLike,
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? AppColors.spotifyGreen : AppColors.textWhite,
                size: 26,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Playback Progress Bar with full-width track shape and flush timestamps
class PlaybackProgressBar extends StatelessWidget {
  final double currentSeconds;
  final double totalSeconds;
  final String formattedCurrent;
  final String formattedRemaining;
  final ValueChanged<double> onChanged;

  const PlaybackProgressBar({
    super.key,
    required this.currentSeconds,
    required this.totalSeconds,
    required this.formattedCurrent,
    required this.formattedRemaining,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Custom SliderTheme with FullWidthTrackShape to start and end track flush at margins
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3.0,
            activeTrackColor: AppColors.textWhite,
            inactiveTrackColor: const Color(0x33FFFFFF),
            thumbColor: AppColors.textWhite,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
            overlayColor: const Color(0x1FFFFFFF),
            trackShape: FullWidthTrackShape(), // Spans 100% parent width flush
          ),
          child: Slider(
            value: currentSeconds.clamp(0.0, totalSeconds),
            min: 0.0,
            max: totalSeconds,
            onChanged: onChanged,
          ),
        ),

        const SizedBox(height: 2),

        // Timestamps Row with strict 0px horizontal inset (flush left & right)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formattedCurrent,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              formattedRemaining,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Playback Controls Row with exact outer icon alignment (Shuffle flush left, Repeat flush right)
class PlaybackControls extends StatelessWidget {
  final bool isPlaying;
  final bool isShuffle;
  final int repeatState;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleShuffle;
  final VoidCallback onToggleRepeat;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const PlaybackControls({
    super.key,
    required this.isPlaying,
    required this.isShuffle,
    required this.repeatState,
    required this.onTogglePlay,
    required this.onToggleShuffle,
    required this.onToggleRepeat,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    IconData repeatIcon = Icons.repeat;
    Color repeatColor = AppColors.textWhite;
    if (repeatState == 1) {
      repeatColor = AppColors.spotifyGreen;
    } else if (repeatState == 2) {
      repeatIcon = Icons.repeat_one;
      repeatColor = AppColors.spotifyGreen;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Shuffle Button (Zero padding, aligned flush left)
        IconButton(
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
          constraints: const BoxConstraints(),
          splashRadius: 22,
          onPressed: onToggleShuffle,
          icon: Icon(
            Icons.shuffle,
            color: isShuffle ? AppColors.spotifyGreen : AppColors.textWhite,
            size: 24,
          ),
        ),

        // Previous Track Button
        IconButton(
          splashRadius: 28,
          onPressed: onPrevious,
          icon: const Icon(
            Icons.skip_previous,
            color: AppColors.textWhite,
            size: 40,
          ),
        ),

        // Main Play/Pause Circular Button
        GestureDetector(
          onTap: onTogglePlay,
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.textWhite,
            ),
            child: Center(
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.black,
                size: 36,
              ),
            ),
          ),
        ),

        // Next Track Button
        IconButton(
          splashRadius: 28,
          onPressed: onNext,
          icon: const Icon(
            Icons.skip_next,
            color: AppColors.textWhite,
            size: 40,
          ),
        ),

        // Repeat Button (Zero padding, aligned flush right)
        IconButton(
          padding: EdgeInsets.zero,
          alignment: Alignment.centerRight,
          constraints: const BoxConstraints(),
          splashRadius: 22,
          onPressed: onToggleRepeat,
          icon: Icon(
            repeatIcon,
            color: repeatColor,
            size: 24,
          ),
        ),
      ],
    );
  }
}

/// Device Output Indicator & Playlist Footer with strict alignment
class DeviceAndPlaylistFooter extends StatelessWidget {
  const DeviceAndPlaylistFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Connected Device Row (Airpods Max in Spotify Green, flush left)
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connected to Airpods Max'),
                duration: Duration(milliseconds: 800),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.bluetooth, color: AppColors.spotifyGreen, size: 16),
              SizedBox(width: 6),
              Text(
                'Airpods Max',
                style: TextStyle(
                  color: AppColors.spotifyGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Playlist name & Secondary Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Queue / Playlist Name Button (Flush left)
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Playlist: SAWAYAMA'),
                    duration: Duration(milliseconds: 800),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.queue_music, color: AppColors.textWhite, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'SAWAYAMA',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Sleep Timer & Share Icons (Flush right)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 18,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sleep Timer set'),
                        duration: Duration(milliseconds: 800),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.bedtime_outlined,
                    color: AppColors.textWhite,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 18),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 18,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share song'),
                        duration: Duration(milliseconds: 800),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.ios_share,
                    color: AppColors.textWhite,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Lyrics Bottom Sheet Card overlapping flush to the bottom screen edge
class LyricsBottomCard extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const LyricsBottomCard({
    super.key,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      height: isExpanded ? 320.0 : 56.0,
      decoration: const BoxDecoration(
        color: AppColors.lyricsCardBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 10.0,
        bottom: 6.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lyrics',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: onToggleExpand,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.iconButtonBg,
                  ),
                  child: Icon(
                    isExpanded ? Icons.close : Icons.open_in_full,
                    color: AppColors.textWhite,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),

          if (isExpanded)
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: SingleChildScrollView(
                  child: Text(
                    "You built a world where I could play the part\n"
                    "Of someone whole and never feel the dark\n"
                    "Akasaka Sad, we built a dynasty...",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),

          // Bottom Home Bar Indicator (iOS style bar sitting at the bottom of the card)
          Container(
            width: 134,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}
