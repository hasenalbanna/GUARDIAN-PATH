import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme_notifier.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedTabIndex = 0; // 0 = Analytics, 1 = Issue Management, 2 = Users

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Admin Console', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          )
        ],
      ),
      body: Row(
        children: [
          // Side Navigation
          Container(
            width: 80,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                _buildNavIcon(Icons.dashboard, 0, 'Stats'),
                _buildNavIcon(Icons.report_problem, 1, 'Issues'),
                _buildNavIcon(Icons.people, 2, 'Users'),
                const Spacer(),
                _buildNavIcon(Icons.logout, -1, 'Exit'),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Content Area
          Expanded(
            child: _buildContentArea(),
          )
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == -1) {
          Navigator.pop(context); // exit admin panel
          return;
        }
        setState(() => _selectedTabIndex = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        color: isSelected ? Colors.grey.withOpacity(0.1) : Colors.transparent,
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.grey, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isSelected ? Theme.of(context).primaryColor : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildContentArea() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildAnalyticsTab();
      case 1:
        return _buildIssueManagementTab();
      case 2:
        return _buildUserManagementTab();
      default:
        return const Center(child: Text("Select a tab"));
    }
  }

  // --- ANALYTICS TAB ---
  Widget _buildAnalyticsTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today\'s Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard('Total Issues', '142', Icons.trending_up, Colors.blue),
              const SizedBox(width: 16),
              _buildStatCard('Resolved', '38', Icons.check_circle, Colors.green),
              const SizedBox(width: 16),
              _buildStatCard('Hotspot Area', 'Ampara', Icons.local_fire_department, Colors.orange),
            ],
          ),
          const SizedBox(height: 48),
          const Text('Issue Distribution (Mock Data)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Simple visual representation
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Chart integration pending\n(Top issues: Flooding, Elephants, Potholes)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
            Text(title, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // --- ISSUE MANAGEMENT TAB ---
  Widget _buildIssueManagementTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Manage Reports', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('issues').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No issues found."));
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(data['title'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(data['description'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          FirebaseFirestore.instance.collection('issues').doc(doc.id).delete();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue Deleted')));
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- USER MANAGEMENT TAB ---
  Widget _buildUserManagementTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Control Center', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
            leading: const CircleAvatar(child: Text('U')),
            title: const Text('user123@gmail.com', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Status: Genuine User (Trust Score: High)'),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User Banned from Platform')));
              },
              child: const Text('BAN USER'),
            ),
          ),
        ],
      ),
    );
  }
}
