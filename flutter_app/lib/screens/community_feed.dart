import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'issue_detail_screen.dart';
import 'package:intl/intl.dart';

class CommunityFeed extends StatelessWidget {
  const CommunityFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('issues').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final issues = snapshot.data!.docs;
        if (issues.isEmpty) {
          return const Center(child: Text('No issues reported yet in your area.'));
        }

        return ListView.builder(
          itemCount: issues.length,
          itemBuilder: (context, index) {
            final doc = issues[index];
            final data = doc.data() as Map<String, dynamic>;
            final createdAt = data['createdAt'] as Timestamp?;
            final timeString = createdAt != null ? DateFormat('MMM dd, yyyy - hh:mm a').format(createdAt.toDate()) : 'Unknown time';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 2,
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => IssueDetailScreen(issueId: doc.id, issueData: data)));
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['title'] ?? 'Issue',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                          ),
                          Text(timeString, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data['description'] ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Icon(Icons.comment_outlined, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text('Discuss this issue', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
