import 'dart:async' as async;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/sounds/sound_service.dart';

class OceanRescueTapGameWidget extends StatefulWidget {
  const OceanRescueTapGameWidget({super.key, required this.onComplete});

  final void Function(int score, int stars) onComplete;

  @override
  State<OceanRescueTapGameWidget> createState() =>
      _OceanRescueTapGameWidgetState();
}

enum _OceanObjectType { trash, life }

typedef _OceanObjectVisual = ({
  String emoji,
  String label,
  Color color,
  _OceanObjectType type,
});

class _OceanBurst {
  const _OceanBurst({
    required this.id,
    required this.index,
    required this.success,
    required this.text,
  });

  final int id;
  final int index;
  final bool success;
  final String text;
}

class _OceanRescueTapGameWidgetState extends State<OceanRescueTapGameWidget> {
  static const _totalRounds = 6;
  static const _trashPerRound = 3;
  static const _totalSeconds = 80;
  final _rand = Random();

  final List<_OceanObjectVisual> _trashVisuals = const [
    (
      emoji: '🧴',
      label: 'قارورة بلاستيك',
      color: Color(0xFFF59E0B),
      type: _OceanObjectType.trash,
    ),
    (
      emoji: '🥫',
      label: 'علبة معدنية',
      color: Color(0xFFF97316),
      type: _OceanObjectType.trash,
    ),
    (
      emoji: '🛍️',
      label: 'كيس بلاستيكي',
      color: Color(0xFFEF4444),
      type: _OceanObjectType.trash,
    ),
    (
      emoji: '🧃',
      label: 'علبة عصير',
      color: Color(0xFFEAB308),
      type: _OceanObjectType.trash,
    ),
  ];

  final List<_OceanObjectVisual> _lifeVisuals = const [
    (
      emoji: '🐟',
      label: 'سمكة',
      color: Color(0xFF38BDF8),
      type: _OceanObjectType.life,
    ),
    (
      emoji: '🐬',
      label: 'دلفين',
      color: Color(0xFF60A5FA),
      type: _OceanObjectType.life,
    ),
    (
      emoji: '🦀',
      label: 'سلطعون',
      color: Color(0xFFF97316),
      type: _OceanObjectType.life,
    ),
    (
      emoji: '🐢',
      label: 'سلحفاة',
      color: Color(0xFF34D399),
      type: _OceanObjectType.life,
    ),
    (
      emoji: '🪸',
      label: 'مرجان',
      color: Color(0xFFFB7185),
      type: _OceanObjectType.life,
    ),
  ];

  int _round = 1;
  int _score = 0;
  int _displayScore = 0;
  int _stars = 0;
  int _combo = 0;
  int _bestStreak = 0;
  int _correct = 0;
  int _wrong = 0;
  int _timeLeft = _totalSeconds;
  int _roundTrashCount = 0;
  int _roundCollectedTrash = 0;
  int _shakeTick = 0;
  int _burstId = 0;
  bool _showIntro = true;
  bool _ending = false;

  double _cleanliness = 0;

  List<_OceanObjectVisual> _cells = const [];
  Set<int> _tapped = <int>{};
  Set<int> _hovered = <int>{};
  List<_OceanBurst> _bursts = const [];

  String _feedback = '';
  bool _feedbackError = false;

  async.Timer? _timer;

  @override
  void initState() {
    super.initState();
    _nextRound(showIntro: true);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = async.Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _ending) return;
      if (_timeLeft <= 1) {
        _finishGame();
        return;
      }
      setState(() => _timeLeft--);
    });
  }

  void _nextRound({required bool showIntro}) {
    final cells = List<_OceanObjectVisual>.generate(8, (_) {
      return _lifeVisuals[_rand.nextInt(_lifeVisuals.length)];
    });

    final trashIndices = <int>{};
    while (trashIndices.length < _trashPerRound) {
      trashIndices.add(_rand.nextInt(cells.length));
    }
    for (final idx in trashIndices) {
      cells[idx] = _trashVisuals[_rand.nextInt(_trashVisuals.length)];
    }

    setState(() {
      _cells = cells;
      _roundTrashCount = trashIndices.length;
      _roundCollectedTrash = 0;
      _tapped = <int>{};
      _hovered = <int>{};
      _bursts = const [];
      _showIntro = showIntro;
      _feedback = 'اضغط على كل النفايات واحمِ الكائنات البحرية';
      _feedbackError = false;
    });

    if (showIntro) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() => _showIntro = false);
      });
    }
  }

  void _tapCell(int index) async {
    if (_ending || _showIntro) return;
    if (_tapped.contains(index)) return;

    final tapped = _cells[index];
    if (tapped.type == _OceanObjectType.trash) {
      final gain = 16 + (_combo * 2);
      setState(() {
        _score += gain;
        _correct++;
        _combo++;
        _bestStreak = max(_bestStreak, _combo);
        _stars++;
        _roundCollectedTrash++;
        _feedback = 'رائع! +$gain 🌟';
        _feedbackError = false;
        _cleanliness = (_correct / (_totalRounds * _trashPerRound)).clamp(
          0.0,
          1.0,
        );
      });
      await SoundService.instance.tapSoft();
      _spawnBurst(index, true, '+$gain');
    } else {
      setState(() {
        _score = max(0, _score - 7);
        _wrong++;
        _combo = 0;
        _feedback = 'هذه كائنات بحرية 🐟';
        _feedbackError = true;
        _shakeTick++;
      });
      _spawnBurst(index, false, '-7');
    }

    setState(() {
      _tapped = <int>{..._tapped, index};
    });

    if (_displayScore != _score) {
      final start = _displayScore;
      final end = _score;
      const steps = 9;
      for (var i = 1; i <= steps; i++) {
        await Future.delayed(const Duration(milliseconds: 16));
        if (!mounted) return;
        setState(() {
          _displayScore = (start + ((end - start) * (i / steps))).round();
        });
      }
    }

    final roundDone = _roundCollectedTrash >= _roundTrashCount;
    if (!roundDone) return;

    if (_round >= _totalRounds) {
      _finishGame();
      return;
    }

    setState(() => _round++);
    Future.delayed(const Duration(milliseconds: 550), () {
      if (!mounted) return;
      _nextRound(showIntro: true);
    });
  }

  void _spawnBurst(int index, bool success, String text) {
    final id = ++_burstId;
    setState(() {
      _bursts = [
        ..._bursts,
        _OceanBurst(id: id, index: index, success: success, text: text),
      ];
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _bursts = _bursts.where((b) => b.id != id).toList());
    });
  }

  void _finishGame() {
    if (_ending) return;
    _ending = true;
    _timer?.cancel();
    final accuracy = _correct / (_correct + _wrong).clamp(1, 9999);
    final stars = accuracy >= .78
        ? 3
        : accuracy >= .5
        ? 2
        : accuracy >= .25
        ? 1
        : 0;
    widget.onComplete(_score, stars);
  }

  @override
  Widget build(BuildContext context) {
    final missionProgress = _roundCollectedTrash / max(1, _roundTrashCount);
    final overallProgress =
        ((_round - 1) / _totalRounds) + (missionProgress / _totalRounds);
    final waterDark = Color.lerp(
      const Color(0xFF0A2A53),
      const Color(0xFF1DA5D8),
      _cleanliness,
    )!;
    final waterLight = Color.lerp(
      const Color(0xFF0A4E8B),
      const Color(0xFF6EE7FF),
      _cleanliness,
    )!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 82, 14, 12),
      child: Stack(
        children: [
          _buildUnderwaterBackground(waterDark, waterLight),
          _buildAmbientForeground(),
          Column(
            children: [
              _buildHud(overallProgress),
              const SizedBox(height: 8),
              _buildMission(missionProgress),
              const SizedBox(height: 4),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 10.0;
                    final count = _cells.length;
                    final crossAxisCount = constraints.maxWidth < 340 ? 3 : 4;
                    final rows = (count / crossAxisCount).ceil().clamp(1, 10);
                    final maxBoardHeight = constraints.maxHeight;

                    final tileByWidth =
                        (constraints.maxWidth -
                            ((crossAxisCount - 1) * spacing)) /
                        crossAxisCount;
                    final tileByHeight =
                        (maxBoardHeight - ((rows - 1) * spacing)) / rows;
                    final tileSize = min(
                      tileByWidth,
                      tileByHeight,
                    ).clamp(68.0, 120.0);

                    final boardWidth =
                        (crossAxisCount * tileSize) +
                        ((crossAxisCount - 1) * spacing);
                    final boardHeight =
                        (rows * tileSize) + ((rows - 1) * spacing);

                    return Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: SizedBox(
                          width: boardWidth,
                          height: boardHeight,
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: count,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: spacing,
                                  mainAxisSpacing: spacing,
                                  childAspectRatio: 1,
                                ),
                            itemBuilder: (_, i) => _buildTile(i),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (_showIntro) _buildRoundIntro(),
        ],
      ),
    );
  }

  Widget _buildUnderwaterBackground(Color dark, Color light) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [dark, light],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 30,
              child:
                  Container(
                        width: 120,
                        height: 280,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(
                                alpha: .12 * (1 - _cleanliness),
                              ),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(begin: -5, end: 8, duration: 4600.ms),
            ),
            Positioned(
              right: 22,
              top: 64,
              child: Opacity(
                opacity: .5 + (_cleanliness * .35),
                child: const Text('🐬', style: TextStyle(fontSize: 26))
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveX(begin: -6, end: 10, duration: 4200.ms),
              ),
            ),
            Positioned(
              left: 24,
              bottom: 58,
              child: Opacity(
                opacity: .28 + (_cleanliness * .45),
                child: const Text('🪸', style: TextStyle(fontSize: 28))
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: 0, end: -5, duration: 3400.ms),
              ),
            ),
            ...List.generate(10, (i) {
              final dx = 20.0 + (i * 33.0);
              final dy = 30.0 + ((i % 5) * 80.0);
              return Positioned(
                left: dx,
                top: dy,
                child: Opacity(
                  opacity: .16 + (_cleanliness * .12),
                  child: const Text('🫧', style: TextStyle(fontSize: 13))
                      .animate(delay: (i * 120).ms, onPlay: (c) => c.repeat())
                      .moveY(begin: 0, end: -16, duration: 3900.ms)
                      .fade(begin: .12, end: .48),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHud(double overallProgress) {
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: .25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .16),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _miniChip('⭐', '$_displayScore'),
                  const SizedBox(width: 6),
                  _miniChip('🔥', '$_combo'),
                  const SizedBox(width: 6),
                  _miniChip('🏆', '$_bestStreak'),
                  const Spacer(),
                  _miniChip('⏱', '$_timeLeft'),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      color: Colors.white.withValues(alpha: .24),
                    ),
                    FractionallySizedBox(
                      widthFactor: overallProgress.clamp(0.0, 1.0),
                      child: Container(
                        height: 8,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF22D3EE),
                              Color(0xFF38BDF8),
                              Color(0xFFFACC15),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(key: ValueKey(_shakeTick))
        .shake(
          duration: _feedbackError ? 320.ms : 0.ms,
          hz: 5,
          offset: const Offset(7, 0),
        );
  }

  Widget _buildMission(double missionProgress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .22)),
      ),
      child: Column(
        children: [
          Text(
            'إنقاذ المحيط $_round/$_totalRounds  •  النجوم $_stars',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _feedbackError
                ? _feedback
                : (_feedback.isNotEmpty
                      ? _feedback
                      : 'اضغط على كل النفايات ($_roundCollectedTrash/$_roundTrashCount)'),
            style: TextStyle(
              color: _feedbackError
                  ? const Color(0xFFFCA5A5)
                  : Colors.white.withValues(alpha: .92),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: missionProgress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: .24),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF22C55E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(int index) {
    final cell = _cells[index];
    final isTapped = _tapped.contains(index);
    final isHovered = _hovered.contains(index);
    final burst = _bursts.where((b) => b.index == index).toList();

    final tileColor = isTapped
        ? (cell.type == _OceanObjectType.trash
              ? const Color(0xFF22C55E).withValues(alpha: .34)
              : const Color(0xFFEF4444).withValues(alpha: .3))
        : Colors.white.withValues(alpha: isHovered ? .18 : .1);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = {..._hovered, index}),
      onExit: (_) {
        final next = Set<int>.from(_hovered)..remove(index);
        setState(() => _hovered = next);
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        scale: isHovered ? 1.03 : 1.0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.white.withValues(alpha: .22),
            highlightColor: Colors.white.withValues(alpha: .08),
            onTap: () => _tapCell(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isTapped && cell.type == _OceanObjectType.trash
                      ? const Color(0xFFFDE047)
                      : (isHovered
                            ? Colors.white.withValues(alpha: .6)
                            : Colors.white.withValues(alpha: .26)),
                  width: isTapped && cell.type == _OceanObjectType.trash
                      ? 1.8
                      : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: cell.color.withValues(alpha: isHovered ? .24 : .14),
                    blurRadius: isHovered ? 16 : 8,
                    offset: const Offset(0, 4),
                  ),
                  if (isTapped && cell.type == _OceanObjectType.trash)
                    BoxShadow(
                      color: const Color(0xFFFDE047).withValues(alpha: .35),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Opacity(
                      opacity: .25,
                      child: Text(
                        cell.type == _OceanObjectType.trash ? '♻️' : '🫧',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                            isTapped && cell.type == _OceanObjectType.life
                                ? '🙈'
                                : cell.emoji,
                            style: const TextStyle(fontSize: 36),
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .moveY(
                            begin: 0,
                            end: cell.type == _OceanObjectType.life
                                ? (isHovered ? -5 : -2)
                                : (isHovered ? -3 : 0),
                            duration: 1200.ms,
                          ),
                    ],
                  ),
                  ...burst.map((b) {
                    return Center(
                      child: IgnorePointer(
                        child:
                            Text(
                                  b.success ? '✨ ${b.text}' : '❌ ${b.text}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: b.success
                                        ? const Color(0xFFFACC15)
                                        : const Color(0xFFFCA5A5),
                                    fontWeight: FontWeight.w900,
                                  ),
                                )
                                .animate(key: ValueKey('burst_${b.id}'))
                                .scale(
                                  begin: const Offset(.5, .5),
                                  end: const Offset(1.15, 1.15),
                                  duration: 260.ms,
                                  curve: Curves.easeOutBack,
                                )
                                .fadeOut(duration: 620.ms)
                                .moveY(begin: 0, end: -22, duration: 620.ms),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmbientForeground() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              left: 16,
              bottom: 24,
              child: Opacity(
                opacity: .18,
                child: const Text('🪸', style: TextStyle(fontSize: 30))
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: 0, end: -4, duration: 4200.ms),
              ),
            ),
            Positioned(
              right: 18,
              bottom: 32,
              child: Opacity(
                opacity: .2,
                child: const Text('🐟', style: TextStyle(fontSize: 24))
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveX(begin: 0, end: -14, duration: 5200.ms),
              ),
            ),
            Positioned(
              right: 36,
              top: 220,
              child: Opacity(
                opacity: .14,
                child: const Text('🐠', style: TextStyle(fontSize: 20))
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveX(begin: -6, end: 10, duration: 4600.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundIntro() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0C1B3D).withValues(alpha: .45),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child:
              Container(
                    width: 220,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .25),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🐬', style: TextStyle(fontSize: 40))
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .moveX(begin: -8, end: 8, duration: 900.ms),
                        const SizedBox(height: 6),
                        Text(
                          'استعد للموجة $_round',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'نظّف المحيط وأعد الحياة البحرية',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 220.ms)
                  .scale(
                    begin: const Offset(.85, .85),
                    end: const Offset(1, 1),
                    curve: Curves.easeOutBack,
                  ),
        ),
      ),
    );
  }

  Widget _miniChip(String icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
