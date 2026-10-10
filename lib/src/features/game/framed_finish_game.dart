import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';

class FramedFinishGameWidget extends StatefulWidget {
  const FramedFinishGameWidget({super.key, required this.onComplete});

  final void Function(int score, int stars) onComplete;

  @override
  State<FramedFinishGameWidget> createState() => _FramedFinishGameWidgetState();
}

class _FramedFinishGameWidgetState extends State<FramedFinishGameWidget> {
  final _rand = Random();
  Timer? _ticker;
  int _round = 1;
  int _score = 0;
  int _perfect = 0;
  double _target = .5;
  double _cursor = .1;
  bool _forward = true;

  @override
  void initState() {
    super.initState();
    _target = .3 + _rand.nextDouble() * .4;
    _ticker = Timer.periodic(const Duration(milliseconds: 28), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _cursor += (_forward ? 0.012 : -0.012);
        if (_cursor >= 1) _forward = false;
        if (_cursor <= 0) _forward = true;
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 88, 18, 20),
      child: Column(
        children: [
          Text(
            'الإطار الذهبي $_round/6  •  النقاط $_score',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
              ),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 16),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'اضغط عندما يصل المؤشر إلى المنطقة الذهبية',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Stack(
                  children: [
                    Container(
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Positioned(
                      left: _target * (MediaQuery.of(context).size.width - 110),
                      child: Container(
                        width: 56,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE047),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Positioned(
                      left: _cursor * (MediaQuery.of(context).size.width - 74),
                      child: Container(
                        width: 20,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _hit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4C1D95),
                    minimumSize: const Size(170, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'اضغط',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _hit() {
    final ok = (_cursor - _target).abs() <= .06;
    if (ok) {
      _score += 30;
      _perfect++;
    } else {
      _score = max(0, _score - 8);
    }
    if (_round >= 6) {
      final stars = _perfect >= 4
          ? 3
          : _perfect >= 2
          ? 2
          : _perfect >= 1
          ? 1
          : 0;
      widget.onComplete(_score, stars);
      return;
    }
    setState(() {
      _round++;
      _target = .2 + _rand.nextDouble() * .6;
    });
  }
}
