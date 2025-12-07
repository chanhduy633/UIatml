// screens/rescue_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../services/request_service.dart';
import '../services/auth_service.dart';

class RescueDashboardScreen extends StatefulWidget {
  const RescueDashboardScreen({super.key});

  @override
  State<RescueDashboardScreen> createState() => _RescueDashboardScreenState();
}

class _RescueDashboardScreenState extends State<RescueDashboardScreen> {
  String _selectedFilter = 'all'; // all, pending, in_progress

  void _logout() {
    AuthService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _refreshData() {
    setState(() {}); // Trigger rebuild
  }

  IconData _getTypeIcon(List<dynamic> conditions) {
    if (conditions.contains('Medical Emergency') ||
        conditions.contains('Chest Pain')) {
      return Icons.medical_services;
    } else if (conditions.contains('Vehicle Accident')) {
      return Icons.car_crash;
    } else if (conditions.contains('Fire')) {
      return Icons.local_fire_department;
    }
    return Icons.emergency;
  }

  String _getTypeLabel(List<dynamic> conditions) {
    if (conditions.contains('Medical Emergency') ||
        conditions.contains('Chest Pain')) {
      return 'Medical Emergency';
    } else if (conditions.contains('Vehicle Accident')) {
      return 'Vehicle Accident';
    } else if (conditions.contains('Fire')) {
      return 'Fire';
    }
    return 'Emergency';
  }

  String _getTimeSince(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    var requests = RequestService.getAllRequests();

    if (_selectedFilter != 'all') {
      requests = requests.where((r) => r.status == _selectedFilter).toList();
    }

    final stats = RequestService.getStatistics();

    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.red,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Rescue Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _refreshData,
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: _logout,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Statistics
                  Row(
                    children: [
                      _buildStatCard('Total', stats['total']!, Colors.blue),
                      const SizedBox(width: 8),
                      _buildStatCard('Pending', stats['pending']!, Colors.grey),
                      const SizedBox(width: 8),
                      _buildStatCard(
                          'Active', stats['in_progress']!, Colors.orange),
                      const SizedBox(width: 8),
                      _buildStatCard(
                          'Resolved', stats['resolved']!, Colors.green),
                    ],
                  ),
                ],
              ),
            ),

            // Filter Chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Active', 'in_progress'),
                ],
              ),
            ),

            // Request List
            Expanded(
              child: requests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No ${_selectedFilter == 'all' ? '' : _selectedFilter} requests',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        _refreshData();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final request = requests[index];
                          final conditions = request.conditions;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3A3A3A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade900,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getTypeIcon(conditions),
                                  color: Colors.red,
                                  size: 28,
                                ),
                              ),
                              title: Text(
                                '${request.name} - ${_getTypeLabel(conditions)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    request.address,
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _getTimeSince(request.requestTime),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/rescue-request-detail',
                                  arguments: request.toJson(),
                                ).then((_) => _refreshData());
                              },
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.red : Colors.white54,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
