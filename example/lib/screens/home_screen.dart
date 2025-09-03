import 'package:flutter/material.dart';
import '../services/signal_service.dart';
import 'setup_screen.dart';
import 'messaging_screen.dart';
import 'keys_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late SignalService _signalService;
  bool _isInitialized = false;
  String _status = 'Not initialized';

  @override
  void initState() {
    super.initState();
    _signalService = SignalService();
    _checkInitialization();
  }

  Future<void> _checkInitialization() async {
    try {
      final isInitialized = await _signalService.isInitialized();
      setState(() {
        _isInitialized = isInitialized;
        _status = isInitialized ? 'Initialized' : 'Not initialized';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  List<Widget> get _pages => [
    SetupScreen(
      signalService: _signalService,
      onInitialized: () {
        setState(() {
          _isInitialized = true;
          _status = 'Initialized';
        });
      },
    ),
    MessagingScreen(signalService: _signalService),
    KeysScreen(signalService: _signalService),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signal Protocol Flutter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Chip(
            label: Text(_status),
            backgroundColor: _isInitialized ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Setup',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messaging',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.key),
            label: 'Keys',
          ),
        ],
      ),
    );
  }
}
