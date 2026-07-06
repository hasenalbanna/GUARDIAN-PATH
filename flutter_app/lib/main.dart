import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const GuardianPathApp());
}

class GuardianPathApp extends StatelessWidget {
  const GuardianPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian Path',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _mapController = MapController();
  final _center = LatLng(6.9015, 79.9140);

  @override
  Widget build(BuildContext context) {
    final pages = [buildMapView(context), buildCommunityView(), buildAssistantView()];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/guardian-path.png', width: 36, height: 36),
            const SizedBox(width: 8),
            const Text('Guardian Path'),
          ],
        ),
      ),
      body: pages[_index],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // SOS action
          showDialog(context: context, builder: (_) => AlertDialog(title: const Text('SOS'), content: const Text('Emergency SOS triggered')));
        },
        label: const Text('SOS'),
        icon: const Icon(Icons.phone_iphone),
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

  Widget buildMapView(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(center: _center, zoom: 14),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.guardian_path',
          attributionBuilder: (_) {
            return const Text('© OpenStreetMap contributors', style: TextStyle(fontSize: 10));
          },
        ),
      ],
    );
  }

  Widget buildCommunityView() {
    return const Center(child: Text('Community feed (placeholder)'));
  }

  Widget buildAssistantView() {
    return AssistantWidget();
  }
}

class AssistantWidget extends StatefulWidget {
  @override
  State<AssistantWidget> createState() => _AssistantWidgetState();
}

class _AssistantWidgetState extends State<AssistantWidget> {
  final _controller = TextEditingController();
  final List<String> _messages = [];

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _messages.add('You: $text'));
    _controller.clear();

    // Try to call Gemini endpoint if API key provided in .env as GP_API_KEY
    final apiKey = dotenv.env['GP_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      setState(() => _messages.add('Assistant: (offline stub) Stay calm; move to well-lit area.'));
      return;
    }

    try {
      final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-09-2025:generateContent?key=$apiKey');
      final resp = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: '{"contents":[{"parts":[{"text":"$text"}]}],"systemInstruction":{"parts":[{"text":"You are a concise safety assistant."}]}}');
      if (resp.statusCode == 200) {
        setState(() => _messages.add('Assistant: (live) Response received'));
      } else {
        setState(() => _messages.add('Assistant: (error ${resp.statusCode})'));
      }
    } catch (e) {
      setState(() => _messages.add('Assistant: (request failed)'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(_messages[i]),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
              Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Ask the Safety Assistant...'))),
              IconButton(icon: const Icon(Icons.send), onPressed: _send),
            ]),
          ),
        ),
      ],
    );
  }
}
