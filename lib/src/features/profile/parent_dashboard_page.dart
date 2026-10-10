import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/models/models.dart';
import '../../data/services/providers.dart';
import '../../shared/kids_widgets.dart';
import '../../shared/parent_lock_gate.dart';

class ParentDashboardPage extends ConsumerWidget {
  const ParentDashboardPage({super.key});

  static const _labels = {
    'colors': 'الألوان',
    'animals': 'الحيوانات',
    'numbers': 'الأرقام',
    'memory': 'الذاكرة',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          const CinematicGameBackground(),
          SafeArea(
            child: Column(
              children: [
                _TopBar(),
                Expanded(
                  child: ParentLockGate(
                    title: 'لوحة متابعة الولي',
                    child: FutureBuilder<List<WorldProgress>>(
                      future: ref.read(gameRepositoryProvider).getWorldProgress(),
                      builder: (context, snapshot) {
                        final data = snapshot.data ?? [];
                        final totalStars = data.fold<int>(0, (sum, e) => sum + e.stars);
                        final totalProgress = data.isEmpty
                            ? 0.0
                            : data
                                    .map(
                                      (e) =>
                                          e.completedLevels /
                                          (e.totalLevels == 0 ? 1 : e.totalLevels),
                                    )
                                    .reduce((a, b) => a + b) /
                                data.length;

                        return ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            GlassCard(
                              borderRadius: 22,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ملخص سريع',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'إجمالي النجوم: $totalStars ⭐',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'نسبة التقدم العام: ${(totalProgress * 100).round()}%',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: .9),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 170,
                                    child: PieChart(
                                      PieChartData(
                                        centerSpaceRadius: 36,
                                        sectionsSpace: 2,
                                        sections: [
                                          PieChartSectionData(
                                            value: (totalProgress * 100).clamp(0, 100),
                                            color: const Color(0xFF66BB6A),
                                            title: '${(totalProgress * 100).round()}%',
                                            titleStyle: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                            radius: 54,
                                          ),
                                          PieChartSectionData(
                                            value: (100 - (totalProgress * 100)).clamp(0, 100),
                                            color: Colors.white.withValues(alpha: .18),
                                            title: '',
                                            radius: 48,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'نجوم كل عالم',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GlassCard(
                              borderRadius: 22,
                              child: SizedBox(
                                height: 220,
                                child: BarChart(
                                  BarChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: Colors.white.withValues(alpha: .12),
                                          strokeWidth: 1,
                                        );
                                      },
                                    ),
                                    borderData: FlBorderData(show: false),
                                    titlesData: FlTitlesData(
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          getTitlesWidget: (value, meta) => Text(
                                            value.toInt().toString(),
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: .85),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            const names = ['ألوان', 'حيوانات', 'أرقام', 'ذاكرة'];
                                            final index = value.toInt();
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 6),
                                              child: Text(
                                                index < names.length ? names[index] : '',
                                                style: TextStyle(
                                                  color: Colors.white.withValues(alpha: .92),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    barGroups: List.generate(data.length, (index) {
                                      return BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          BarChartRodData(
                                            toY: data[index].stars.toDouble(),
                                            color: const Color(0xFF42A5F5),
                                            width: 22,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...data.map(_worldCard),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _worldCard(WorldProgress item) {
    final progress = item.totalLevels == 0 ? 0.0 : item.completedLevels / item.totalLevels;
    final label = _labels[item.worldId] ?? item.worldId;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(color: Colors.white.withValues(alpha: .9)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                backgroundColor: Colors.white.withValues(alpha: .2),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF42A5F5)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'المستويات المكتملة: ${item.completedLevels}/${item.totalLevels}',
              style: TextStyle(color: Colors.white.withValues(alpha: .9)),
            ),
            Text(
              'نجوم هذا العالم: ${item.stars} ⭐',
              style: TextStyle(color: Colors.white.withValues(alpha: .9)),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 260.ms);
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go(AppRoutes.settings),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: .25)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'لوحة متابعة الولي',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          const Text('📊', style: TextStyle(fontSize: 30)),
        ],
      ),
    ).animate().fadeIn(duration: 260.ms).slideY(begin: -.08, end: 0);
  }
}
