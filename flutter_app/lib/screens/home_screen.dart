import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'report_issue_screen.dart';
import 'community_feed.dart';
import 'issue_detail_screen.dart';
import 'login_screen.dart';
import '../theme_notifier.dart'; // to access themeNotifier

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _mapController = MapController();
  final _center = LatLng(6.9015, 79.9140);
  bool _isMapExpanded = false;

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (_index != 0) {
      // Temporary placeholder, soon to be replaced with actual screens
      return Scaffold(
        body: Center(child: Text("Tab $_index coming soon...")),
        bottomNavigationBar: _buildCustomBottomNav(),
        floatingActionButton: _buildCustomFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      );
    }

    final isDark = themeNotifier.value == ThemeMode.dark;
    
    return Scaffold(
      extendBody: true, 
      body: Column(
        children: [
          // Custom Top Bar (Hidden when map is full screen)
          if (!_isMapExpanded)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Hello, HASEN',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                          onPressed: () {
                            themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                          },
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          child: Text(
                            'H',
                            style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          // Split View: Map & Reports
          Expanded(
            child: Stack(
              children: [
                // 1. MAP LAYER 
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: _isMapExpanded ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height * 0.45,
                  child: _buildMapLayer(),
                ),
                // 2. BOTTOM SHEET LAYER (Hidden when map is expanded)
                if (!_isMapExpanded)
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.40,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          )
                        ],
                      ),
                      child: _buildRecentReportsList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isMapExpanded ? null : _buildCustomFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _isMapExpanded ? null : _buildCustomBottomNav(),
    );
  }

  Widget _buildMapLayer() {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('issues').snapshots(),
          builder: (context, snapshot) {
            List<Marker> markers = [];
            if (snapshot.hasData) {
              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                if (data['latitude'] != null && data['longitude'] != null) {
                  markers.add(
                    Marker(
                      point: LatLng(data['latitude'], data['longitude']),
                      width: 40,
                      height: 40,
                      builder: (ctx) => const Icon(Icons.location_on, color: Colors.black, size: 30),
                    ),
                  );
                }
              }
            }
            return FlutterMap(
              mapController: _mapController,
              options: MapOptions(center: _center, zoom: 14),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: markers),
              ],
            );
          },
        ),
        // Map Controls (Expand/Collapse)
        Positioned(
          bottom: _isMapExpanded ? 40 : 100, // adjust position based on expansion
          right: 16,
          child: FloatingActionButton(
            mini: true,
            heroTag: 'map_expand_btn',
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            onPressed: () => setState(() => _isMapExpanded = !_isMapExpanded),
            child: Icon(_isMapExpanded ? Icons.close_fullscreen : Icons.open_in_full),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentReportsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drag Handle Indicator
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Reports',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('issues').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.black));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No recent reports."));
              }
              return ListView.builder(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100), // bottom padding for nav bar
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, i) {
                  final data = snapshot.data!.docs[i].data() as Map<String, dynamic>;
                  return _buildReportCard(data);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: const Icon(Icons.location_on_outlined, size: 24),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (data['title'] ?? 'UNKNOWN').toString().toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      'Just now', // Placeholder for date
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data['description'] ?? 'No details',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Ampara District, Eastern Province, Sri Lanka', // Placeholder location string
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCustomFab() {
    final isDark = themeNotifier.value == ThemeMode.dark;
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportIssueScreen()));
      },
      backgroundColor: isDark ? Colors.white : Colors.black,
      foregroundColor: isDark ? Colors.black : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: const Icon(Icons.add, size: 28),
    );
  }

  Widget _buildCustomBottomNav() {
    final isDark = themeNotifier.value == ThemeMode.dark;
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_filled, 'Home', 0),
              _buildNavItem(Icons.people_alt_outlined, 'Community', 1),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(Icons.description_outlined, 'My Issues', 2),
              _buildNavItem(Icons.person_outline, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _index == index;
    return GestureDetector(
      onTap: () => setState(() => _index = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
