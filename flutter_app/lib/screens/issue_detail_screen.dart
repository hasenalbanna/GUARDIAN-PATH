import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class IssueDetailScreen extends StatefulWidget {
  final String issueId;
  final Map<String, dynamic> issueData;

  const IssueDetailScreen({super.key, required this.issueId, required this.issueData});

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  final _commentController = TextEditingController();
  bool _isPosting = false;

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPosting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      // Fetch user name
      String userName = 'Anonymous';
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data()?['name'] != null) {
          userName = userDoc.data()!['name'];
        }
      }

      await FirebaseFirestore.instance.collection('issues').doc(widget.issueId).collection('comments').add({
        'text': text,
        'userId': user?.uid ?? 'anonymous',
        'userName': userName,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      _commentController.clear();
      FocusScope.of(context).unfocus(); // Dismiss keyboard
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to post comment: $e')));
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Issue Details')),
      body: Column(
        children: [
          // Issue Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.issueData['title'] ?? 'Issue',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.issueData['description'] ?? 'No description provided.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Divider(),
              ],
            ),
          ),
          
          // Comments Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('issues')
                  .doc(widget.issueId)
                  .collection('comments')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final comments = snapshot.data!.docs;
                if (comments.isEmpty) {
                  return const Center(child: Text('No comments yet. Be the first to discuss.'));
                }
                
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final commentData = comments[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              commentData['userName'] ?? 'Anonymous',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.deepPurple),
                            ),
                            const SizedBox(height: 4),
                            Text(commentData['text'] ?? ''),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Comment Input
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isPosting 
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send, color: Colors.deepPurple),
                        onPressed: _postComment,
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
