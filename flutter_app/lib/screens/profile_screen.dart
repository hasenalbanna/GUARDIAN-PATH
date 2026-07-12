import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme_notifier.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeNotifier.value == ThemeMode.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: const [
                            Text('EN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Icon(Icons.keyboard_arrow_down, size: 16),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        radius: 16,
                        child: Text(
                          'H',
                          style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Profile Picture
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      )
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/guardian-path.png'), // placeholder
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                )
              ],
            ),
            
            const SizedBox(height: 16),
            const Text(
              'HASEN AL BANNA.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'hasen.banna119@gmail.com',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            
            const SizedBox(height: 32),
            
            // Email Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                children: [
                  Icon(Icons.mail_outline, color: Colors.grey.shade600),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('EMAIL', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                      const Text('hasen.banna119@gmail.com', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Edit Profile Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  foregroundColor: Theme.of(context).primaryColor,
                ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: () {}, // placeholder
              ),
            ),
            
            const SizedBox(height: 32),
            const Divider(height: 1),
            const SizedBox(height: 16),
            
            // Action List
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
              leading: Icon(Icons.chat_bubble_outline, color: Theme.of(context).primaryColor),
              title: const Text('Message Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              onTap: () {}, // placeholder
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Sign Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red)),
              onTap: () => _signOut(context),
            ),
          ],
        ),
      ),
    );
  }
}
