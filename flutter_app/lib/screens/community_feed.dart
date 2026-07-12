import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityFeed extends StatelessWidget {
  const CommunityFeed({super.key});

  void _callNumber(String number) async {
    final Uri url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('SOS / Emergency', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Sri Lanka Emergency Contacts',
            style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildEmergencyCard(
            context,
            'Police Emergency',
            '119',
            Icons.local_police,
            Colors.blue.shade800,
          ),
          _buildEmergencyCard(
            context,
            'Ambulance (Suwa Seriya)',
            '1990',
            Icons.medical_services,
            Colors.green.shade600,
          ),
          _buildEmergencyCard(
            context,
            'Disaster Management Center',
            '117',
            Icons.warning_amber_rounded,
            Colors.orange.shade700,
          ),
          _buildEmergencyCard(
            context,
            'Fire and Rescue',
            '110',
            Icons.local_fire_department,
            Colors.red.shade700,
          ),
          _buildEmergencyCard(
            context,
            'Tourist Police',
            '1912',
            Icons.flight_takeoff,
            Colors.teal.shade700,
          ),
          const SizedBox(height: 32),
          const Text(
            'Community Protocols',
            style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            'What to do during a Flood',
            'Move to higher ground immediately. Avoid walking or driving through flood waters. Disconnect electrical appliances.',
            Icons.water_drop,
          ),
          _buildInfoCard(
            context,
            'Elephant Conflict Protocol',
            'Do not approach the elephant. Make loud noises to scare it away if safe. Contact the wildlife department.',
            Icons.pets,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(BuildContext context, String title, String number, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          radius: 24,
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text('Call $number', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        trailing: IconButton(
          icon: const Icon(Icons.phone, color: Colors.green, size: 28),
          onPressed: () => _callNumber(number),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
