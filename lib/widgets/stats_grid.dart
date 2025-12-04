// ============================================
// FILE: lib/widgets/stats_grid.dart
// ============================================
import 'package:flutter/material.dart';
import '../models/rescue_point.dart';

class StatsGrid extends StatelessWidget {
  final List<RescuePoint> rescuePoints;

  const StatsGrid({super.key, required this.rescuePoints});

  @override
  Widget build(BuildContext context) {
    int needHelp = rescuePoints.where((p) => !p.isSafe).length;
    int safe = rescuePoints.where((p) => p.isSafe).length;
    int totalPeople = rescuePoints.fold(0, (sum, p) => sum + p.totalPeople);
    int helpedPeople = rescuePoints
        .where((p) => p.isSafe)
        .fold(0, (sum, p) => sum + p.totalPeople);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Cần trợ giúp',
                  needHelp.toString(),
                  const Color(0xFFFA5252),
                  Icons.warning_amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Đã an toàn',
                  safe.toString(),
                  const Color(0xFF40C057),
                  Icons.check_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Tổng số người',
                  totalPeople.toString(),
                  const Color(0xFF3B5BDB),
                  Icons.people_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Người an toàn',
                  helpedPeople.toString(),
                  const Color(0xFF40C057),
                  Icons.verified_user,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
