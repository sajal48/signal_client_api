import 'package:flutter/material.dart';
import 'package:signal_protocol_flutter/signal_protocol_flutter.dart';
import '../services/signal_service.dart';

class SetupScreen extends StatefulWidget {
  final SignalService signalService;
  final VoidCallback onInitialized;

  const SetupScreen({
    super.key,
    required this.signalService,
    required this.onInitialized,
  });

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _userIdController = TextEditingController();
  final _firebaseUrlController = TextEditingController();
  bool _isInitializing = false;
  String? _errorMessage;
  Map<String, dynamic>? _instanceInfo;

  @override
  void initState() {
    super.initState();
    _loadInstanceInfo();
  }

  Future<void> _loadInstanceInfo() async {
    try {
      if (await widget.signalService.isInitialized()) {
        final info = await widget.signalService.getInstanceInfo();
        setState(() {
          _instanceInfo = info;
        });
      }
    } catch (e) {
      // Ignore error if not initialized
    }
  }

  Future<void> _initialize() async {
    final userId = _userIdController.text.trim();
    final firebaseUrl = _firebaseUrlController.text.trim();

    if (userId.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a user ID';
      });
      return;
    }

    if (firebaseUrl.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a Firebase URL';
      });
      return;
    }

    // Validate user ID format
    if (!widget.signalService.isValidUserId(userId)) {
      setState(() {
        _errorMessage = 'Invalid user ID format. Use alphanumeric characters, dots, underscores, and hyphens only.';
      });
      return;
    }

    // Validate Firebase URL format
    if (!widget.signalService.isValidFirebaseUrl(firebaseUrl)) {
      setState(() {
        _errorMessage = 'Invalid Firebase URL format.';
      });
      return;
    }

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      // For this example, we'll create a simple FirebaseConfig-like object
      // In a real app, you would use the actual Firebase configuration
      final firebaseConfig = FirebaseConfig();
      await FirebaseConfig.initialize(databaseURL: firebaseUrl);

      await widget.signalService.initialize(
        userId: userId,
        firebaseConfig: firebaseConfig,
      );

      await _loadInstanceInfo();
      widget.onInitialized();

      setState(() {
        _isInitializing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signal Protocol initialized successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Initialization failed: $e';
      });
    }
  }

  Future<void> _uploadKeys() async {
    try {
      await widget.signalService.uploadKeys();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Keys uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _loadInstanceInfo();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload keys: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Signal Protocol Setup',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            // User ID Input
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                hintText: 'Enter your unique user ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Firebase URL Input
            TextField(
              controller: _firebaseUrlController,
              decoration: const InputDecoration(
                labelText: 'Firebase Database URL',
                hintText: 'https://your-project.firebaseio.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Error Message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Initialize Button
            ElevatedButton(
              onPressed: _isInitializing ? null : _initialize,
              child: _isInitializing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Initializing...'),
                      ],
                    )
                  : const Text('Initialize Signal Protocol'),
            ),
            
            const SizedBox(height: 16),
            
            // Upload Keys Button (only if initialized)
            if (_instanceInfo != null && _instanceInfo!['isInitialized'] == true)
              ElevatedButton(
                onPressed: _uploadKeys,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Upload Keys to Firebase'),
              ),
            
            const SizedBox(height: 24),
            
            // Instance Info
            if (_instanceInfo != null) ...[
              const Text(
                'Instance Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _instanceInfo!.entries
                      .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('${e.key}: ${e.value}'),
                          ))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _firebaseUrlController.dispose();
    super.dispose();
  }
}
