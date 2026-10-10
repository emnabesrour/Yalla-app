import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../data/world_catalog.dart';
import '../settings/settings_controller.dart';
import '../../shared/kids_widgets.dart';

class ResultPage extends ConsumerStatefulWidget {
  const ResultPage({
    super.key,
    this.score = 0,
    this.stars = 3,
    this.worldId = 'forest_rescue',
    this.levelNumber = 1,
    this.dbLevelId,
  });
  final int score;
  final int stars;
  final String worldId;
  final int levelNumber;
  final int? dbLevelId;

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage> {
  late ConfettiController _confetti;
  late Future<_ResultDynamicData> _dynamicDataFuture;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 5));
    _dynamicDataFuture = _loadDynamicData();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && widget.stars >= 2) _confetti.play();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  String get _mascotEmoji {
    if (widget.stars == 3) return '🥳';
    if (widget.stars == 2) return '😊';
    if (widget.stars == 1) return '😅';
    return '😢';
  }

  bool get _hasNextLevel =>
      widget.levelNumber < worldById(widget.worldId).totalLevels;
  bool get _shouldRetry => widget.stars <= 0;

  Future<_ResultDynamicData> _loadDynamicData() async {
    final repository = ref.read(gameRepositoryProvider);
    final profile = await repository.getProfile();
    final worldProgress = await repository.getWorldProgress();
    final dbWorldId = _dbWorldIdForResult();
    final levels = await repository.getLevelsByWorld(dbWorldId);
    LevelModel? levelModel;
    if (widget.dbLevelId != null) {
      for (final level in levels) {
        if (level.id == widget.dbLevelId) {
          levelModel = level;
          break;
        }
      }
    } else if (levels.isNotEmpty) {
      levelModel = levels[(widget.levelNumber - 1).clamp(0, levels.length - 1)];
    }
    final totalWorlds = worldProgress.length;
    final completedWorlds = worldProgress
        .where((w) => w.totalLevels > 0 && w.completedLevels >= w.totalLevels)
        .length;
    WorldProgress? currentWorldProgress;
    for (final world in worldProgress) {
      if (world.worldId == dbWorldId) {
        currentWorldProgress = world;
        break;
      }
    }
    final isCurrentWorldCompleted = currentWorldProgress != null &&
        currentWorldProgress.totalLevels > 0 &&
        currentWorldProgress.completedLevels >= currentWorldProgress.totalLevels;

    return _ResultDynamicData(
      totalStars: profile.totalStars,
      badges: profile.badges,
      levelStars: levelModel?.stars ?? widget.stars,
      completedWorlds: completedWorlds,
      totalWorlds: totalWorlds,
      isCurrentWorldCompleted: isCurrentWorldCompleted,
    );
  }

  String _dbWorldIdForResult() {
    final world = worldById(widget.worldId);
    switch (world.questionWorldId) {
      case 'forest':
        return 'colors';
      case 'animals':
        return 'animals';
      case 'ocean':
        return 'numbers';
      case 'energy':
      case 'earth':
        return 'memory';
      default:
        return 'colors';
    }
  }

  Future<void> _showGuestNextLevelDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('أنت تلعب كضيف'),
          content: const Text(
            'للتقدّم إلى المستوى التالي وحفظ إنجازاتك، سجّل الدخول أو أنشئ حساباً جديداً.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                this.context.go(AppRoutes.register);
              },
              child: const Text('إنشاء حساب'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                this.context.go(AppRoutes.authLogin);
              },
              child: const Text('تسجيل الدخول'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGuestMode = ref.watch(
      settingsControllerProvider.select((settings) => settings.guestMode),
    );
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1A0533),
                  Color(0xFF2D1B69),
                  Color(0xFF0369A1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Star field
          ..._buildStars(context),

          SafeArea(
            child: FutureBuilder<_ResultDynamicData>(
              future: _dynamicDataFuture,
              builder: (context, snapshot) {
                final dynamicData = snapshot.data;
                final earnedBadgeName = _earnedBadgeName(dynamicData);
                final contextualMessage = _buildContextualMessage(dynamicData);
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    const SizedBox(height: 20),

                    // Mascot
                    Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF7C3AED,
                                ).withValues(alpha: .6),
                                blurRadius: 28,
                                spreadRadius: 6,
                              ),
                            ],
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Center(
                            child: Text(
                              _mascotEmoji,
                              style: const TextStyle(fontSize: 66),
                            ),
                          ),
                        )
                        .animate()
                        .scale(
                          begin: const Offset(.3, .3),
                          duration: 700.ms,
                          curve: Curves.easeOutBack,
                        )
                        .fadeIn(duration: 500.ms),

                    const SizedBox(height: 24),

                    Text(
                          contextualMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.35,
                            shadows: [
                              Shadow(color: Colors.black26, blurRadius: 6),
                            ],
                          ),
                        )
                        .animate(delay: 300.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: .2, end: 0),

                    const SizedBox(height: 28),

                    // Stars
                    Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .14),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .3),
                            ),
                          ),
                          child: Column(
                            children: [
                              StarRow(count: widget.stars, size: 52),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '⭐',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${widget.score} نقطة',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '⭐ مجموعك الآن: ${dynamicData?.totalStars ?? '...'}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: .85),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate(delay: 500.ms)
                        .fadeIn(duration: 400.ms)
                        .scale(
                          begin: const Offset(.8, .8),
                          curve: Curves.easeOutBack,
                        ),

                    const SizedBox(height: 32),

                    // Badges earned
                    if (widget.stars == 3) ...[
                      Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFF59E0B,
                                  ).withValues(alpha: .4),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🏆', style: TextStyle(fontSize: 32)),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'شارة جديدة!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      earnedBadgeName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                          .animate(delay: 700.ms)
                          .fadeIn(duration: 400.ms)
                          .scale(
                            begin: const Offset(.8, .8),
                            curve: Curves.easeOutBack,
                          ),
                      const SizedBox(height: 20),
                    ],

                    // Action buttons
                    Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.go(AppRoutes.worlds),
                                child: Container(
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: .18),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: .4),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '🗺️ العوالم',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  if (_shouldRetry) {
                                    context.go(
                                      '${AppRoutes.game}?world=${widget.worldId}&level=${widget.levelNumber}',
                                    );
                                  } else if (_hasNextLevel) {
                                    if (isGuestMode) {
                                      await _showGuestNextLevelDialog();
                                      return;
                                    }
                                    final nextLevel = widget.levelNumber + 1;
                                    context.go(
                                      '${AppRoutes.game}?world=${widget.worldId}&level=$nextLevel',
                                    );
                                  } else {
                                    context.go(
                                      '${AppRoutes.levels}?world=${widget.worldId}',
                                    );
                                  }
                                },
                                child: Container(
                                  height: 58,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1DB954),
                                        Color(0xFF0A7A3A),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF1DB954,
                                        ).withValues(alpha: .4),
                                        blurRadius: 14,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      _shouldRetry
                                          ? '🔁 إعادة المحاولة'
                                          : '▶ التالي',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                        .animate(delay: 800.ms)
                        .fadeIn(duration: 350.ms)
                        .slideY(begin: .15, end: 0),

                    const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 40,
              maxBlastForce: 25,
              gravity: 0.25,
              colors: const [
                Color(0xFF1DB954),
                Color(0xFFFBBF24),
                Color(0xFF8B5CF6),
                Color(0xFF0EA5E9),
                Color(0xFFF97316),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _earnedBadgeName(_ResultDynamicData? data) {
    if (data == null) return 'إنجاز جديد ✨';
    if (data.levelStars >= 3) return 'نجم المستوى ${widget.levelNumber} 🌟';
    if (data.badges >= 1) return 'لديك ${data.badges} شارات 🏅';
    return 'مغامر متطور 🚀';
  }

  String _buildContextualMessage(_ResultDynamicData? data) {
    if (data == null) {
      if (widget.stars == 3) return 'رائع جداً! 🌟\nأنت بطل البيئة الحقيقي!';
      if (widget.stars == 2) return 'عمل رائع! 😊\nواصل التحسّن!';
      if (widget.stars == 1) return 'أحسنت! 👍\nمرّة أخرى وستكون أفضل!';
      return 'حاول مرة أخرى 💪\nأنت قادر على ذلك!';
    }

    if (widget.stars <= 0) {
      return 'لا بأس 💪\nجرّب مرة أخرى لتحسين نتيجتك!';
    }

    if (data.isCurrentWorldCompleted) {
      if (data.completedWorlds >= data.totalWorlds && data.totalWorlds > 0) {
        return 'مذهل! 👑\nأنهيت كل العوالم وأصبحت بطل البيئة!';
      }
      return 'إنجاز كبير! 🗺️\nأنهيت هذا العالم وفتحت تحديات جديدة!';
    }

    if (!_hasNextLevel && widget.stars >= 2) {
      return 'عمل رائع! 🌟\nأنهيت آخر مستوى في هذه الخريطة بنجاح!';
    }

    if (widget.stars == 3) {
      return 'رائع جداً! 🌟\nنتيجة كاملة! واصل بهذا الأداء!';
    }

    if (widget.stars == 2) {
      return 'عمل رائع! 😊\nاقتربت كثيراً من الدرجة الكاملة!';
    }

    return 'أحسنت! 👍\nمرّة أخرى وستكون أفضل!';
  }

  List<Widget> _buildStars(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return List.generate(15, (i) {
      final x = (i * 83.3) % w;
      final y = (i * 59.7) % h;
      return Positioned(
        left: x,
        top: y,
        child:
            Text(i % 3 == 0 ? '✨' : '⭐', style: const TextStyle(fontSize: 14))
                .animate(
                  delay: (i * 80).ms,
                  onPlay: (c) => c.repeat(reverse: true),
                )
                .fade(begin: .1, end: .5, duration: 1800.ms),
      );
    });
  }
}

class _ResultDynamicData {
  const _ResultDynamicData({
    required this.totalStars,
    required this.badges,
    required this.levelStars,
    required this.completedWorlds,
    required this.totalWorlds,
    required this.isCurrentWorldCompleted,
  });

  final int totalStars;
  final int badges;
  final int levelStars;
  final int completedWorlds;
  final int totalWorlds;
  final bool isCurrentWorldCompleted;
}
