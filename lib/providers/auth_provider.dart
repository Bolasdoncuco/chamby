import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

enum AppState { loading, welcome, login, signup, app }
enum UserRole { employer, candidate, none }
enum CurrentView { feed, create, match, profile, dashboard, candidates, settings, editVacancy }

class AuthProvider with ChangeNotifier {
  AppState _appState = AppState.loading;
  UserRole _userRole = UserRole.none;
  CurrentView _currentView = CurrentView.feed;
  dynamic _matchedUser;
  dynamic _selectedVacancy;

  AuthProvider() {
    checkAuthStatus();
  }

  AppState get appState => _appState;
  UserRole get userRole => _userRole;
  CurrentView get currentView => _currentView;
  dynamic get matchedUser => _matchedUser;
  dynamic get selectedVacancy => _selectedVacancy;

  void setAppState(AppState state) {
    _appState = state;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final response = await ApiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String token = data['token'];
      final String roleStr = data['user']['role'];
      
      final UserRole role = roleStr == 'EMPLOYER' ? UserRole.employer : UserRole.candidate;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_role', roleStr);
      
      handleAuthSuccess(role);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Error al iniciar sesión');
    }
  }

  Future<void> register({
    required Map<String, dynamic> data,
    required UserRole role,
  }) async {
    final response = await ApiService.post('/auth/register', data);

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final String token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_role', role == UserRole.employer ? 'EMPLOYER' : 'CANDIDATE');
      
      handleAuthSuccess(role);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Error al registrarse');
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final roleStr = prefs.getString('user_role');
      
      if (token != null && roleStr != null) {
        final role = roleStr == 'EMPLOYER' ? UserRole.employer : UserRole.candidate;
        _userRole = role;
        _currentView = role == UserRole.employer ? CurrentView.dashboard : CurrentView.feed;
        _appState = AppState.app;
      } else {
        _appState = AppState.welcome;
      }
    } catch (e) {
      _appState = AppState.welcome;
    }
    notifyListeners();
  }

  void handleAuthSuccess(UserRole role) {
    _userRole = role;
    _appState = AppState.app;
    _currentView = role == UserRole.employer ? CurrentView.dashboard : CurrentView.feed;
    notifyListeners();
  }

  Future<void> handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
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
