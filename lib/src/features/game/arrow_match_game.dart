import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:yalla_app/src/core/sounds/sound_service.dart';
import 'package:yalla_app/src/shared/animated_assets.dart';

class ArrowMatchGameWidget extends StatefulWidget {
  const ArrowMatchGameWidget({super.key, required this.onComplete});

  final void Function(int score, int stars) onComplete;

  @override
  State<ArrowMatchGameWidget> createState() => _ArrowMatchGameWidgetState();
}

enum _TrashType { plastic, paper, organic }

typedef _TrashItemVisual = ({
  String emoji,
  String name,
  _TrashType type,
  Color tint,
});

class _FallingItem {
  const _FallingItem({
    required this.id,
    required this.visual,
    required this.x,
    required this.y,
    required this.speed,
    required this.rotation,
  });

  final int id;
  final _TrashItemVisual visual;
  final double x;
  final double y;
  final double speed;
  final double rotation;

  _FallingItem copyWith({
    int? id,
    _TrashItemVisual? visual,
    double? x,
    double? y,
    double? speed,
    double? rotation,
  }) {
    return _FallingItem(
      id: id ?? this.id,
      visual: visual ?? this.visual,
      x: x ?? this.x,
      y: y ?? this.y,
      speed: speed ?? this.speed,
      rotation: rotation ?? this.rotation,
    );
  }
}

class _FloatText {
  const _FloatText({
    required this.id,
    required this.text,
    required this.x,
    required this.y,
    required this.color,
  });

  final int id;
  final String text;
  final double x;
  final double y;
  final Color color;
}

class _Burst {
  const _Burst({
    required this.id,
    required this.x,
    required this.y,
    required this.success,
  });

  final int id;
  final double x;
  final double y;
  final bool success;
}

class _ArrowMatchGameWidgetState extends State<ArrowMatchGameWidget> {
  static const _gameSeconds = 70;
  final _rand = Random();

  final List<_TrashItemVisual> _trashPool = const [
    (
      emoji: '🧴',
      name: 'قارورة',
      type: _TrashType.plastic,
      tint: Color(0xFF60A5FA),
    ),
    (
      emoji: '🛍️',
      name: 'كيس',
      type: _TrashType.plastic,
      tint: Color(0xFF38BDF8),
    ),
    (
      emoji: '🧃',
      name: 'علبة عصير',
      type: _TrashType.paper,
      tint: Color(0xFFF59E0B),
    ),
    (emoji: '📄', name: 'ورق', type: _TrashType.paper, tint: Color(0xFFEAB308)),
    (
      emoji: '🍎',
      name: 'تفاحة',
      type: _TrashType.organic,
      tint: Color(0xFF22C55E),
    ),
    (
      emoji: '🍌',
      name: 'قشر موز',
      type: _TrashType.organic,
      tint: Color(0xFF4ADE80),
    ),
  ];

  final Set<int> _dragging = <int>{};
  final List<_FallingItem> _items = <_FallingItem>[];
  final List<_FloatText> _floatTexts = <_FloatText>[];
  final List<_Burst> _bursts = <_Burst>[];

  Timer? _tickTimer;
  Timer? _spawnTimer;
  Timer? _clockTimer;

  int _timeLeft = _gameSeconds;
  int _score = 0;
  int _stars = 0;
  int _combo = 0;
  int _bestStreak = 0;
  int _caught = 0;
  int _missed = 0;
  int _idCounter = 0;
  int _wrongPulse = 0;
  bool _finished = false;
  MascotMood _mood = MascotMood.idle;
  String _feedback = 'اسحب النفايات إلى الحاوية المناسبة';

  @override
  void initState() {
    super.initState();
    SoundService.instance.startUnderwaterAmbience();
    _startGameLoop();
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _spawnTimer?.cancel();
    _clockTimer?.cancel();
    SoundService.instance.stopUnderwaterAmbience();
    super.dispose();
  }

  void _startGameLoop() {
    _tickTimer = Timer.periodic(const Duration(milliseconds: 32), (_) {
      if (!mounted || _finished) return;
      _tickFalling();
    });
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 880), (_) {
      if (!mounted || _finished) return;
      _spawnItem();
    });
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _finished) return;
      setState(() {
        if (_timeLeft <= 1) {
          _finishGame();
          return;
        }
        _timeLeft--;
      });
    });
  }

  double get _difficulty {
    final elapsed = (_gameSeconds - _timeLeft).clamp(0, _gameSeconds);
    return 1 + (elapsed / _gameSeconds) * .9;
  }

  void _spawnItem() {
    if (_items.length > 10) return;
    final visual = _trashPool[_rand.nextInt(_trashPool.length)];
    final x = .08 + _rand.nextDouble() * .84;
    final speed = (.008 + (_rand.nextDouble() * .005)) * _difficulty;
    final rotation = (_rand.nextDouble() - .5) * .2;
    setState(() {
      _items.add(
        _FallingItem(
          id: ++_idCounter,
          visual: visual,
          x: x,
          y: -0.08,
          speed: speed,
          rotation: rotation,
        ),
      );
    });
  }

  void _tickFalling() {
    final dropped = <_FallingItem>[];
    final next = <_FallingItem>[];
    for (final item in _items) {
      if (_dragging.contains(item.id)) {
        next.add(item);
        continue;
      }
      final updated = item.copyWith(y: item.y + item.speed);
      if (updated.y > .86) {
        dropped.add(updated);
      } else {
        next.add(updated);
      }
    }
    if (dropped.isNotEmpty) {
      setState(() {
        _items
          ..clear()
          ..addAll(next);
        _combo = 0;
        _missed += dropped.length;
        _wrongPulse++;
        _mood = MascotMood.wrong;
        _feedback = 'أوه! سقطت نفايات على الأرض';
      });
      SoundService.instance.wrong();
      for (final item in dropped) {
        _spawnFloatText('-5', item.x, .82, const Color(0xFFFCA5A5));
      }
      _score = max(0, _score - (dropped.length * 5));
    } else {
      setState(() {
        _items
          ..clear()
          ..addAll(next);
      });
    }
  }

  void _onDrop(_FallingItem item, _TrashType targetType) {
    final isCorrect = item.visual.type == targetType;
    if (isCorrect) {
      final multiplier = 1 + (min(_combo, 6) * .2);
      final gain = (12 * multiplier).round();
      setState(() {
        _items.removeWhere((e) => e.id == item.id);
        _dragging.remove(item.id);
        _score += gain;
        _combo++;
        _caught++;
        _bestStreak = max(_bestStreak, _combo);
        _stars = (_score ~/ 75).clamp(0, 999);
        _feedback = _combo >= 3
            ? 'سلسلة رائعة! x${multiplier.toStringAsFixed(1)}'
            : 'ممتاز! فرز صحيح';
        _mood = _combo >= 4 ? MascotMood.excited : MascotMood.happy;
      });
      SoundService.instance.success();
      if (_combo > 0 && _combo % 4 == 0) {
        SoundService.instance.bonus();
      }
      _spawnBurst(item.x, .78, true);
      _spawnFloatText('+$gain', item.x, .78, const Color(0xFFFACC15));
    } else {
      setState(() {
        _items.removeWhere((e) => e.id == item.id);
        _dragging.remove(item.id);
        _score = max(0, _score - 7);
        _combo = 0;
        _missed++;
        _wrongPulse++;
        _feedback = 'الحاوية غير صحيحة 😅';
        _mood = MascotMood.wrong;
      });
      SoundService.instance.wrong();
      _spawnBurst(item.x, .78, false);
      _spawnFloatText('-7', item.x, .78, const Color(0xFFFCA5A5));
    }
  }

  void _spawnFloatText(String text, double x, double y, Color color) {
    final id = ++_idCounter;
    setState(() {
      _floatTexts.add(_FloatText(id: id, text: text, x: x, y: y, color: color));
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _floatTexts.removeWhere((e) => e.id == id));
    });
  }

  void _spawnBurst(double x, double y, bool success) {
    final id = ++_idCounter;
    setState(() {
      _bursts.add(_Burst(id: id, x: x, y: y, success: success));
    });
    Future.delayed(const Duration(milliseconds: 620), () {
      if (!mounted) return;
      setState(() => _bursts.removeWhere((e) => e.id == id));
    });
  }

  void _finishGame() {
    if (_finished) return;
    _finished = true;
    _tickTimer?.cancel();
    _spawnTimer?.cancel();
    _clockTimer?.cancel();
    final accuracy = _caught / max(1, _caught + _missed);
    final stars = accuracy >= .82
        ? 3
        : accuracy >= .56
        ? 2
        : accuracy >= .3
        ? 1
        : 0;
    widget.onComplete(_score, stars);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_gameSeconds - _timeLeft) / _gameSeconds;
    final unlockedBadge = _bestStreak >= 5;
    final unlockedSkin = _score >= 260;
    final unlockedWorld = _score >= 360;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 88, 14, 14),
      child: Stack(
        children: [
          _animatedBackground(progress),
          Column(
            children: [
              _buildHud(progress),
              const SizedBox(height: 10),
              _buildMissionCard(
                unlockedBadge: unlockedBadge,
                unlockedSkin: unlockedSkin,
                unlockedWorld: unlockedWorld,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        ..._items.map((item) {
                          final left = (item.x * constraints.maxWidth) - 26;
                          final top = (item.y * constraints.maxHeight).clamp(
                            0.0,
                            constraints.maxHeight - 60,
                          );
                          return Positioned(
                            left: left,
                            top: top,
                            child: Draggable<_FallingItem>(
                              data: item,
                              onDragStarted: () {
                                setState(() => _dragging.add(item.id));
                              },
                              onDragEnd: (_) {
                                if (!mounted) return;
                                setState(() => _dragging.remove(item.id));
                              },
                              feedback: _trashBubble(item, dragging: true),
                              childWhenDragging: Opacity(
                                opacity: .22,
                                child: _trashBubble(item),
                              ),
                              child: _trashBubble(item),
                            ),
                          );
                        }),
                        ..._bursts.map((b) => _burstFx(b)),
                        ..._floatTexts.map((f) => _floatingTextFx(f)),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              _buildBins()
                  .animate(key: ValueKey(_wrongPulse))
                  .shake(duration: 260.ms, hz: 4.6, offset: const Offset(8, 0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHud(double progress) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .26)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _chip('⭐', '$_stars'),
              const SizedBox(width: 6),
              _chip('🏆', '$_score'),
              const SizedBox(width: 6),
              _chip('🔥', '$_combo'),
              const Spacer(),
              _chip('⏱', '$_timeLeft'),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
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

  Widget _buildMissionCard({
    required bool unlockedBadge,
    required bool unlockedSkin,
    required bool unlockedWorld,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .22)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF4F46E5)],
              ),
              border: Border.all(color: Colors.white, width: 2.4),
            ),
            child: Center(child: RiveMascot(mood: _mood, size: 52)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trash Sort Frenzy',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _feedback,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .92),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _rewardPill('شارة', unlockedBadge),
                    _rewardPill('مظهر', unlockedSkin),
                    _rewardPill('عالم', unlockedWorld),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBins() {
    return Row(
      children: [
        Expanded(child: _binTarget(_TrashType.plastic, '🟦 بلاستيك')),
        const SizedBox(width: 8),
        Expanded(child: _binTarget(_TrashType.paper, '🟨 ورق')),
        const SizedBox(width: 8),
        Expanded(child: _binTarget(_TrashType.organic, '🟩 عضوي')),
      ],
    );
  }

  Widget _binTarget(_TrashType type, String label) {
    return DragTarget<_FallingItem>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        _onDrop(details.data, type);
      },
      builder: (context, candidateData, rejectedData) {
        final active = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 92,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: active ? .26 : .16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: active ? .55 : .28),
              width: active ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .18),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _trashBubble(_FallingItem item, {bool dragging = false}) {
    return Transform.rotate(
      angle: item.rotation,
      child: Container(
        width: dragging ? 58 : 52,
        height: dragging ? 58 : 52,
        decoration: BoxDecoration(
          color: item.visual.tint.withValues(alpha: dragging ? .52 : .34),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: .55)),
          boxShadow: [
            BoxShadow(
              color: item.visual.tint.withValues(alpha: .35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            item.visual.emoji,
            style: TextStyle(fontSize: dragging ? 30 : 26),
          ),
        ),
      ),
    );
  }

  Widget _burstFx(_Burst burst) {
    return Align(
      alignment: Alignment((burst.x * 2) - 1, (burst.y * 2) - 1),
      child: IgnorePointer(
        child:
            Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (burst.success
                                ? const Color(0xFFFACC15)
                                : const Color(0xFFFCA5A5))
                            .withValues(alpha: .52),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      burst.success ? '✨' : '💥',
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                )
                .animate(key: ValueKey('burst_${burst.id}'))
                .scale(
                  begin: const Offset(.45, .45),
                  end: const Offset(1.24, 1.24),
                  duration: 520.ms,
                )
                .fadeOut(duration: 520.ms),
      ),
    );
  }

  Widget _floatingTextFx(_FloatText t) {
    return Align(
      alignment: Alignment((t.x * 2) - 1, (t.y * 2) - 1),
      child:
          Text(
                t.text,
                style: TextStyle(
                  color: t.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              )
              .animate(key: ValueKey('txt_${t.id}'))
              .moveY(begin: 0, end: -24, duration: 680.ms)
              .fadeOut(duration: 680.ms),
    );
  }

  Widget _animatedBackground(double progress) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF06B6D4),
              Color.lerp(
                const Color(0xFF0369A1),
                const Color(0xFF22C55E),
                progress.clamp(0.0, 1.0),
              )!,
              const Color(0xFF0F172A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              child: const Text('☁️', style: TextStyle(fontSize: 26))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveX(begin: -8, end: 16, duration: 7600.ms),
            ),
            Positioned(
              right: 22,
              top: 84,
              child: const Text('🍃', style: TextStyle(fontSize: 20))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(begin: 0, end: -8, duration: 3400.ms),
            ),
            Positioned(
              left: 24,
              bottom: 112,
              child: const Text('✨', style: TextStyle(fontSize: 18))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .fade(begin: .2, end: .65, duration: 2200.ms),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String icon, String value) {
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
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardPill(String label, bool unlocked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: unlocked
            ? const Color(0xFFFACC15).withValues(alpha: .3)
            : Colors.white.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked
              ? const Color(0xFFFDE047)
              : Colors.white.withValues(alpha: .25),
        ),
      ),
      child: Text(
        unlocked ? '$label ✅' : '$label 🔒',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
