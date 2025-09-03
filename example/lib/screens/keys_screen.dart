import 'package:flutter/material.dart';
import '../services/signal_service.dart';

class KeysScreen extends StatefulWidget {
  final SignalService signalService;

  const KeysScreen({
    super.key,
    required this.signalService,
  });

  @override
  State<KeysScreen> createState() => _KeysScreenState();
}

class _KeysScreenState extends State<KeysScreen> {
  Map<String, dynamic>? _instanceInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInstanceInfo();
  }

  Future<void> _loadInstanceInfo() async {
    if (!widget.signalService.isApiAvailable) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final info = await widget.signalService.getInstanceInfo();
      setState(() {
        _instanceInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading instance info: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadKeys() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.signalService.uploadKeys();
      await _loadInstanceInfo();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Keys uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
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

  Widget _buildInfoCard(String title, String subtitle, IconData icon, {Color? color}) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildInstanceInfoSection() {
    if (_instanceInfo == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No instance information available'),
        ),
      );
    }

    final isInitialized = _instanceInfo!['isInitialized'] ?? false;
    final userId = _instanceInfo!['userId'] ?? 'Unknown';
    final deviceId = _instanceInfo!['deviceId'] ?? 'Unknown';
    final hasKeys = _instanceInfo!['hasKeys'] ?? false;

    return Column(
      children: [
        _buildInfoCard(
          'Initialization Status',
          isInitialized ? 'Initialized' : 'Not Initialized',
          isInitialized ? Icons.check_circle : Icons.error,
          color: isInitialized ? Colors.green : Colors.red,
        ),
        _buildInfoCard(
          'User ID',
          userId.toString(),
          Icons.person,
        ),
        _buildInfoCard(
          'Device ID',
          deviceId.toString(),
          Icons.devices,
        ),
        _buildInfoCard(
          'Keys Status',
          hasKeys ? 'Keys Available' : 'No Keys',
          hasKeys ? Icons.key : Icons.key_off,
          color: hasKeys ? Colors.green : Colors.orange,
        ),
      ],
    );
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
              'Key Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _loadInstanceInfo,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _uploadKeys,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Upload Keys'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Loading Indicator
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),

              // Instance Information
              if (!_isLoading) ...[
                const Text(
                  'Instance Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInstanceInfoSection(),
              ],

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
                        'Key Management Features',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• View initialization status\n'
                        '• Check user and device information\n'
                        '• Upload keys to Firebase\n'
                        '• Monitor key availability\n'
                        '• Refresh instance information',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Security Note
              const Card(
                color: Colors.amber,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.security, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Security Note',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Private keys never leave your device. Only public keys and metadata are synchronized via Firebase.',
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
}
