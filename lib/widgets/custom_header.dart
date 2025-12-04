// ============================================
// FILE: lib/widgets/custom_header.dart
// ============================================
import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final int safeCount;
  final int needHelpCount;

  const CustomHeader({
    super.key,
    required this.safeCount,
    required this.needHelpCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4C6EF5), Color(0xFF3B5BDB)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'DB',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          //   decoration: BoxDecoration(
          //     color: const Color(0xFF3B5BDB),
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   child: const Row(
          //     children: [
          //       Text(
          //         'Bản đồ cứu trợ',
          //         style: TextStyle(color: Colors.white, fontSize: 14),
          //       ),
          //       SizedBox(width: 4),
          //       Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
          //     ],
          //   ),
          // ),
          const Spacer(),
          _buildChip('An toàn: $safeCount', const Color(0xFF40C057), true),
          const SizedBox(width: 8),
          _buildChip(
            'Cần trợ giúp: $needHelpCount',
            const Color(0xFFFA5252),
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color, bool hasCheck) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            hasCheck ? Icons.check_circle : Icons.warning,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
