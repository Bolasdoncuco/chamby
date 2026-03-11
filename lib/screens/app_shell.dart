import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/auth_provider.dart';
import 'candidate/profile_screen.dart';
import 'candidate/swipe_feed_screen.dart';
import 'candidate/match_screen.dart';
import 'employer/dashboard_screen.dart';
import 'employer/job_creation_screen.dart';
import 'employer/vacancy_candidates_screen.dart';
import 'common/settings_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.userRole;
    final currentView = authProvider.currentView;

    return Scaffold(
      backgroundColor: Colors.grey[50], // slate-50
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        title: const Text(
          'Chamby',
          style: TextStyle(
            color: Color(0xFF2563EB), // blue-600
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          if (userRole == UserRole.employer) ...[
            IconButton(
              icon: Icon(
                LucideIcons.layoutDashboard,
                color: currentView == CurrentView.dashboard ? const Color(0xFF2563EB) : Colors.grey[400],
              ),
              onPressed: () => authProvider.setCurrentView(CurrentView.dashboard),
            ),
            IconButton(
              icon: Icon(
                LucideIcons.settings,
                color: currentView == CurrentView.settings ? const Color(0xFF2563EB) : Colors.grey[400],
              ),
              onPressed: () => authProvider.setCurrentView(CurrentView.settings),
            ),
          ] else ...[
             IconButton(
              icon: Icon(
                LucideIcons.briefcase,
                color: currentView == CurrentView.feed ? const Color(0xFF2563EB) : Colors.grey[400],
              ),
              onPressed: () => authProvider.setCurrentView(CurrentView.feed),
            ),
            IconButton(
              icon: Icon(
                LucideIcons.user,
                color: currentView == CurrentView.profile ? const Color(0xFF2563EB) : Colors.grey[400],
              ),
              onPressed: () => authProvider.setCurrentView(CurrentView.profile),
            ),
            IconButton(
              icon: Icon(
                LucideIcons.settings,
                color: currentView == CurrentView.settings ? const Color(0xFF2563EB) : Colors.grey[400],
              ),
              onPressed: () => authProvider.setCurrentView(CurrentView.settings),
            ),
          ],
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[100], // slate-100 border
            height: 1.0,
          ),
        ),
      ),
      body: _buildCurrentView(currentView, authProvider),
    );
  }

  Widget _buildCurrentView(CurrentView view, AuthProvider authProvider) {
    switch (view) {
      case CurrentView.feed:
        return const SwipeFeedScreen();
      case CurrentView.dashboard:
         return const EmployerDashboardScreen();
      case CurrentView.create:
      case CurrentView.editVacancy:
         return const JobCreationScreen();
      case CurrentView.match:
         return MatchScreen(user: authProvider.matchedUser, onContinue: () => authProvider.setCurrentView(CurrentView.feed));
      case CurrentView.profile:
         return const CandidateProfileScreen();
      case CurrentView.candidates:
         return const VacancyCandidatesScreen();
      case CurrentView.settings:
         return const SettingsScreen();
    }
  }
}
