import 'dart:math';

import 'package:flutter/material.dart';

class SpotDifferenceGameWidget extends StatefulWidget {
  const SpotDifferenceGameWidget({super.key, required this.onComplete});

  final void Function(int score, int stars) onComplete;

  @override
  State<SpotDifferenceGameWidget> createState() =>
      _SpotDifferenceGameWidgetState();
}

class _SpotDifferenceGameWidgetState extends State<SpotDifferenceGameWidget> {
  static const _rounds = 5;
  final _rand = Random();
  final _items = const ['🐟', '🌿', '⭐', '🐢', '💧', '♻️', '🌸'];

  int _round = 1;
  int _score = 0;
  int _correct = 0;
  late int _differentAt;
  late String _same;
  late String _different;

  @override
  void initState() {
    super.initState();
    _generateRound();
  }

  void _generateRound() {
    _differentAt = _rand.nextInt(6);
    _same = _items[_rand.nextInt(_items.length)];
    _different = _items[(_rand.nextInt(_items.length - 1) + 1) % _items.length];
    if (_different == _same) {
      _different = '🔥';
    }
  }

  void _tapCell(int index) {
    if (index == _differentAt) {
      _score += 24;
      _correct++;
    } else {
      _score = max(0, _score - 6);
    }

    if (_round >= _rounds) {
      final stars = _correct >= 4
          ? 3
          : _correct >= 2
          ? 2
          : _correct >= 1
          ? 1
          : 0;
      widget.onComplete(_score, stars);
      return;
    }

    setState(() {
      _round++;
      _generateRound();
    });
  }

  Widget _buildGrid({required bool withDifference}) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: 6,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (_, i) {
        final emoji = withDifference && i == _differentAt ? _different : _same;
        return GestureDetector(
          onTap: withDifference ? () => _tapCell(i) : null,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: .22)),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 34)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 88, 20, 20),
      child: Column(
        children: [
          Text(
            'الاختلاف $_round/$_rounds  •  النقاط $_score',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'اعثر على المربع المختلف في الصورة اليمنى',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildGrid(withDifference: false)),
                const SizedBox(width: 12),
                Expanded(child: _buildGrid(withDifference: true)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
