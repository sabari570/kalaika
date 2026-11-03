import 'dart:async';

import 'package:feemanager/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';

/// Notifies go_router when authentication state changes.
class AuthRefreshListenable extends ChangeNotifier {
  /// Subscribes to [repository] auth updates.
  AuthRefreshListenable(AuthRepository repository) {
    _subscription = repository.watchAuthUser().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
