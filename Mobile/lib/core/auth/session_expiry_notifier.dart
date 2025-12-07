import 'dart:async';



class SessionExpiryNotifier {
  static final SessionExpiryNotifier _instance = SessionExpiryNotifier._internal();
  factory SessionExpiryNotifier() => _instance;
  SessionExpiryNotifier._internal();

  final _sessionExpiredController = StreamController<void>.broadcast();

  
  Stream<void> get sessionExpiredStream => _sessionExpiredController.stream;

  
  void notifySessionExpired() {
    _sessionExpiredController.add(null);
  }

  void dispose() {
    _sessionExpiredController.close();
  }
}
