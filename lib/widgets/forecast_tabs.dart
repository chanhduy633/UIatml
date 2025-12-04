// ============================================
// FILE: lib/widgets/forecast_tabs.dart
// ============================================
import 'package:flutter/material.dart';

class ForecastTabs extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabSelected;

  const ForecastTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(59, 91, 219, 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.access_time,
              color: Color(0xFF3B5BDB),
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Dự báo vùng ngập',
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          const Spacer(),
          _buildTimeTab('24h', 0),
          _buildTimeTab('48h', 1),
          _buildTimeTab('72h', 2),
        ],
      ),
    );
  }

  Widget _buildTimeTab(String label, int index) {
    bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B5BDB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B5BDB) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
