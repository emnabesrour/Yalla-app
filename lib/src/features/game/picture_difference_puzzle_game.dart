import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yalla_app/src/core/sounds/sound_service.dart';

import '../../shared/animated_assets.dart';

class DifferenceSpot {
  const DifferenceSpot({
    required this.x,
    required this.y,
    required this.radius,
    required this.tag,
    required this.diffEmoji,
    required this.baseEmoji,
  });

  final double x;
  final double y;
  final double radius;
  final String tag;
  final String diffEmoji;
  final String baseEmoji;
}

class DifferenceLevel {
  const DifferenceLevel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.leftImageUrl,
    required this.rightImageUrl,
    required this.spots,
  });

  final String id;
  final String title;
  final String subtitle;
  final String leftImageUrl;
  final String rightImageUrl;
  final List<DifferenceSpot> spots;
}

class _SparkEffect {
  const _SparkEffect({
    required this.id,
    required this.x,
    required this.y,
    required this.color,
    required this.glyph,
  });

  final int id;
  final double x;
  final double y;
  final Color color;
  final String glyph;
}

class PictureDifferencePuzzleWidget extends StatefulWidget {
  const PictureDifferencePuzzleWidget({super.key, required this.onComplete});

  final void Function(int score, int stars) onComplete;

  @override
  State<PictureDifferencePuzzleWidget> createState() =>
      _PictureDifferencePuzzleWidgetState();
}

class _PictureDifferencePuzzleWidgetState
    extends State<PictureDifferencePuzzleWidget> {
  static const _levelCount = 6;
  static const _secondsPerLevel = 70;
  static const _savePrefix = 'spot_diff_best_stars_';

  final _rand = Random();
  final _levels = const <DifferenceLevel>[
    DifferenceLevel(
      id: 'forest',
      title: 'المستوى 1 — الغابة',
      subtitle: 'اعثر على عناصر التلوث والنقص في الطبيعة',
      leftImageUrl:
          'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=1200&q=80',
      rightImageUrl:
          'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=1200&q=80',
      spots: [
        DifferenceSpot(
          x: .22,
          y: .28,
          radius: .085,
          tag: 'plastic',
          diffEmoji: '🧴',
          baseEmoji: '🍃',
        ),
        DifferenceSpot(
          x: .78,
          y: .4,
          radius: .08,
          tag: 'bird_missing',
          diffEmoji: '🪵',
          baseEmoji: '🐦',
        ),
        DifferenceSpot(
          x: .55,
          y: .72,
          radius: .09,
          tag: 'trash_bag',
          diffEmoji: '🛍️',
          baseEmoji: '🌱',
        ),
      ],
    ),
    DifferenceLevel(
      id: 'ocean',
      title: 'المستوى 2 — المحيط',
      subtitle: 'اكتشف البلاستيك والكائنات البحرية المتضررة',
      leftImageUrl:
          'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=1200&q=80',
      rightImageUrl:
          'https://images.unsplash.com/photo-1500375592092-40eb2168fd21?auto=format&fit=crop&w=1200&q=80',
      spots: [
        DifferenceSpot(
          x: .3,
          y: .62,
          radius: .085,
          tag: 'bottle',
          diffEmoji: '🧃',
          baseEmoji: '🐟',
        ),
        DifferenceSpot(
          x: .68,
          y: .35,
          radius: .085,
          tag: 'net',
          diffEmoji: '🪢',
          baseEmoji: '🐬',
        ),
        DifferenceSpot(
          x: .84,
          y: .72,
          radius: .08,
          tag: 'oil',
          diffEmoji: '🛢️',
          baseEmoji: '🫧',
        ),
      ],
    ),
    DifferenceLevel(
      id: 'animals',
      title: 'المستوى 3 — الحيوانات',
      subtitle: 'لاحظ التغيّرات في موطن الحيوانات',
      leftImageUrl:
          'https://images.unsplash.com/photo-1474511320723-9a56873867b5?auto=format&fit=crop&w=1200&q=80',
      rightImageUrl:
          'https://images.unsplash.com/photo-1474511320723-9a56873867b5?auto=format&fit=crop&w=1200&q=80',
      spots: [
        DifferenceSpot(
          x: .25,
          y: .7,
          radius: .09,
          tag: 'food_can',
          diffEmoji: '🥫',
          baseEmoji: '🌾',
        ),
        DifferenceSpot(
          x: .58,
          y: .3,
          radius: .08,
          tag: 'tree_cut',
          diffEmoji: '🪚',
          baseEmoji: '🌳',
        ),
        DifferenceSpot(
          x: .78,
          y: .58,
          radius: .085,
          tag: 'smoke',
          diffEmoji: '💨',
          baseEmoji: '☁️',
        ),
      ],
    ),
    DifferenceLevel(
      id: 'recycling',
      title: 'المستوى 4 — إعادة التدوير',
      subtitle: 'اعثر على الفرز الخاطئ للنفايات',
      leftImageUrl:
          'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?auto=format&fit=crop&w=1200&q=80',
      rightImageUrl:
          'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?auto=format&fit=crop&w=1200&q=80',
      spots: [
        DifferenceSpot(
          x: .2,
          y: .34,
          radius: .08,
          tag: 'wrong_bin',
          diffEmoji: '🗑️',
          baseEmoji: '♻️',
        ),
        DifferenceSpot(
          x: .52,
          y: .63,
          radius: .09,
          tag: 'plastic_mix',
          diffEmoji: '🍼',
          baseEmoji: '📦',
        ),
        DifferenceSpot(
          x: .82,
          y: .46,
          radius: .085,
          tag: 'battery',
          diffEmoji: '🔋',
          baseEmoji: '🍀',
        ),
      ],
    ),
    DifferenceLevel(
      id: 'energy',
      title: 'المستوى 5 — الطاقة',
      subtitle: 'اكتشف هدر الطاقة في المشهد',
      leftImageUrl:
          'https://images.unsplash.com/photo-1509391366360-2e959784a276?auto=format&fit=crop&w=1200&q=80',
      rightImageUrl:
          'https://images.unsplash.com/photo-1509391366360-2e959784a276?auto=format&fit=crop&w=1200&q=80',
      spots: [
        DifferenceSpot(
          x: .26,
          y: .24,
          radius: .08,
          tag: 'light_on',
          diffEmoji: '💡',
          baseEmoji: '☀️',
        ),
        DifferenceSpot(
          x: .6,
          y: .66,
          radius: .09,
          tag: 'wire',
          diffEmoji: '🔌',
          baseEmoji: '🌿',
        ),
        DifferenceSpot(
          x: .82,
          y: .34,
          radius: .085,
          tag: 'smoke',
          diffEmoji: '🏭',
          baseEmoji: '🌬️',
        ),
      ],
    ),
    DifferenceLevel(
      id: 'earth_guardian',
      title: 'المستوى 6 — حارس الأرض',
      subtitle: 'التحدي النهائي لحماية الكوكب',
      leftImageUrl:
          'https://images.unsplash.com/photo-1614730321146-b6fa6a46bcb4?auto=format&fit=crop&w=1200&q=80',
      rightImageUrl:
          'https://images.unsplash.com/photo-1614730321146-b6fa6a46bcb4?auto=format&fit=crop&w=1200&q=80',
      spots: [
        DifferenceSpot(
          x: .2,
          y: .53,
          radius: .08,
          tag: 'fire',
          diffEmoji: '🔥',
          baseEmoji: '🌧️',
        ),
        DifferenceSpot(
          x: .47,
          y: .32,
          radius: .085,
          tag: 'trash',
          diffEmoji: '🧴',
          baseEmoji: '🕊️',
        ),
        DifferenceSpot(
          x: .78,
          y: .66,
          radius: .095,
          tag: 'factory',
          diffEmoji: '🏭',
          baseEmoji: '🌍',
        ),
      ],
    ),
  ];

  int _levelIndex = 0;
  int _score = 0;
  int _stars = 0;
  int _attempts = 0;
  int _hintsUsed = 0;
  int _timeLeft = _secondsPerLevel;
  int _sparkCounter = 0;
  int _wrongPulse = 0;
  int _combo = 0;
  int _bestCombo = 0;
  int? _hintSpot;
  int? _recentCorrectSpot;
  bool _paused = false;
  bool _finished = false;
  bool _showWrongText = false;
  bool _showLevelTransition = false;
  String _feedbackText = '';
  String _transitionText = '';
  MascotMood _mascotMood = MascotMood.idle;

  Set<int> _found = <int>{};
  List<_SparkEffect> _effects = const [];

  Timer? _timer;

  DifferenceLevel get _level => _levels[_levelIndex];
  int get _maxLevel => min(_levelCount, _levels.length);
  double get _levelCleanProgress =>
      (_found.length / max(1, _level.spots.length)).clamp(0.0, 1.0);
  double get _comboMultiplier => 1 + (min(_combo, 6) * .2);

  String _restorationMessage(String levelId) {
    switch (levelId) {
      case 'forest':
        return 'الغابة تتعافى... 🍃';
      case 'ocean':
        return 'المحيط يلمع من جديد... 🐬';
      case 'animals':
        return 'الحياة البرية تعود تدريجياً... 🐾';
      case 'recycling':
        return 'المدينة تصبح أنظف... ♻️';
      case 'energy':
        return 'الطاقة الخضراء تنير المكان... 💡';
      default:
        return 'الأرض تبتسم بفضلك... 🌍';
    }
  }

  Color _sceneGlassTint() {
    switch (_level.id) {
      case 'forest':
        return const Color(0xFF86EFAC);
      case 'ocean':
        return const Color(0xFF7DD3FC);
      case 'animals':
        return const Color(0xFFFDE68A);
      case 'recycling':
        return const Color(0xFF93C5FD);
      case 'energy':
        return const Color(0xFFFCD34D);
      default:
        return const Color(0xFFC4B5FD);
    }
  }

  ({double dx, double dy, int durationMs}) _spotDriftFor(String tag) {
    if (tag.contains('smoke')) {
      return (dx: 1.5, dy: -2.0, durationMs: 2600);
    }
    if (tag.contains('bird') || tag.contains('cloud')) {
      return (dx: 2.4, dy: -0.8, durationMs: 3200);
    }
    if (tag.contains('tree') || tag.contains('leaf')) {
      return (dx: -1.4, dy: 1.6, durationMs: 3000);
    }
    return (dx: 0, dy: 0, durationMs: 0);
  }

  @override
  void initState() {
    super.initState();
    SoundService.instance.startUnderwaterAmbience();
    _startLevel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    SoundService.instance.stopUnderwaterAmbience();
    super.dispose();
  }

  void _startLevel() {
    _timer?.cancel();
    setState(() {
      _timeLeft = _secondsPerLevel;
      _found = <int>{};
      _effects = const [];
      _hintSpot = null;
      _recentCorrectSpot = null;
      _paused = false;
      _feedbackText = '';
      _showWrongText = false;
      _mascotMood = MascotMood.idle;
      _combo = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _paused || _finished) return;
      if (_timeLeft <= 1) {
        _timer?.cancel();
        _onLevelTimeout();
        return;
      }
      setState(() => _timeLeft--);
    });
  }

  void _onLevelTimeout() {
    setState(() {
      _score = max(0, _score - 10);
      _feedbackText = 'انتهى الوقت ⏳';
      _showWrongText = true;
      _mascotMood = MascotMood.calm;
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _showWrongText = false);
      _goNextLevelOrFinish();
    });
  }

  void _handleImageTap(TapDownDetails details, BoxConstraints constraints) {
    if (_paused || _finished) return;
    SoundService.instance.tapSoft();

    _attempts++;
    final local = details.localPosition;
    final w = constraints.maxWidth;
    final h = constraints.maxHeight;
    if (w <= 0 || h <= 0) return;

    final nx = (local.dx / w).clamp(0.0, 1.0);
    final ny = (local.dy / h).clamp(0.0, 1.0);

    int? matched;
    for (var i = 0; i < _level.spots.length; i++) {
      if (_found.contains(i)) continue;
      final spot = _level.spots[i];
      final dx = nx - spot.x;
      final dy = ny - spot.y;
      final interactionRadius = (spot.radius * 1.22).clamp(.07, .14);
      if (sqrt((dx * dx) + (dy * dy)) <= interactionRadius) {
        matched = i;
        break;
      }
    }

    if (matched != null) {
      _onCorrectTap(matched);
    } else {
      _onWrongTap();
    }
  }

  void _onCorrectTap(int spotIndex) {
    final spot = _level.spots[spotIndex];
    final gain = (24 * _comboMultiplier).round();
    setState(() {
      _score += gain;
      _stars++;
      _combo++;
      _bestCombo = max(_bestCombo, _combo);
      _found = <int>{..._found, spotIndex};
      _recentCorrectSpot = spotIndex;
      _mascotMood = MascotMood.happy;
      _feedbackText = _combo >= 3
          ? 'سلسلة رائعة x${_comboMultiplier.toStringAsFixed(1)}'
          : 'ممتاز! +$gain 👏';
      _showWrongText = false;
      _effects = [
        ..._effects,
        _SparkEffect(
          id: ++_sparkCounter,
          x: spot.x,
          y: spot.y,
          color: const Color(0xFFFACC15),
          glyph: '✨',
        ),
        _SparkEffect(
          id: ++_sparkCounter,
          x: (spot.x + 0.04).clamp(0.08, 0.92),
          y: (spot.y - 0.04).clamp(0.08, 0.92),
          color: const Color(0xFF67E8F9),
          glyph: '⭐',
        ),
      ];
    });
    SoundService.instance.success();
    if (_combo > 0 && _combo % 3 == 0) {
      SoundService.instance.bonus();
    }

    final firstEffectId = _sparkCounter - 1;
    final secondEffectId = _sparkCounter;
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(
        () => _effects = _effects
            .where((e) => e.id != firstEffectId && e.id != secondEffectId)
            .toList(),
      );
    });
    Future.delayed(const Duration(milliseconds: 480), () {
      if (!mounted) return;
      setState(() {
        if (_recentCorrectSpot == spotIndex) _recentCorrectSpot = null;
        if (_mascotMood == MascotMood.happy) _mascotMood = MascotMood.excited;
      });
    });

    if (_found.length >= _level.spots.length) {
      Future.delayed(const Duration(milliseconds: 520), () {
        if (!mounted) return;
        _goNextLevelOrFinish();
      });
    }
  }

  void _onWrongTap() {
    setState(() {
      _score = max(0, _score - 5);
      _combo = 0;
      _feedbackText = 'حاول مرة أخرى 🌱';
      _showWrongText = true;
      _mascotMood = MascotMood.wrong;
      _wrongPulse++;
    });
    SoundService.instance.wrong();
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() {
        _showWrongText = false;
        _mascotMood = MascotMood.idle;
      });
    });
  }

  void _useHint() {
    if (_paused || _finished) return;
    final pending = List<int>.generate(
      _level.spots.length,
      (i) => i,
    ).where((i) => !_found.contains(i)).toList();
    if (pending.isEmpty) return;

    final idx = pending[_rand.nextInt(pending.length)];
    setState(() {
      _hintSpot = idx;
      _hintsUsed++;
      _score = max(0, _score - 8);
      _mascotMood = MascotMood.calm;
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        if (_hintSpot == idx) _hintSpot = null;
        if (_mascotMood == MascotMood.calm) _mascotMood = MascotMood.idle;
      });
    });
  }

  void _pauseGame() async {
    setState(() => _paused = true);
    final action = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF172554),
          title: const Text(
            'إيقاف مؤقت',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'خُذ استراحة قصيرة ثم واصل المغامرة 🌿',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'quit'),
              child: const Text('خروج'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'resume'),
              child: const Text('متابعة'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (action == 'quit') {
      _finishAndExit(forceLowScore: true);
      return;
    }
    setState(() => _paused = false);
  }

  Future<void> _goNextLevelOrFinish() async {
    if (_levelIndex >= _maxLevel - 1) {
      await _finishAndExit();
      return;
    }
    setState(() {
      _levelIndex++;
      _feedbackText = 'ممتاز! المستوى التالي 🚀';
      _showWrongText = true;
      _showLevelTransition = true;
      _transitionText = _restorationMessage(_levels[_levelIndex - 1].id);
      _mascotMood = MascotMood.excited;
    });
    await Future.delayed(const Duration(milliseconds: 1050));
    if (!mounted) return;
    setState(() {
      _showWrongText = false;
      _showLevelTransition = false;
    });
    _startLevel();
  }

  Future<void> _finishAndExit({bool forceLowScore = false}) async {
    _finished = true;
    _timer?.cancel();

    final totalSpots = _levels
        .take(_maxLevel)
        .fold<int>(0, (sum, level) => sum + level.spots.length);
    final foundCount = (_stars).clamp(0, totalSpots);
    final accuracy = foundCount / max(1, _attempts);
    final bonus = forceLowScore
        ? 0
        : max(0, (_timeLeft ~/ 2) - (_hintsUsed * 2));
    final finalScore = max(0, _score + bonus);

    final finalStars = accuracy >= 0.75
        ? 3
        : accuracy >= 0.5
        ? 2
        : accuracy >= 0.28
        ? 1
        : 0;

    final prefs = await SharedPreferences.getInstance();
    final saveKey = '$_savePrefix${_level.id}';
    final prev = prefs.getInt(saveKey) ?? 0;
    if (finalStars > prev) {
      await prefs.setInt(saveKey, finalStars);
    }

    if (!mounted) return;
    widget.onComplete(finalScore, finalStars);
  }

  List<double> _saturationMatrix(double saturation) {
    final s = saturation.clamp(0.0, 2.0);
    const ir = 0.2126;
    const ig = 0.7152;
    const ib = 0.0722;
    final inv = 1 - s;
    final r = inv * ir;
    final g = inv * ig;
    final b = inv * ib;
    return <double>[
      r + s,
      g,
      b,
      0,
      0,
      r,
      g + s,
      b,
      0,
      0,
      r,
      g,
      b + s,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        (_levelIndex + (_found.length / _level.spots.length)) / _maxLevel;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 84, 12, 16),
      child: Stack(
        children: [
          _floatingAtmosphere(progress: _levelCleanProgress),
          Column(
            children: [
              _topHud(progress),
              const SizedBox(height: 10),
              _headerRow(),
              const SizedBox(height: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 740;
                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(child: _imageCard(isRight: false)),
                          const SizedBox(width: 10),
                          Expanded(child: _imageCard(isRight: true)),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Expanded(child: _imageCard(isRight: false)),
                        const SizedBox(height: 10),
                        Expanded(child: _imageCard(isRight: true)),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              _bottomControls(),
            ],
          ),
          Positioned(top: 138, right: 8, child: _floatingPauseButton()),
          if (_showLevelTransition) _levelTransitionOverlay(),
        ],
      ),
    );
  }

  Widget _topHud(double progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0EA5E9).withValues(alpha: .25),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${_level.title}  •  ${_levelIndex + 1}/$_maxLevel',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '⭐ $_stars',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🔥 $_combo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _timeLeft <= 10
                      ? const Color(0xFFEF4444).withValues(alpha: .28)
                      : Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'x${_comboMultiplier.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  value: (_timeLeft / _secondsPerLevel).clamp(0.0, 1.0),
                  strokeWidth: 3,
                  backgroundColor: Colors.white.withValues(alpha: .2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _timeLeft <= 10
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF38BDF8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: .2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFACC15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: .45),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: RiveMascot(mood: _mascotMood, size: 66),
            )
            .animate(key: ValueKey(_mascotMood))
            .scale(
              begin: const Offset(.7, .7),
              duration: 280.ms,
              curve: Curves.easeOutBack,
            )
            .moveY(begin: 0, end: -3, duration: 1400.ms)
            .then(delay: 200.ms)
            .moveY(begin: -3, end: 0, duration: 1400.ms),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: .24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _level.subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الفروقات المكتشفة: ${_found.length}/${_level.spots.length}  •  النقاط: $_score',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .86),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'أفضل سلسلة: $_bestCombo',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .88),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_showWrongText) ...[
                  const SizedBox(height: 4),
                  Text(
                    _feedbackText,
                    style: const TextStyle(
                      color: Color(0xFFFFF59D),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _imageCard({required bool isRight}) {
    final imageUrl = isRight ? _level.rightImageUrl : _level.leftImageUrl;
    final borderGlow = isRight
        ? const Color(0xFF38BDF8)
        : const Color(0xFFA78BFA);

    Widget content = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderGlow.withValues(alpha: .5), width: 2),
        boxShadow: [
          BoxShadow(
            color: borderGlow.withValues(alpha: .2),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onTapDown: isRight
                  ? (d) => _handleImageTap(d, constraints)
                  : null,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColorFiltered(
                    colorFilter: ColorFilter.matrix(
                      _saturationMatrix(_level.id == 'forest' ? 1.16 : 1.1),
                    ),
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 2.2,
                      child: _networkNatureImage(imageUrl),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: .06),
                            Colors.black.withValues(alpha: .09),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  if (_level.id == 'forest')
                    Positioned(
                      top: -10,
                      left: 0,
                      child:
                          Container(
                                width: 240,
                                height: 180,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(
                                        0xFFFFF4BF,
                                      ).withValues(alpha: .28),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .moveY(begin: -3, end: 8, duration: 5200.ms),
                    ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child:
                          Opacity(
                                opacity: 0.18 + (_levelCleanProgress * .16),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        const Color(
                                          0xFFBAE6FD,
                                        ).withValues(alpha: .2),
                                        Colors.transparent,
                                      ],
                                      stops: const [0, .45, 1],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .moveX(begin: -18, end: 18, duration: 4400.ms),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child:
                          Opacity(
                                opacity: .12,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: .34),
                                        Colors.transparent,
                                      ],
                                      radius: .85,
                                      center: const Alignment(-.4, -.6),
                                    ),
                                  ),
                                ),
                              )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .fade(begin: .07, end: .2, duration: 3600.ms),
                    ),
                  ),
                  ..._differenceOverlays(isRight: isRight),
                  if (isRight) ..._foundRingOverlays(),
                  if (isRight) ..._sparkOverlays(),
                ],
              ),
            );
          },
        ),
      ),
    );

    if (!isRight) return content;
    return content
        .animate(key: ValueKey(_wrongPulse))
        .shake(hz: 4.3, duration: 360.ms, offset: const Offset(8, 0));
  }

  Widget _networkNatureImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0EA5E9), Color(0xFF14532D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          alignment: Alignment.center,
          child: const Text('🌍', style: TextStyle(fontSize: 60)),
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: const Color(0xFF1E3A8A).withValues(alpha: .35),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      },
    );
  }

  List<Widget> _differenceOverlays({required bool isRight}) {
    return _level.spots.indexed.map((entry) {
      final i = entry.$1;
      final spot = entry.$2;
      final found = _found.contains(i);
      final isRecent = _recentCorrectSpot == i;
      final emoji = isRight ? spot.diffEmoji : spot.baseEmoji;
      final alpha = found ? .2 : (isRight ? .66 : .58);
      final align = Alignment((spot.x * 2) - 1, (spot.y * 2) - 1);
      final size = isRight ? 32.0 : 29.0;
      final drift = _spotDriftFor(spot.tag);
      final glassTint = _sceneGlassTint();
      final baseIcon =
          ClipOval(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 2.1, sigmaY: 2.1),
                  child: Container(
                    width: size,
                    height: size,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: glassTint.withValues(alpha: isRight ? .14 : .1),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .14),
                        width: .8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      emoji,
                      style: TextStyle(
                        fontSize: isRight ? 19 : 17,
                        color: Colors.white.withValues(alpha: alpha),
                      ),
                    ),
                  ),
                ),
              )
              .animate(key: ValueKey('spot_${i}_$isRecent'))
              .scale(
                begin: isRecent ? const Offset(.72, .72) : const Offset(1, 1),
                end: const Offset(1.04, 1.04),
                duration: 320.ms,
                curve: Curves.easeOutBack,
              )
              .then()
              .scale(
                begin: const Offset(1.04, 1.04),
                end: const Offset(1, 1),
                duration: 220.ms,
              );

      return Align(
        alignment: align,
        child: drift.durationMs > 0
            ? baseIcon.move(
                begin: Offset.zero,
                end: Offset(drift.dx, drift.dy),
                duration: drift.durationMs.ms,
              )
            : baseIcon,
      );
    }).toList();
  }

  List<Widget> _foundRingOverlays() {
    return _level.spots.indexed.where((entry) => _found.contains(entry.$1)).map(
      (entry) {
        final spot = entry.$2;
        return Align(
          alignment: Alignment((spot.x * 2) - 1, (spot.y * 2) - 1),
          child:
              Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFACC15),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFACC15).withValues(alpha: .4),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(.95, .95),
                    end: const Offset(1.08, 1.08),
                    duration: 900.ms,
                  ),
        );
      },
    ).toList();
  }

  List<Widget> _sparkOverlays() {
    return _effects.map((e) {
      return Align(
        alignment: Alignment((e.x * 2) - 1, (e.y * 2) - 1),
        child: IgnorePointer(
          child:
              Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          e.color.withValues(alpha: .5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        e.glyph,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  )
                  .animate(key: ValueKey(e.id))
                  .scale(
                    begin: const Offset(.4, .4),
                    end: const Offset(1.2, 1.2),
                    duration: 560.ms,
                  )
                  .fadeOut(duration: 560.ms)
                  .moveY(begin: 0, end: -18, duration: 560.ms),
        ),
      );
    }).toList();
  }

  Widget _bottomControls() {
    final hintLeft = max(0, 3 - _hintsUsed);
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            label: 'تلميح ($hintLeft)',
            icon: Icons.lightbulb_rounded,
            color: const Color(0xFFF59E0B),
            onTap: hintLeft > 0 ? _useHint : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionButton(
            label: 'الحقيبة',
            icon: Icons.backpack_rounded,
            color: const Color(0xFF22C55E),
            onTap: () {
              setState(() {
                _feedbackText = 'الحقيبة قيد التطوير 🎒';
                _showWrongText = true;
                _mascotMood = MascotMood.calm;
              });
              Future.delayed(const Duration(milliseconds: 900), () {
                if (!mounted) return;
                setState(() {
                  _showWrongText = false;
                  if (_mascotMood == MascotMood.calm) {
                    _mascotMood = MascotMood.idle;
                  }
                });
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionButton(
            label: 'الماسح',
            icon: Icons.document_scanner_rounded,
            color: const Color(0xFF0EA5E9),
            onTap: () {
              setState(() {
                _feedbackText = 'الماسح يساعدك على التركيز 🔎';
                _showWrongText = true;
              });
              Future.delayed(const Duration(milliseconds: 900), () {
                if (!mounted) return;
                setState(() => _showWrongText = false);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: onTap == null ? .45 : 1,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: .78)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: .35)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: .35),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _floatingPauseButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _paused ? () => setState(() => _paused = false) : _pauseGame,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: .36)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _levelTransitionOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child:
            Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: .28),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .3),
                        ),
                      ),
                      child: Text(
                        _transitionText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 220.ms)
                .scale(
                  begin: const Offset(.9, .9),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutBack,
                ),
      ),
    );
  }

  Widget _floatingAtmosphere({required double progress}) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: 18,
            top: 34,
            child:
                Opacity(
                      opacity: .16 + (progress * .12),
                      child: const Text('☁️', style: TextStyle(fontSize: 30)),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveX(begin: -6, end: 12, duration: 7600.ms),
          ),
          Positioned(
            right: 30,
            top: 84,
            child:
                Opacity(
                      opacity: .14 + (progress * .1),
                      child: const Text('💨', style: TextStyle(fontSize: 22)),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveX(begin: -4, end: 7, duration: 3600.ms),
          ),
          Positioned(
            right: 38,
            top: 114,
            child:
                Opacity(
                      opacity: .12 + (progress * .1),
                      child: const Text('🍃', style: TextStyle(fontSize: 18)),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: -2, end: 4, duration: 3000.ms)
                    .moveX(begin: 0, end: -5, duration: 3000.ms),
          ),
          Positioned(
            left: 26,
            bottom: 106,
            child:
                Opacity(
                      opacity: .34,
                      child: const Text('🫧', style: TextStyle(fontSize: 16)),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: 2, end: -6, duration: 3400.ms),
          ),
          Positioned(
            right: 46,
            bottom: 74,
            child:
                Opacity(
                      opacity: .26 + (progress * .2),
                      child: const Text('🦋', style: TextStyle(fontSize: 17)),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: 0, end: -5, duration: 3200.ms),
          ),
          Positioned(
            left: 52,
            bottom: 180,
            child:
                Opacity(
                      opacity: .2 + (progress * .16),
                      child: const Text('✨', style: TextStyle(fontSize: 14)),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(begin: .22, end: .58, duration: 2200.ms)
                    .moveY(begin: 3, end: -4, duration: 2200.ms),
          ),
        ],
      ),
    );
  }
}
