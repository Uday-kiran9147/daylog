import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/day_note_repository.dart';
import '../repositories/day_note_repository_impl.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import '../services/mock_auth_service.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/day_note_viewmodel.dart';

/// Flag or instance indicating whether Firebase was successfully initialized
final firebaseInitializedProvider = StateProvider<bool>((ref) => false);

/// Provides the active AuthService (FirebaseAuthService if available, MockAuthService fallback)
final dayNoteAuthServiceProvider = Provider<AuthService>((ref) {
  final hasFirebase = ref.watch(firebaseInitializedProvider);
  if (hasFirebase) {
    try {
      return FirebaseAuthService();
    } catch (e) {
      debugPrint('Failed to instantiate FirebaseAuthService, using MockAuthService: $e');
      return MockAuthService();
    }
  }
  return MockAuthService();
});

/// Provides FirestoreService if Firebase is available
final dayNoteFirestoreServiceProvider = Provider<FirestoreService?>((ref) {
  final hasFirebase = ref.watch(firebaseInitializedProvider);
  if (hasFirebase) {
    try {
      return FirestoreService();
    } catch (e) {
      debugPrint('Firestore unavailable: $e');
      return null;
    }
  }
  return null;
});

/// Riverpod ChangeNotifierProvider for AuthViewModel
final dayNoteAuthProvider = ChangeNotifierProvider<AuthViewModel>((ref) {
  final authService = ref.watch(dayNoteAuthServiceProvider);
  return AuthViewModel(authService: authService);
});

/// Riverpod Provider for DayNoteRepository
final dayNoteRepositoryProvider = Provider<DayNoteRepository>((ref) {
  final firestore = ref.watch(dayNoteFirestoreServiceProvider);
  final repo = DayNoteRepositoryImpl(
    storageService: LocalStorageService(),
    firestoreService: firestore,
  );
  return repo;
});

/// Riverpod ChangeNotifierProvider for DayNoteViewModel
final dayNoteViewModelProvider = ChangeNotifierProvider<DayNoteViewModel>((ref) {
  final repo = ref.watch(dayNoteRepositoryProvider);
  final vm = DayNoteViewModel(repository: repo);

  // Sync user context when auth user changes without recreating the viewmodel
  ref.listen<String?>(
    dayNoteAuthProvider.select((auth) => auth.currentUser?.uid),
    (previous, next) {
      if (previous != next && !vm.isDisposed) {
        vm.updateUserContext(next);
      }
    },
  );

  // Initialize with the current user ID if available
  final currentUserId = ref.read(dayNoteAuthProvider).currentUser?.uid;
  if (currentUserId != null) {
    repo.setUserId(currentUserId);
  }

  // Auto-initialize when created
  vm.init();
  return vm;
});
