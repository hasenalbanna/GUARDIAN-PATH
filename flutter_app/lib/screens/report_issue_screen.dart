import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'Road/Pothole';
  final List<String> _categories = [
    'Road/Pothole',
    'Flooding',
    'Elephant Conflict',
    'Power Outage',
    'Dengue Outbreak',
    'Water Shortage',
    'Landslide',
    'Wildfire',
    'Coastal Erosion',
    'Protest/Roadblock',
    'Other'
  ];
  
  final _otherCategoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final _mapController = MapController();
  LatLng _selectedLocation = LatLng(6.9015, 79.9140); // Default to Sri Lanka
  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = false;

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null) return;
    
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submitIssue() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      String title = _selectedCategory == 'Other' ? _otherCategoryController.text.trim() : _selectedCategory;
      
      await FirebaseFirestore.instance.collection('issues').add({
        'title': title,
        'description': _descriptionController.text.trim(),
        'latitude': _selectedLocation.latitude,
        'longitude': _selectedLocation.longitude,
        'incidentDateTime': _selectedDateTime.toIso8601String(),
        'userId': user?.uid ?? 'anonymous',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue reported successfully')));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to report issue: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Issue Type', border: OutlineInputBorder()),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
                if (_selectedCategory == 'Other') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _otherCategoryController,
                    decoration: const InputDecoration(labelText: 'Specify Issue', border: OutlineInputBorder()),
                    validator: (val) => val == null || val.isEmpty ? 'Please specify the issue' : null,
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 4,
                  validator: (val) => val == null || val.isEmpty ? 'Description is compulsory' : null,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date & Time of Incident'),
                  subtitle: Text(
                    "${_selectedDateTime.toLocal()}".split('.')[0],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDateTime,
                ),
                const SizedBox(height: 16),
                const Text('Select Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Tap anywhere on the map to place the marker.', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Container(
                  height: 250,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: _selectedLocation,
                      zoom: 14,
                      onTap: (tapPosition, point) {
                        setState(() {
                          _selectedLocation = point;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedLocation,
                            width: 40,
                            height: 40,
                            builder: (ctx) => const Icon(Icons.location_on, size: 40, color: Colors.black),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : FilledButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Text('Submit Report', style: TextStyle(fontSize: 16)),
                        ),
                        onPressed: _submitIssue,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
