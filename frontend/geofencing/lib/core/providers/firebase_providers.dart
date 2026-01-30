import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_messaging_service.dart';

/// Provider para el servicio de Firebase Messaging
/// Este provider se sobrescribe en main.dart con la instancia real
final firebaseMessagingServiceProvider = Provider<FirebaseMessagingService>((ref) {
  throw UnimplementedError('FirebaseMessagingService debe ser provisto en el main');
});
