import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

void main() async {
  // Test PreKeyRecord methods
  final preKeys = generatePreKeys(0, 1);
  final preKey = preKeys.first;
  print('PreKeyRecord methods:');
  print('- id: ${preKey.id}');
  print('- getKeyPair: ${preKey.getKeyPair()}');
  print('- publicKey: ${preKey.getKeyPair().publicKey}');
  
  // Test SignedPreKeyRecord methods
  final identity = generateIdentityKeyPair();
  final signedPreKey = generateSignedPreKey(identity, 0);
  print('\nSignedPreKeyRecord methods:');
  print('- id: ${signedPreKey.id}');
  print('- getKeyPair: ${signedPreKey.getKeyPair()}');
  print('- signature: ${signedPreKey.signature}');
  print('- publicKey: ${signedPreKey.getKeyPair().publicKey}');
  
  // Test Direction
  print('\nDirection constants:');
  print('- sending: ${Direction.sending}');
  print('- receiving: ${Direction.receiving}');
}
