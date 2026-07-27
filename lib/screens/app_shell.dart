import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/vacancy.dart';
import '../providers/auth_provider.dart';
import 'candidate/match_screen.dart';
import 'candidate/profile_screen.dart';
import 'candidate/swipe_feed_screen.dart';
import 'common/settings_screen.dart';
import 'employer/dashboard_screen.dart';
import 'employer/job_creation_screen.dart';
import 'employer/vacancy_candidates_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, this.contentOverride});

  final Widget? contentOverride;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final view = auth.currentView;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        title: const Text('Chamby', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
        actions: [
          if (auth.userRole == UserRole.employer) ...[
            _NavButton(label: 'Ver candidatos', icon: LucideIcons.search, selected: view == CurrentView.feed, onPressed: () => auth.setCurrentView(CurrentView.feed)),
            _NavButton(label: 'Ver dashboard', icon: LucideIcons.layoutDashboard, selected: view == CurrentView.dashboard, onPressed: () => auth.setCurrentView(CurrentView.dashboard)),
            _NavButton(label: 'Abrir configuración', icon: LucideIcons.settings, selected: view == CurrentView.settings, onPressed: () => auth.setCurrentView(CurrentView.settings)),
          ] else ...[
            _NavButton(label: 'Ver vacantes', icon: LucideIcons.briefcase, selected: view == CurrentView.feed, onPressed: () => auth.setCurrentView(CurrentView.feed)),
            _NavButton(label: 'Ver mi perfil', icon: LucideIcons.user, selected: view == CurrentView.profile, onPressed: () => auth.setCurrentView(CurrentView.profile)),
            _NavButton(label: 'Abrir configuración', icon: LucideIcons.settings, selected: view == CurrentView.settings, onPressed: () => auth.setCurrentView(CurrentView.settings)),
          ],
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[100], height: 1),
        ),
      ),
      body: contentOverride ?? _buildCurrentView(auth, view),
    );
  }

  Widget _buildCurrentView(AuthProvider auth, CurrentView view) {
    if (!auth.canAccess(view)) {
      return auth.userRole == UserRole.employer ? const EmployerDashboardScreen() : const SwipeFeedScreen();
    }
    switch (view) {
      case CurrentView.feed:
        if (auth.userRole == UserRole.employer) {
          final vacancy = auth.selectedVacancy;
          return vacancy is Vacancy
              ? VacancyCandidatesScreen(vacancy: vacancy, onBack: () => auth.setCurrentView(CurrentView.dashboard))
              : const _EmployerFeedEmptyState();
        }
        return const SwipeFeedScreen();
      case CurrentView.dashboard:
        return const EmployerDashboardScreen();
      case CurrentView.create:
      case CurrentView.editVacancy:
        return const JobCreationScreen();
      case CurrentView.match:
        return MatchScreen(user: auth.matchedUser, onContinue: () => auth.setCurrentView(CurrentView.feed));
      case CurrentView.profile:
        return const CandidateProfileScreen();
      case CurrentView.candidates:
        return VacancyCandidatesScreen(
          vacancy: auth.selectedVacancy is Vacancy ? auth.selectedVacancy as Vacancy : null,
          onBack: () => auth.setCurrentView(CurrentView.dashboard),
        );
      case CurrentView.settings:
        return const SettingsScreen();
    }
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.label, required this.icon, required this.selected, required this.onPressed});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
        label: label,
        button: true,
        selected: selected,
        child: IconButton(
          tooltip: label,
          icon: Icon(icon, color: selected ? const Color(0xFF2563EB) : Colors.grey[400]),
          onPressed: onPressed,
        ),
      );
}

class _EmployerFeedEmptyState extends StatelessWidget {
  const _EmployerFeedEmptyState();

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('Selecciona una vacante para revisar candidatos.', textAlign: TextAlign.center),
        ),
      );
}
