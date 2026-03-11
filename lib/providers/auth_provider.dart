import 'package:flutter/material.dart';

enum AppState { welcome, login, signup, app }
enum UserRole { employer, candidate, none }
enum CurrentView { feed, create, match, profile, dashboard, candidates, settings, editVacancy }

class AuthProvider with ChangeNotifier {
  AppState _appState = AppState.welcome;
  UserRole _userRole = UserRole.none;
  CurrentView _currentView = CurrentView.feed;
  dynamic _matchedUser;
  dynamic _selectedVacancy;

  AppState get appState => _appState;
  UserRole get userRole => _userRole;
  CurrentView get currentView => _currentView;
  dynamic get matchedUser => _matchedUser;
  dynamic get selectedVacancy => _selectedVacancy;

  void setAppState(AppState state) {
    _appState = state;
    notifyListeners();
  }

  void handleAuthSuccess(UserRole role) {
    _userRole = role;
    _appState = AppState.app;
    _currentView = role == UserRole.employer ? CurrentView.dashboard : CurrentView.feed;
    notifyListeners();
  }

  void handleLogout() {
    _appState = AppState.welcome;
    _userRole = UserRole.none;
    _currentView = CurrentView.feed;
    notifyListeners();
  }

  void setCurrentView(CurrentView view) {
    _currentView = view;
    notifyListeners();
  }

  void setMatchedUser(dynamic user) {
    _matchedUser = user;
    _currentView = CurrentView.match;
    notifyListeners();
  }

  void setSelectedVacancy(dynamic vacancy, CurrentView view) {
    _selectedVacancy = vacancy;
    _currentView = view;
    notifyListeners();
  }
}
