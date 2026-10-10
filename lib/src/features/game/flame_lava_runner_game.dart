import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class LavaRunnerMiniGame extends FlameGame {
  LavaRunnerMiniGame({
    required this.onScoreChanged,
    required this.onTimeChanged,
    required this.onGameComplete,
    this.levelDuration = 40,
  });

  final void Function(int score) onScoreChanged;
  final void Function(int secondsLeft) onTimeChanged;
  final void Function(int score, int stars) onGameComplete;
  final int levelDuration;

  final Random _rand = Random();
  _RunnerPlayer? _player;
  final List<_LavaObstacle> _obstacles = [];

  double _spawnTimer = 0;
  int _score = 0;
  double _timeLeft = 0;
  bool _ended = false;
  double _scoreAccumulator = 0;
  int _lastReportedSecond = -1;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _timeLeft = levelDuration.toDouble();
    _player = _RunnerPlayer();
    add(_player!);
    _updateHud();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_player != null) {
      _player!.position = Vector2(size.x * .18, size.y * .72);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_ended || !isLoaded) {
      return;
    }

    _timeLeft -= dt;
    if (_timeLeft <= 0) {
      _completeWithSuccess();
      return;
    }

    _scoreAccumulator += dt * 10;
    if (_scoreAccumulator >= 1) {
      final gain = _scoreAccumulator.floor();
      _scoreAccumulator -= gain;
      _score += gain;
      onScoreChanged(_score);
    }

    _spawnTimer -= dt;
    if (_spawnTimer <= 0) {
      _spawnTimer = 1.1 + _rand.nextDouble() * 0.9;
      _spawnObstacle();
    }

    _checkCollisions();
    _cleanupPassedObstacles();
    _updateHud();
  }

  void jump() {
    if (_ended || !isLoaded) {
      return;
    }
    _player?.jump();
  }

  void _spawnObstacle() {
    final obstacle = _LavaObstacle(
      position: Vector2(size.x + 30, size.y * .8),
      speed: 190 + _rand.nextDouble() * 70,
      width: 34 + _rand.nextDouble() * 12,
      height: 42 + _rand.nextDouble() * 32,
    );
    _obstacles.add(obstacle);
    add(obstacle);
  }

  void _checkCollisions() {
    final player = _player;
    if (player == null) return;
    final playerRect = player.hitRect;
    for (final obstacle in _obstacles) {
      if (playerRect.overlaps(obstacle.hitRect)) {
        _completeWithFail();
        return;
      }
    }
  }

  void _cleanupPassedObstacles() {
    _obstacles.removeWhere((obs) {
      if (obs.position.x + obs.size.x < -50) {
        obs.removeFromParent();
        _score += 8;
        onScoreChanged(_score);
        return true;
      }
      return false;
    });
  }

  void _completeWithSuccess() {
    _ended = true;
    final stars = _score >= 520
        ? 3
        : _score >= 320
        ? 2
        : 1;
    onGameComplete(_score, stars);
  }

  void _completeWithFail() {
    _ended = true;
    final stars = _score >= 240 ? 1 : 0;
    onGameComplete(_score, stars);
  }

  void _updateHud() {
    final currentSecond = _timeLeft.ceil().clamp(0, 999);
    if (currentSecond != _lastReportedSecond) {
      _lastReportedSecond = currentSecond;
      onTimeChanged(currentSecond);
    }
  }
}

class _RunnerPlayer extends PositionComponent
    with HasGameReference<LavaRunnerMiniGame> {
  _RunnerPlayer() : super(size: Vector2(44, 56), anchor: Anchor.center);

  double _velocityY = 0;
  final double _gravity = 900;
  final double _jumpForce = -440;
  bool _onGround = true;

  Rect get hitRect => Rect.fromLTWH(
    position.x - size.x / 2,
    position.y - size.y / 2,
    size.x,
    size.y,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      RectangleComponent(
        size: size,
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xFF34D399),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    final groundY = game.size.y * .72;
    _velocityY += _gravity * dt;
    position.y += _velocityY * dt;

    if (position.y >= groundY) {
      position.y = groundY;
      _velocityY = 0;
      _onGround = true;
    }
  }

  void jump() {
    if (_onGround) {
      _onGround = false;
      _velocityY = _jumpForce;
    }
  }
}

class _LavaObstacle extends PositionComponent {
  _LavaObstacle({
    required super.position,
    required this.speed,
    required double width,
    required double height,
  }) : super(size: Vector2(width, height), anchor: Anchor.bottomCenter);

  final double speed;

  Rect get hitRect => Rect.fromLTWH(
    position.x - size.x / 2,
    position.y - size.y,
    size.x,
    size.y,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      RectangleComponent(
        size: size,
        anchor: Anchor.bottomCenter,
        paint: Paint()..color = const Color(0xFFEF4444),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt;
  }
}

class LavaRunnerWidget extends StatefulWidget {
  const LavaRunnerWidget({
    super.key,
    required this.onComplete,
    this.title = 'عدّاء اللهب',
  });

  final void Function(int score, int stars) onComplete;
  final String title;

  @override
  State<LavaRunnerWidget> createState() => _LavaRunnerWidgetState();
}

class _LavaRunnerWidgetState extends State<LavaRunnerWidget> {
  late LavaRunnerMiniGame _game;
  int _score = 0;
  int _timeLeft = 40;

  @override
  void initState() {
    super.initState();
    _game = LavaRunnerMiniGame(
      onScoreChanged: (s) {
        if (_score == s) {
          return;
        }
        _setStateSafely(() => _score = s);
      },
      onTimeChanged: (t) {
        if (_timeLeft == t) {
          return;
        }
        _setStateSafely(() => _timeLeft = t);
      },
      onGameComplete: widget.onComplete,
    );
  }

  void _setStateSafely(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    final phase = SchedulerBinding.instance.schedulerPhase;
    final isBuildingFrame =
        phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.transientCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks;
    if (isBuildingFrame) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(fn);
        }
      });
      return;
    }
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GameWidget(game: _game),
        Positioned(
          left: 12,
          right: 12,
          top: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: .22)),
            ),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  '⏱️ $_timeLeft',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '⭐ $_score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 26,
          child: Center(
            child: GestureDetector(
              onTap: _game.jump,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .35),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'اقفز',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
