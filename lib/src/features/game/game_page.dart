import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/services/guest_progress_session.dart';
import '../../data/services/providers.dart';
import '../../data/world_catalog.dart';
import '../settings/settings_controller.dart';
import '../../shared/animated_assets.dart';
import '../../shared/kids_widgets.dart';
import '../../shared/world_painters.dart';
import 'arrow_match_game.dart';
import 'arrow_color_game.dart';
import 'flame_recycle_game.dart';
import 'ocean_rescue_tap_game.dart';
import 'picture_difference_puzzle_game.dart';
import 'spot_difference_game.dart';

// ─── Question Model ──────────────────────────────────────────────────────

class _Question {
  const _Question({
    required this.text,
    required this.emoji,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
  final String text;
  final String emoji;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

// ─── Questions Bank ──────────────────────────────────────────────────────

final _questionsBank = {
  'forest': [
    const _Question(
      text: 'ما الذي يحتاجه الشجرة لتنمو؟',
      emoji: '🌱',
      options: [
        'المياه والشمس ☀️',
        'الهاتف 📱',
        'البلاستيك 🍼',
        'التلفزيون 📺',
      ],
      correctIndex: 0,
      explanation: 'الأشجار تحتاج الماء والشمس والتربة الجيدة لتنمو 🌱',
    ),
    const _Question(
      text: 'ماذا يفعل الغابات للهواء؟',
      emoji: '🌬️',
      options: ['تلوّثه 💨', 'تنظّفه وتُنتج أكسجين', 'لا تؤثر عليه', 'تجففه'],
      correctIndex: 1,
      explanation: 'الغابات تنقي الهواء وتعطينا الأكسجين النقي 🌿',
    ),
    const _Question(
      text: 'لماذا يجب أن لا نقطع الأشجار؟',
      emoji: '🌲',
      options: [
        'لأنها جميلة فقط',
        'تُنتج أكسجيناً وتحمي الحيوانات',
        'ليست مهمة',
        'تعيق السير',
      ],
      correctIndex: 1,
      explanation: 'الأشجار تُنتج الأكسجين وتوفر مأوى للحيوانات 🐦',
    ),
    const _Question(
      text: 'ما هو صديق الغابة الذي يُلقّح الزهور؟',
      emoji: '🦋',
      options: ['السيارة 🚗', 'الفراشة والنحل', 'الهاتف المحمول', 'الدخان'],
      correctIndex: 1,
      explanation: 'الفراشات والنحل تساعد على تلقيح الزهور 🌸',
    ),
  ],
  'ocean': [
    const _Question(
      text: 'ما الذي يُلوّث المحيطات أكثر؟',
      emoji: '🌊',
      options: [
        'البلاستيك والنفايات',
        'الأسماك 🐟',
        'الأمطار 🌧️',
        'المد والجزر',
      ],
      correctIndex: 0,
      explanation: 'البلاستيك والنفايات تضر بالحياة البحرية 🐠',
    ),
    const _Question(
      text: 'كيف نساعد السلاحف البحرية؟',
      emoji: '🐢',
      options: [
        'نُلقي البلاستيك في البحر',
        'نُنظّف الشواطئ من النفايات',
        'نصطادها',
        'نتركها',
      ],
      correctIndex: 1,
      explanation: 'نُنظّف الشواطئ لحماية السلاحف والأسماك 🐢',
    ),
    const _Question(
      text: 'ما هو أهم شيء يوفره المحيط للبشر؟',
      emoji: '💧',
      options: ['الذهب', 'الأكسجين والغذاء', 'الكهرباء فقط', 'الرياح'],
      correctIndex: 1,
      explanation: 'المحيطات توفر الأكسجين والغذاء لنصف سكان الأرض 🌊',
    ),
  ],
  'animals': [
    const _Question(
      text: 'لماذا نحمي الحيوانات المهددة بالانقراض؟',
      emoji: '🦁',
      options: [
        'لأنها جميلة فقط',
        'تحافظ على التوازن البيئي',
        'لنبيعها',
        'ليس ضرورياً',
      ],
      correctIndex: 1,
      explanation: 'كل حيوان يُوازن النظام البيئي ويُكمل الدورة الطبيعية 🌿',
    ),
    const _Question(
      text: 'ما الذي يُهدّد الباندا بالانقراض؟',
      emoji: '🐼',
      options: [
        'الأمطار',
        'قطع الغابات وفقدان الموطن',
        'البحر',
        'الطقس البارد',
      ],
      correctIndex: 1,
      explanation: 'قطع الغابات يُدمّر موطن الباندا 🌲',
    ),
  ],
  'energy': [
    const _Question(
      text: 'ما هي مصادر الطاقة النظيفة؟',
      emoji: '☀️',
      options: [
        'الفحم والبترول',
        'الشمس والرياح والماء',
        'النار والدخان',
        'الخشب فقط',
      ],
      correctIndex: 1,
      explanation: 'الشمس والرياح والماء مصادر طاقة نظيفة ومتجددة ♻️',
    ),
    const _Question(
      text: 'كيف توفّر الكهرباء في المنزل؟',
      emoji: '💡',
      options: [
        'أشعل كل الأنوار دائماً',
        'أطفئ الأنوار عند الخروج',
        'استخدم أكثر ما يمكن',
        'لا فرق',
      ],
      correctIndex: 1,
      explanation: 'إطفاء الأنوار يُوفّر الكهرباء ويُقلّل التلوث 💡',
    ),
  ],
  'earth': [
    const _Question(
      text: 'ما هو الاحترار العالمي؟',
      emoji: '🌍',
      options: [
        'ارتفاع درجات الحرارة بسبب التلوث',
        'الطقس في الصيف',
        'برودة القطب الشمالي',
        'لا شيء مهم',
      ],
      correctIndex: 0,
      explanation:
          'الاحترار العالمي يُغيّر مناخ الأرض ويُهدّد الكائنات الحية 🌡️',
    ),
    const _Question(
      text: 'كيف نُنقذ كوكب الأرض؟',
      emoji: '🌿',
      options: [
        'نحرق أكثر',
        'نزرع أشجاراً ونُقلّل التلوث',
        'نستخدم بلاستيك أكثر',
        'لا شيء',
      ],
      correctIndex: 1,
      explanation: 'زراعة الأشجار وتقليل التلوث يُنقذ كوكبنا 🌱',
    ),
  ],
};

// ─── Game Page ────────────────────────────────────────────────────────────

class GamePage extends ConsumerStatefulWidget {
  const GamePage({
    super.key,
    this.levelNumber = 1,
    this.worldId = 'forest_rescue',
    this.dbLevelId,
  });
  final int levelNumber;
  final String worldId;
  final int? dbLevelId;

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  late List<_Question> _questions;
  int _current = 0;
  int _score = 0;
  int _combo = 0;
  int _timeLeft = 20;
  Timer? _timer;
  int? _selectedIndex;
  bool _answered = false;
  MascotMood _mood = MascotMood.idle;
  late ConfettiController _confetti;
  bool _showParallaxPreview = true;
  late WorldBlueprint _world;
  late GameMode _activeMode;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _world = worldById(widget.worldId);
    _activeMode = _resolveLevelMode();
    final bank =
        _questionsBank[_world.questionWorldId] ?? _questionsBank['forest']!;
    _questions = List<_Question>.from(bank)..shuffle(Random());
    final maxQuestions = _questionCountForMode(_activeMode);
    if (_questions.length > maxQuestions) {
      _questions = _questions.take(maxQuestions).toList();
    }
    if (_usesQuizMode(_activeMode)) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() => _showParallaxPreview = false);
          _startTimer();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timeLeft = _world.timerSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          if (!_answered) _onAnswer(-1);
        }
      });
    });
  }

  void _onAnswer(int idx) {
    if (_answered) return;
    _timer?.cancel();
    final correct = idx == _questions[_current].correctIndex;
    setState(() {
      _answered = true;
      _selectedIndex = idx;
      if (correct) {
        _score += _world.basePoints + (_combo * 3) + (_timeLeft ~/ 2);
        _combo++;
        _mood = _combo >= 3 ? MascotMood.excited : MascotMood.happy;
        _confetti.play();
      } else {
        _score = (_score - _world.wrongPenalty).clamp(0, 9999);
        _combo = 0;
        _mood = MascotMood.wrong;
      }
    });
  }

  void _nextQuestion() {
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _answered = false;
        _selectedIndex = null;
        _mood = MascotMood.idle;
      });
      _startTimer();
    } else {
      _goToResult(_score, _starsFromScore());
    }
  }

  int _starsFromScore() {
    if (_score >= 60) return 3;
    if (_score >= 35) return 2;
    if (_score >= 15) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return switch (_activeMode) {
      GameMode.dragDropCleanup => _buildRecyclingGame(),
      GameMode.flameRunner => _buildPictureDifferenceGame(),
      GameMode.oceanRescueTap => _buildOceanRescueTapGame(),
      GameMode.arrowColors => _buildArrowColorsGame(),
      GameMode.spotDifference => _buildSpotDifferenceGame(),
      GameMode.frameChallenge => _buildFrameChallengeGame(),
      _ => _buildQuizGame(),
    };
  }

  // ─── Recycling: Flame drag-and-drop ────────────────────────────────────
  Widget _buildRecyclingGame() {
    return Scaffold(
      body: Stack(
        children: [
          const CinematicGameBackground(),
          RecycleGameWidget(
            title: '${_modeLabel(_activeMode)}: ${_world.title}',
            instruction: 'اسحب كل عنصر إلى الصندوق المناسب بسرعة',
            emoji: _world.emoji,
            targetItems: 10,
            onExit: () => context.go(AppRoutes.worlds),
            onComplete: _goToResult,
          ),
        ],
      ),
    );
  }

  Widget _buildPictureDifferenceGame() {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [..._world.gradientColors, const Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          PictureDifferencePuzzleWidget(onComplete: _goToResult),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 60, left: 16),
              child: GestureDetector(
                onTap: () => context.go(AppRoutes.worlds),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowColorsGame() {
    return _buildMiniGameScaffold(
      child: ArrowColorGameWidget(onComplete: _goToResult),
    );
  }

  Widget _buildSpotDifferenceGame() {
    return _buildMiniGameScaffold(
      child: SpotDifferenceGameWidget(onComplete: _goToResult),
    );
  }

  Widget _buildOceanRescueTapGame() {
    return _buildMiniGameScaffold(
      child: OceanRescueTapGameWidget(onComplete: _goToResult),
    );
  }

  Widget _buildFrameChallengeGame() {
    return _buildMiniGameScaffold(
      child: ArrowMatchGameWidget(onComplete: _goToResult),
    );
  }

  Widget _buildMiniGameScaffold({required Widget child}) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [..._world.gradientColors, const Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          child,
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 60, left: 16),
              child: GestureDetector(
                onTap: () => context.go(AppRoutes.worlds),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Other Worlds: Quiz ─────────────────────────────────────────────────
  Widget _buildQuizGame() {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),

          // Cinematic intro: parallax preview
          if (_showParallaxPreview) ...[
            ParallaxWorldScene(worldId: _world.sceneWorldId, showFull: true),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: .7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 80),
                  RiveMascot(mood: MascotMood.excited, size: 120),
                  const SizedBox(height: 20),
                  const Text(
                        'المغامرة تبدأ!',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.black45, blurRadius: 8),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: .2, end: 0),
                ],
              ),
            ),
          ] else ...[
            SafeArea(
              child: Column(
                children: [
                  _GameTopBar(
                    current: _current,
                    total: _questions.length,
                    score: _score,
                    combo: _combo,
                    timeLeft: _timeLeft,
                    modeLabel: _modeLabel(_activeMode),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildQuizContent(),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              maxBlastForce: 20,
              minBlastForce: 8,
              gravity: 0.3,
              colors: const [
                Color(0xFF1DB954),
                Color(0xFF0EA5E9),
                Color(0xFFFBBF24),
                Color(0xFFF97316),
                Color(0xFF8B5CF6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    final q = _questions[_current];
    return Column(
      children: [
        const SizedBox(height: 16),
        // Mascot + question bubble
        Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RiveMascot(mood: _mood, size: 72)
                    .animate(key: ValueKey(_mood))
                    .scale(
                      begin: const Offset(.7, .7),
                      duration: 300.ms,
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .18),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .3),
                      ),
                    ),
                    child: Text(
                      q.text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ],
            )
            .animate(key: ValueKey(_current))
            .fadeIn(duration: 350.ms)
            .scale(begin: const Offset(.9, .9)),

        const SizedBox(height: 20),

        // Big emoji question visual
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: .2)),
          ),
          child: Text(q.emoji, style: const TextStyle(fontSize: 80))
              .animate(key: ValueKey('emoji_$_current'))
              .scale(
                begin: const Offset(.4, .4),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 350.ms),
        ),

        const SizedBox(height: 20),

        if (_answered) ...[
          _ExplanationCard(
            text: q.explanation,
          ).animate().fadeIn(duration: 350.ms).slideY(begin: .1, end: 0),
          const SizedBox(height: 14),
        ],

        // Options
        ...q.options.indexed.map((rec) {
          final (i, opt) = rec;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _OptionButton(
              text: opt,
              index: i,
              selectedIndex: _selectedIndex,
              correctIndex: q.correctIndex,
              answered: _answered,
              onTap: () => _onAnswer(i),
              delay: i * 60,
            ),
          );
        }),

        const SizedBox(height: 12),

        if (_answered)
          ElevatedButton(
            onPressed: _nextQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF7C3AED),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 8,
            ),
            child: Text(
              _current < _questions.length - 1 ? 'التالي ▶' : '🏆 النتائج',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: .15, end: 0),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBackground() {
    final colors = _world.gradientColors;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [...colors, const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  int _questionCountForMode(GameMode mode) {
    return switch (mode) {
      GameMode.quizSpeed => 3,
      GameMode.quizSurvival => 5,
      GameMode.quizClassic => 4,
      GameMode.dragDropCleanup => 0,
      GameMode.flameRunner => 0,
      GameMode.oceanRescueTap => 0,
      GameMode.arrowColors => 0,
      GameMode.spotDifference => 0,
      GameMode.frameChallenge => 0,
    };
  }

  bool _usesQuizMode(GameMode mode) {
    return mode == GameMode.quizClassic ||
        mode == GameMode.quizSpeed ||
        mode == GameMode.quizSurvival;
  }

  GameMode _resolveLevelMode() {
    final byWorld = <String, List<GameMode>>{
      'forest_rescue': [
        GameMode.quizClassic,
        GameMode.arrowColors,
        GameMode.spotDifference,
        GameMode.quizClassic,
        GameMode.frameChallenge,
        GameMode.dragDropCleanup,
      ],
      'ocean_cleanup': [
        GameMode.dragDropCleanup,
        GameMode.oceanRescueTap,
        GameMode.spotDifference,
        GameMode.quizClassic,
        GameMode.arrowColors,
        GameMode.frameChallenge,
      ],
      'lava_flame_escape': [
        GameMode.quizClassic,
        GameMode.arrowColors,
        GameMode.spotDifference,
        GameMode.frameChallenge,
        GameMode.quizSurvival,
        GameMode.flameRunner,
      ],
      'sky_city': [
        GameMode.quizSpeed,
        GameMode.arrowColors,
        GameMode.spotDifference,
        GameMode.quizSpeed,
        GameMode.frameChallenge,
        GameMode.quizClassic,
      ],
      'wildlife_alba': [
        GameMode.quizClassic,
        GameMode.oceanRescueTap,
        GameMode.spotDifference,
        GameMode.arrowColors,
        GameMode.frameChallenge,
        GameMode.quizSurvival,
      ],
      'desert_temple': [
        GameMode.quizSurvival,
        GameMode.spotDifference,
        GameMode.arrowColors,
        GameMode.quizSurvival,
        GameMode.frameChallenge,
        GameMode.quizClassic,
      ],
      'cyber_arena': [
        GameMode.quizSpeed,
        GameMode.arrowColors,
        GameMode.frameChallenge,
        GameMode.spotDifference,
        GameMode.quizSpeed,
        GameMode.quizClassic,
      ],
      'ice_mountain': [
        GameMode.quizSurvival,
        GameMode.spotDifference,
        GameMode.frameChallenge,
        GameMode.quizSurvival,
        GameMode.arrowColors,
        GameMode.quizClassic,
      ],
    };
    final fallback = <GameMode>[
      GameMode.quizClassic,
      GameMode.arrowColors,
      GameMode.spotDifference,
      GameMode.dragDropCleanup,
      GameMode.flameRunner,
      GameMode.frameChallenge,
    ];
    final sequence = byWorld[_world.id] ?? fallback;
    final idx = (widget.levelNumber - 1) % sequence.length;
    return sequence[idx];
  }

  String _modeLabel(GameMode mode) {
    return switch (mode) {
      GameMode.dragDropCleanup => 'تنظيف بالسحب والإفلات',
      GameMode.flameRunner => 'لغز الاختلاف',
      GameMode.oceanRescueTap => 'إنقاذ المحيط',
      GameMode.quizSpeed => 'اختبار السرعة',
      GameMode.quizClassic => 'اختبار المغامرة',
      GameMode.quizSurvival => 'اختبار البقاء',
      GameMode.arrowColors => 'أسهم الألوان',
      GameMode.spotDifference => 'اكتشف الاختلاف',
      GameMode.frameChallenge => 'ربط بالأسهم',
    };
  }

  String _dbWorldIdForCurrentWorld() {
    switch (_world.questionWorldId) {
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

  int _resolveDbLevelIdFallback() {
    final dbWorldId = _dbWorldIdForCurrentWorld();
    final baseOffset = switch (dbWorldId) {
      'colors' => 0,
      'animals' => 6,
      'numbers' => 12,
      'memory' => 18,
      _ => 0,
    };
    return baseOffset + widget.levelNumber;
  }

  Future<void> _goToResult(int score, int stars) async {
    final levelId = widget.dbLevelId ?? _resolveDbLevelIdFallback();
    final isGuestMode = ref.read(settingsControllerProvider).guestMode;
    if (!isGuestMode) {
      await ref.read(gameRepositoryProvider).saveLevelResult(
            levelId: levelId,
            score: score,
            stars: stars,
          );
    } else {
      ref
          .read(guestProgressSessionProvider.notifier)
          .recordResult(levelId: levelId, score: score, stars: stars);
    }
    if (!mounted) return;
    context.go(
      '${AppRoutes.result}?score=$score&stars=$stars&world=${_world.id}&level=${widget.levelNumber}&dbLevelId=$levelId',
    );
  }
}

// ─── Game HUD ─────────────────────────────────────────────────────────────

class _GameTopBar extends StatelessWidget {
  const _GameTopBar({
    required this.current,
    required this.total,
    required this.score,
    required this.combo,
    required this.timeLeft,
    required this.modeLabel,
  });
  final int current;
  final int total;
  final int score;
  final int combo;
  final int timeLeft;
  final String modeLabel;

  @override
  Widget build(BuildContext context) {
    final timerColor = timeLeft <= 5
        ? const Color(0xFFEF4444)
        : timeLeft <= 10
        ? const Color(0xFFFBBF24)
        : Colors.white;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go(AppRoutes.worlds),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (current + 1) / total,
                minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: .25),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              modeLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: timeLeft <= 5
                  ? const Color(0xFFEF4444).withValues(alpha: .3)
                  : Colors.white.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('⏱️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '$timeLeft',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: timerColor,
                  ),
                ),
              ],
            ),
          ),
          if (combo >= 2) ...[
            const SizedBox(width: 6),
            Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: .35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '🔥 x$combo',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(.95, .95),
                  end: const Offset(1.05, 1.05),
                  duration: 600.ms,
                ),
          ],
        ],
      ),
    );
  }
}

// ─── Option Button ────────────────────────────────────────────────────────

class _OptionButton extends StatefulWidget {
  const _OptionButton({
    required this.text,
    required this.index,
    required this.selectedIndex,
    required this.correctIndex,
    required this.answered,
    required this.onTap,
    required this.delay,
  });
  final String text;
  final int index;
  final int? selectedIndex;
  final int correctIndex;
  final bool answered;
  final VoidCallback onTap;
  final int delay;

  @override
  State<_OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<_OptionButton> {
  bool _pressed = false;

  Color _getBg() {
    if (!widget.answered) return Colors.white.withValues(alpha: .18);
    if (widget.index == widget.correctIndex) {
      return const Color(0xFF1DB954).withValues(alpha: .5);
    }
    if (widget.index == widget.selectedIndex) {
      return const Color(0xFFEF4444).withValues(alpha: .5);
    }
    return Colors.white.withValues(alpha: .08);
  }

  Color _getBorder() {
    if (!widget.answered) return Colors.white.withValues(alpha: .3);
    if (widget.index == widget.correctIndex) return const Color(0xFF1DB954);
    if (widget.index == widget.selectedIndex) return const Color(0xFFEF4444);
    return Colors.white.withValues(alpha: .1);
  }

  String _getSuffix() {
    if (!widget.answered) return '';
    if (widget.index == widget.correctIndex) return ' ✅';
    if (widget.index == widget.selectedIndex) return ' ❌';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTapDown: widget.answered
              ? null
              : (_) => setState(() => _pressed = true),
          onTapUp: widget.answered
              ? null
              : (_) => setState(() => _pressed = false),
          onTapCancel: widget.answered
              ? null
              : () => setState(() => _pressed = false),
          onTap: widget.answered ? null : widget.onTap,
          child: AnimatedScale(
            scale: _pressed ? .97 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: _getBg(),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _getBorder(), width: 2),
              ),
              child: Text(
                '${widget.text}${_getSuffix()}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        )
        .animate(delay: widget.delay.ms)
        .fadeIn(duration: 280.ms)
        .slideX(begin: .1, end: 0);
  }
}

// ─── Explanation Card ─────────────────────────────────────────────────────

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBBF24).withValues(alpha: .22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFBBF24).withValues(alpha: .5),
        ),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
