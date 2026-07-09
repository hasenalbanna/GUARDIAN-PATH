import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'report_issue_screen.dart';
import 'community_feed.dart';
import 'issue_detail_screen.dart';
import 'login_screen.dart';
import 'assistant_screen.dart'; // We'll extract this next

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _mapController = MapController();
  final _center = LatLng(6.9015, 79.9140);
  bool _showLiveMap = false;

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildMapView(context),
      const CommunityFeed(),
      const AssistantScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/guardian-path.png', width: 36, height: 36),
            const SizedBox(width: 8),
            const Text('Guardian Path'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: pages[_index],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Normal SOS logic or report issue
          // We also have report issue which the user asked for.
          // Let's make this floating action open the report issue screen.
          // Or SOS is different? The user said "report an issue where some details should ask".
          // I will change this to Report Issue, and keep a separate button for SOS if needed, or maybe just Report Issue.
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportIssueScreen()));
        },
        label: const Text('Report Issue'),
        icon: const Icon(Icons.warning_amber_rounded),
        backgroundColor: Colors.red,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Assistant'),
        ],
      ),
    );
  }

  Widget _buildMapView(BuildContext context) {
    if (!_showLiveMap) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.map_outlined, size: 72, color: Colors.deepPurple),
              const SizedBox(height: 16),
              const Text(
                'Live map is ready to load',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap below after the emulator is fully online to fetch the free OpenStreetMap tiles.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => setState(() => _showLiveMap = true),
                child: const Text('Load Live Map'),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
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
                  builder: (ctx) => GestureDetector(
                    onTap: () {
                      _showIssuePopup(context, doc.id, data);
                    },
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
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
              userAgentPackageName: 'com.example.guardian_path',
            ),
            MarkerLayer(markers: markers),
          ],
        );
      },
    );
  }

  void _showIssuePopup(BuildContext context, String issueId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(data['title'] ?? 'Reported Issue', style: const TextStyle(color: Colors.red)),
        content: Text(data['description'] ?? 'No description provided.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => IssueDetailScreen(issueId: issueId, issueData: data)));
            },
            child: const Text('View Details'),
          )
        ],
      ),
    );
  }
}
