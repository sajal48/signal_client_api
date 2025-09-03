import 'package:flutter/material.dart';
import '../services/signal_service.dart';

class MessagingScreen extends StatefulWidget {
  final SignalService signalService;

  const MessagingScreen({
    super.key,
    required this.signalService,
  });

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final _recipientController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isChecking = false;
  bool _hasKeysForRecipient = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    setState(() {
      _currentUserId = widget.signalService.currentUserId;
    });
  }

  Future<void> _checkKeysForUser() async {
    final recipientId = _recipientController.text.trim();
    
    if (recipientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a recipient ID'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!widget.signalService.isValidUserId(recipientId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid recipient ID format'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isChecking = true;
    });

    try {
      final hasKeys = await widget.signalService.hasKeysForUser(recipientId);
      setState(() {
        _hasKeysForRecipient = hasKeys;
        _isChecking = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasKeys
                ? 'Keys found for $recipientId'
                : 'No keys found for $recipientId',
          ),
          backgroundColor: hasKeys ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      setState(() {
        _isChecking = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking keys: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _simulateEncryption() {
    final recipientId = _recipientController.text.trim();
    final message = _messageController.text.trim();

    if (recipientId.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both recipient ID and message'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_hasKeysForRecipient) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot encrypt: No keys found for recipient'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Simulate encryption result
    final simulatedEncrypted = 'ENCRYPTED_${message.length}_${DateTime.now().millisecondsSinceEpoch}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Encryption Simulation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Original Message: $message'),
            const SizedBox(height: 8),
            Text('Encrypted (Simulated): $simulatedEncrypted'),
            const SizedBox(height: 16),
            const Text(
              'Note: This is a simulation. Full encryption/decryption will be implemented in future versions.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isInitialized = widget.signalService.isApiAvailable;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Secure Messaging',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            if (_currentUserId != null)
              Text(
                'Current User: $_currentUserId',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            
            const SizedBox(height: 24),

            if (!isInitialized) ...[
              const Card(
                color: Colors.orange,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Please initialize Signal Protocol in the Setup tab first.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ] else ...[
              // Recipient ID Input
              TextField(
                controller: _recipientController,
                decoration: InputDecoration(
                  labelText: 'Recipient ID',
                  hintText: 'Enter recipient user ID',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: _isChecking ? null : _checkKeysForUser,
                    icon: _isChecking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                  ),
                ),
                onSubmitted: (_) => _checkKeysForUser(),
              ),
              const SizedBox(height: 16),

              // Keys Status
              if (_recipientController.text.isNotEmpty) ...[
                Card(
                  color: _hasKeysForRecipient ? Colors.green.shade100 : Colors.red.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(
                          _hasKeysForRecipient ? Icons.check_circle : Icons.error,
                          color: _hasKeysForRecipient ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _hasKeysForRecipient
                              ? 'Keys available for recipient'
                              : 'No keys found for recipient',
                          style: TextStyle(
                            color: _hasKeysForRecipient ? Colors.green.shade800 : Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Message Input
              TextField(
                controller: _messageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Enter your message to encrypt',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Encrypt Button
              ElevatedButton.icon(
                onPressed: _simulateEncryption,
                icon: const Icon(Icons.lock),
                label: const Text('Simulate Encryption'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // Information Card
              const Card(
                color: Colors.blue,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demo Features',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Check if keys exist for a user\n'
                        '• Simulate message encryption\n'
                        '• Validate user ID format\n'
                        '• Full encryption coming in future versions',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
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
    _recipientController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
