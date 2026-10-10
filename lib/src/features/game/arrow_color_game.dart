import 'dart:math';

import 'package:flutter/material.dart';

class ArrowColorGameWidget extends StatefulWidget {
  const ArrowColorGameWidget({super.key, required this.onComplete});

  final void Function(int score, int stars) onComplete;

  @override
  State<ArrowColorGameWidget> createState() => _ArrowColorGameWidgetState();
}

class _ArrowColorGameWidgetState extends State<ArrowColorGameWidget> {
  static const _rounds = 6;
  final _rand = Random();
  final _palette = const [
    (name: 'أحمر', color: Color(0xFFEF4444)),
    (name: 'أزرق', color: Color(0xFF3B82F6)),
    (name: 'أخضر', color: Color(0xFF22C55E)),
    (name: 'أصفر', color: Color(0xFFFACC15)),
  ];

  int _round = 1;
  int _score = 0;
  int _correct = 0;
  late int _target;

  @override
  void initState() {
    super.initState();
    _target = _rand.nextInt(_palette.length);
  }

  void _pick(int index) {
    if (index == _target) {
      _score += 20;
      _correct++;
    } else {
      _score = max(0, _score - 5);
    }

    if (_round >= _rounds) {
      final stars = _correct >= 5
          ? 3
          : _correct >= 3
          ? 2
          : _correct >= 1
          ? 1
          : 0;
      widget.onComplete(_score, stars);
      return;
    }

    setState(() {
      _round++;
      _target = _rand.nextInt(_palette.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final target = _palette[_target];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 88, 20, 24),
      child: Column(
        children: [
          Text(
            'المستوى $_round/$_rounds  •  النقاط $_score',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: .25)),
            ),
            child: Column(
              children: [
                const Text(
                  'اختر لون السهم الصحيح',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 110,
                  color: target.color,
                ),
                const SizedBox(height: 8),
                Text(
                  target.name,
                  style: TextStyle(
                    color: target.color,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(_palette.length, (i) {
              final item = _palette[i];
              return ElevatedButton(
                onPressed: () => _pick(i),
                style: ElevatedButton.styleFrom(
                  backgroundColor: item.color,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(130, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
