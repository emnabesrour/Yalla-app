import 'dart:async' as async;
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ScaleEffect;
import 'package:yalla_app/src/core/sounds/sound_service.dart';

enum TrashType { plastic, glass, organic, paper }

extension TrashTypeExt on TrashType {
  String get itemEmoji => switch (this) {
    TrashType.plastic => '🧴',
    TrashType.glass => '🍾',
    TrashType.organic => '🍌',
    TrashType.paper => '📄',
  };

  String get binEmoji => switch (this) {
    TrashType.plastic => '🟡',
    TrashType.glass => '🟢',
    TrashType.organic => '🟤',
    TrashType.paper => '🔵',
  };

  Color get color => switch (this) {
    TrashType.plastic => const Color(0xFFFACC15),
    TrashType.glass => const Color(0xFF22C55E),
    TrashType.organic => const Color(0xFFB45309),
    TrashType.paper => const Color(0xFF0EA5E9),
  };

  String get label => switch (this) {
    TrashType.plastic => 'بلاستيك',
    TrashType.glass => 'زجاج',
    TrashType.organic => 'عضوي',
    TrashType.paper => 'ورق',
  };
}

class RecycleFlameGame extends FlameGame {
  RecycleFlameGame({
    required this.onScoreChanged,
    required this.onGameComplete,
    this.onComboChanged,
    this.onFeedback,
    this.onWorldCleanChanged,
    this.onSuccessJuice,
    this.targetItems = 8,
  });

  static const _itemSpawnY = .33;

  final void Function(int score) onScoreChanged;
  final void Function(int score, int stars) onGameComplete;
  final void Function(int combo)? onComboChanged;
  final void Function(String text, bool isError)? onFeedback;
  final void Function(double value)? onWorldCleanChanged;
  final void Function(bool success, int delta)? onSuccessJuice;
  final int targetItems;

  int score = 0;
  int _correct = 0;
  int _total = 0;
  int _combo = 0;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    onWorldCleanChanged?.call(0);
    _spawnNextItem();
  }

  void _spawnNextItem() {
    if (_total >= targetItems) {
      Future.delayed(const Duration(milliseconds: 650), () {
        final stars = _correct >= targetItems - 1
            ? 3
            : _correct >= targetItems - 3
            ? 2
            : _correct >= 2
            ? 1
            : 0;
        onGameComplete(score, stars);
      });
      return;
    }
    final type = TrashType.values[Random().nextInt(TrashType.values.length)];
    add(
      DraggableTrashItem(
        type: type,
        position: Vector2(size.x / 2, size.y * _itemSpawnY),
        gameInstance: this,
      ),
    );
    _total++;
  }

  void onDragHoverBin({
    required TrashType draggingType,
    required TrashType? hoveredBinType,
  }) {
    final bins = children.whereType<RecycleBin>();
    for (final bin in bins) {
      final active = hoveredBinType == bin.type;
      bin.setHoverState(active: active, isMatch: draggingType == bin.type);
    }
  }

  void onCorrectDrop(TrashType type, Vector2 atPosition) {
    final gained = 14 + (_combo * 2);
    score += gained;
    _correct++;
    _combo++;
    onComboChanged?.call(_combo);
    onScoreChanged(score);
    onFeedback?.call('رائع! +$gained', false);
    onSuccessJuice?.call(true, gained);
    onWorldCleanChanged?.call(_correct / targetItems);
    _spawnBurst(const Color(0xFFFACC15), atPosition, stars: true);
    _spawnBurst(const Color(0xFF22C55E), atPosition, stars: false);
    _spawnNextItem();
  }

  void onWrongDrop(TrashType type, Vector2 atPosition) {
    final lost = 6;
    score = (score - lost).clamp(0, 9999);
    _combo = 0;
    onComboChanged?.call(_combo);
    onScoreChanged(score);
    onFeedback?.call('حاول مرة أخرى 🌱', true);
    onSuccessJuice?.call(false, lost);
    _spawnBurst(const Color(0xFFEF4444), atPosition, stars: false);
    _spawnNextItem();
  }

  void _spawnBurst(Color color, Vector2 position, {required bool stars}) {
    add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: stars ? 16 : 12,
          lifespan: .72,
          generator: (_) {
            final rnd = Random();
            final dx = (rnd.nextDouble() - .5) * 260;
            final dy = -rnd.nextDouble() * 200;
            return AcceleratedParticle(
              acceleration: Vector2(dx, dy),
              child: stars
                  ? CircleParticle(
                      radius: 3 + rnd.nextDouble() * 3,
                      paint: Paint()..color = color.withValues(alpha: .9),
                    )
                  : CircleParticle(
                      radius: 2 + rnd.nextDouble() * 3,
                      paint: Paint()..color = color.withValues(alpha: .85),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class DraggableTrashItem extends PositionComponent
    with DragCallbacks, HasGameReference<RecycleFlameGame> {
  DraggableTrashItem({
    required this.type,
    required super.position,
    required RecycleFlameGame gameInstance,
  }) : super(size: Vector2.all(92), anchor: Anchor.center) {
    _gameInstance = gameInstance;
  }

  final TrashType type;
  late final RecycleFlameGame _gameInstance;
  bool _dropped = false;
  bool _dragging = false;
  late Vector2 _homePosition;
  double _dragTime = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _homePosition = position.clone();

    add(
      CircleComponent(
        radius: 52,
        paint: Paint()..color = type.color.withValues(alpha: .16),
      ),
    );
    add(
      CircleComponent(
        radius: 46,
        paint: Paint()
          ..color = type.color.withValues(alpha: .2)
          ..style = PaintingStyle.fill,
      ),
    );
    add(
      CircleComponent(
        radius: 46,
        paint: Paint()
          ..color = type.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.6,
      ),
    );
    add(
      TextComponent(
        text: type.itemEmoji,
        textRenderer: TextPaint(style: const TextStyle(fontSize: 40)),
        anchor: Anchor.center,
        position: size / 2,
      ),
    );
    add(
      TextComponent(
        text: type.label,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(color: Colors.black45, blurRadius: 3)],
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y + 12),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_dragging) {
      _dragTime += dt;
      angle = sin(_dragTime * 9) * .06;
    } else if (angle.abs() > .001) {
      angle *= .82;
    } else {
      angle = 0;
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (_dropped) return;
    _dragging = true;
    priority = 10;
    add(
      ScaleEffect.to(
        Vector2.all(1.12),
        EffectController(duration: .15, curve: Curves.easeOutBack),
      ),
    );
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_dropped) return;
    position += event.localDelta;
    final bins = _gameInstance.children.whereType<RecycleBin>().toList();
    TrashType? hovered;
    double minDist = 9999;
    for (final bin in bins) {
      final center = bin.position + (bin.size / 2);
      final d = (position - center).length;
      if (d < 120 && d < minDist) {
        minDist = d;
        hovered = bin.type;
      }
    }
    _gameInstance.onDragHoverBin(draggingType: type, hoveredBinType: hovered);
    super.onDragUpdate(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (_dropped) return;
    _dragging = false;
    _gameInstance.onDragHoverBin(draggingType: type, hoveredBinType: null);
    _checkBinDrop();
    super.onDragEnd(event);
  }

  void _checkBinDrop() {
    final bins = _gameInstance.children.whereType<RecycleBin>();
    for (final bin in bins) {
      final center = bin.position + (bin.size / 2);
      final dist = (position - center).length;
      if (dist < 86) {
        _dropped = true;
        if (bin.type == type) {
          _gameInstance.onCorrectDrop(type, center);
        } else {
          _gameInstance.onWrongDrop(type, center);
        }
        removeFromParent();
        return;
      }
    }

    add(
      MoveToEffect(
        _homePosition,
        EffectController(duration: .32, curve: Curves.easeOutBack),
      ),
    );
    add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: .22, curve: Curves.easeOut),
      ),
    );
  }
}

class RecycleBin extends PositionComponent {
  RecycleBin({required this.type, required super.position})
    : super(size: Vector2(92, 108), anchor: Anchor.center);

  final TrashType type;
  late RectangleComponent _fill;
  late RectangleComponent _border;
  late TextComponent _eyes;
  late TextComponent _mouth;

  bool _active = false;
  bool _match = false;
  double _pulseTime = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      RectangleComponent(
        size: size + Vector2(10, 12),
        position: Vector2(-5, -6),
        paint: Paint()..color = Colors.black.withValues(alpha: .16),
      ),
    );
    _fill = RectangleComponent(
      size: size,
      paint: Paint()..color = type.color.withValues(alpha: .2),
    );
    _border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = type.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4,
    );
    add(_fill);
    add(_border);

    _eyes = TextComponent(
      text: '◕ ◕',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 15,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 6),
    );
    _mouth = TextComponent(
      text: '◡',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 24),
    );
    add(_eyes);
    add(_mouth);

    add(
      TextComponent(
        text: type.binEmoji,
        textRenderer: TextPaint(style: const TextStyle(fontSize: 28)),
        anchor: Anchor.topCenter,
        position: Vector2(size.x / 2, 40),
      ),
    );
    add(
      TextComponent(
        text: type.label,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(color: Colors.black54, blurRadius: 3)],
          ),
        ),
        anchor: Anchor.bottomCenter,
        position: Vector2(size.x / 2, size.y - 7),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt;
    if (!_active) {
      final s = 1 + sin(_pulseTime * 2.2) * .015;
      scale = Vector2.all(s);
    }
  }

  void setHoverState({required bool active, required bool isMatch}) {
    if (_active == active && _match == isMatch) return;
    _active = active;
    _match = isMatch;
    if (active) {
      final c = isMatch ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
      _border.paint.color = c;
      _border.paint.strokeWidth = 4.4;
      _fill.paint.color = c.withValues(alpha: .22);
      _eyes.text = isMatch ? '✦ ✦' : '> <';
      _mouth.text = isMatch ? '◠' : '︿';
      add(
        ScaleEffect.to(
          Vector2.all(1.08),
          EffectController(duration: .16, curve: Curves.easeOutBack),
        ),
      );
    } else {
      _border.paint.color = type.color;
      _border.paint.strokeWidth = 3.4;
      _fill.paint.color = type.color.withValues(alpha: .2);
      _eyes.text = '◕ ◕';
      _mouth.text = '◡';
      add(
        ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(duration: .18, curve: Curves.easeOutCubic),
        ),
      );
    }
  }
}

class RecycleGameWidget extends StatefulWidget {
  const RecycleGameWidget({
    super.key,
    required this.onComplete,
    this.onExit,
    this.title = 'فرّز النفايات!',
    this.instruction = 'اسحب كل عنصر إلى الصندوق المناسب بسرعة',
    this.emoji = '♻️',
    this.targetItems = 8,
  });
  final void Function(int score, int stars) onComplete;
  final VoidCallback? onExit;
  final String title;
  final String instruction;
  final String emoji;
  final int targetItems;

  @override
  State<RecycleGameWidget> createState() => _RecycleGameWidgetState();
}

class _RecycleGameWidgetState extends State<RecycleGameWidget> {
  static const _topHudReserved = 140.0;
  static const _bottomHudReserved = 110.0;
  static const _totalSeconds = 75;

  int _score = 0;
  int _combo = 0;
  int _streak = 0;
  int _timeLeft = _totalSeconds;
  int _hudShakeTick = 0;
  double _worldClean = 0;
  String _feedback = '';
  bool _feedbackError = false;
  async.Timer? _timer;
  bool _exiting = false;

  late RecycleFlameGame _game;
  bool _binsSpawned = false;

  @override
  void initState() {
    super.initState();
    _game = RecycleFlameGame(
      targetItems: widget.targetItems,
      onScoreChanged: (v) {
        if (!mounted || _exiting) return;
        setState(() => _score = v);
      },
      onComboChanged: (combo) {
        if (!mounted || _exiting) return;
        setState(() {
          _combo = combo;
          _streak = max(_streak, combo);
        });
      },
      onFeedback: (text, isError) {
        if (!mounted || _exiting) return;
        setState(() {
          _feedback = text;
          _feedbackError = isError;
          if (isError) _hudShakeTick++;
        });
      },
      onWorldCleanChanged: (v) {
        if (!mounted || _exiting) return;
        setState(() => _worldClean = v.clamp(0.0, 1.0));
      },
      onSuccessJuice: (success, delta) async {
        if (_exiting) return;
        if (success) {
          await SoundService.instance.success();
          if (_combo > 0 && _combo % 3 == 0) {
            await SoundService.instance.bonus();
          }
        } else {
          await SoundService.instance.wrong();
        }
      },
      onGameComplete: (score, stars) {
        _safeComplete(score, stars);
      },
    );
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = async.Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _exiting) return;
      if (_timeLeft <= 1) {
        _timer?.cancel();
        final stars = _score >= 120
            ? 3
            : _score >= 70
            ? 2
            : _score >= 30
            ? 1
            : 0;
        _safeComplete(_score, stars);
        return;
      }
      setState(() => _timeLeft--);
    });
  }

  void _safeComplete(int score, int stars) {
    if (_exiting || !mounted) return;
    _exiting = true;
    _timer?.cancel();
    widget.onComplete(score, stars);
  }

  void _handleExit() {
    if (_exiting) return;
    _exiting = true;
    _timer?.cancel();
    widget.onExit?.call();
  }

  void _spawnBins() {
    if (_binsSpawned) return;
    final gameSize = _game.size;
    if (gameSize.x < 120 || gameSize.y < 220) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _spawnBins());
      return;
    }
    _binsSpawned = true;
    final types = TrashType.values;
    final horizontalPadding = (gameSize.x * .1).clamp(18.0, 36.0);
    final usableWidth = gameSize.x - (horizontalPadding * 2);
    final spacing = usableWidth / (types.length - 1);
    final y = gameSize.y * .84;
    for (int i = 0; i < types.length; i++) {
      _game.add(
        RecycleBin(
          type: types[i],
          position: Vector2(horizontalPadding + (spacing * i), y),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _spawnBins());
    final progress = (_score / (widget.targetItems * 20)).clamp(0.0, 1.0);
    return Stack(
      children: [
        _buildWorldCleanLayer(),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              10,
              _topHudReserved,
              10,
              _bottomHudReserved,
            ),
            child: GameWidget(game: _game),
          ),
        ),
        _buildTopHud(progress),
        _buildBottomHint(),
      ],
    );
  }

  Widget _buildWorldCleanLayer() {
    final dirty = (1 - _worldClean).clamp(0.0, 1.0);
    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.lerp(
                const Color(0xFF1E1B4B),
                const Color(0xFF0D9488),
                _worldClean,
              )!,
              Color.lerp(
                const Color(0xFF1E3A8A),
                const Color(0xFF16A34A),
                _worldClean,
              )!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 38,
              top: 210,
              child: Opacity(
                opacity: dirty * .4,
                child: const Text('🛢️', style: TextStyle(fontSize: 26)),
              ),
            ),
            Positioned(
              right: 48,
              top: 236,
              child: Opacity(
                opacity: _worldClean * .7,
                child: const Text('🐟', style: TextStyle(fontSize: 26)),
              ),
            ),
            Positioned(
              left: 42,
              bottom: 180,
              child: Opacity(
                opacity: _worldClean * .7,
                child: const Text('🌿', style: TextStyle(fontSize: 24)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHud(double progress) {
    return Positioned(
      top: 8,
      right: 12,
      left: 12,
      child:
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .17),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .16),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (widget.onExit != null)
                          GestureDetector(
                            onTap: _handleExit,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .16),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          widget.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _HudChip(
                          icon: '⭐',
                          value: '$_score',
                          color: const Color(0xFFFACC15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _HudChip(
                          icon: '🔥',
                          value: 'x$_combo',
                          color: const Color(0xFFF97316),
                        ),
                        const SizedBox(width: 8),
                        _HudChip(
                          icon: '🏆',
                          value: '$_streak',
                          color: const Color(0xFF22C55E),
                        ),
                        const SizedBox(width: 8),
                        _HudChip(
                          icon: '⏱',
                          value: '$_timeLeft',
                          color: const Color(0xFF0EA5E9),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: Colors.white.withValues(
                                alpha: .22,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFFACC15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate(key: ValueKey(_hudShakeTick))
              .shake(
                duration: _feedbackError ? 300.ms : 0.ms,
                hz: 5,
                offset: const Offset(6, 0),
              ),
    );
  }

  Widget _buildBottomHint() {
    return Positioned(
      bottom: 14,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: .25)),
        ),
        child: Row(
          children: [
            const Text('⚡', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _feedback.isEmpty ? widget.instruction : _feedback,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: _feedbackError
                      ? const Color(0xFFFCA5A5)
                      : Colors.white.withValues(alpha: .92),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('🧠', style: TextStyle(fontSize: 20)),
          ],
        ),
      ).animate().fadeIn(duration: 320.ms).slideY(begin: .12, end: 0),
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  final String icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .24),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: .45)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
