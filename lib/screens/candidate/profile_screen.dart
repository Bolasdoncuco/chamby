import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../models/candidate.dart';
import '../../services/candidate_service.dart';
import '../../theme/app_colors.dart';

class CandidateProfileScreen extends StatefulWidget {
  const CandidateProfileScreen({super.key, CandidateGateway? gateway})
    : _gateway = gateway;

  final CandidateGateway? _gateway;

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _role = TextEditingController();
  final _bio = TextEditingController();
  final _skills = TextEditingController();
  final _experience = TextEditingController();
  final _availability = TextEditingController();
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();
  late final CandidateGateway _gateway;

  Candidate? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _gateway = widget._gateway ?? ApiCandidateGateway();
    _load();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _role.dispose();
    _bio.dispose();
    _skills.dispose();
    _experience.dispose();
    _availability.dispose();
    _phone.dispose();
    _whatsapp.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final profile = await _gateway.loadProfile();
      if (!mounted) return;
      _setDraft(CandidateProfileDraft.fromCandidate(profile));
      setState(() => _profile = profile);
    } catch (error) {
      if (mounted) setState(() => _errorMessage = candidateErrorMessage(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _setDraft(CandidateProfileDraft draft) {
    _firstName.text = draft.firstName;
    _lastName.text = draft.lastName;
    _role.text = draft.role;
    _bio.text = draft.bio;
    _skills.text = draft.skills.join(', ');
    _experience.text = draft.experience?.toString() ?? '';
    _availability.text = draft.availability;
    _phone.text = draft.phone;
    _whatsapp.text = draft.whatsapp;
  }

  CandidateProfileDraft _draft() => CandidateProfileDraft(
    firstName: _firstName.text,
    lastName: _lastName.text,
    role: _role.text,
    bio: _bio.text,
    skills: _skills.text.split(','),
    experience: parseCandidateExperience(_experience.text),
    availability: _availability.text,
    phone: _phone.text,
    whatsapp: _whatsapp.text,
  );

  Future<void> _save() async {
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      final profile = await _gateway.saveProfile(_draft());
      if (!mounted) return;
      _setDraft(CandidateProfileDraft.fromCandidate(profile));
      setState(() => _profile = profile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu perfil fue actualizado.')),
      );
    } catch (error) {
      if (mounted) setState(() => _errorMessage = candidateErrorMessage(error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null && _profile == null) {
      return _ErrorState(message: _errorMessage!, onRetry: _load);
    }

    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _ProfileHeader(profile: _profile),
              const SizedBox(height: 24),
              const Text(
                'Tu perfil',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Esta información se muestra a las empresas que te recomiende Chamby.',
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null) _InlineError(message: _errorMessage!),
              Row(
                children: [
                  Expanded(child: _field(_firstName, 'Nombre', required: true)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(_lastName, 'Apellidos', required: true),
                  ),
                ],
              ),
              _field(_role, 'Puesto o especialidad'),
              _field(_availability, 'Disponibilidad'),
              _field(
                _experience,
                'Años de experiencia',
                keyboardType: TextInputType.number,
                validator: _experienceValidator,
              ),
              _field(
                _skills,
                'Habilidades',
                hint: 'Ej. ventas, POS, atención al cliente',
              ),
              _field(_bio, 'Sobre ti', maxLines: 4),
              _field(_phone, 'Teléfono', keyboardType: TextInputType.phone),
              _field(_whatsapp, 'WhatsApp', keyboardType: TextInputType.phone),
              const SizedBox(height: 8),
              Semantics(
                button: true,
                label: 'Guardar cambios de perfil',
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.save),
                  label: Text(_isSaving ? 'Guardando…' : 'Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      minLines: maxLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator:
          validator ??
          (required
              ? (value) => value == null || value.trim().isEmpty
                    ? 'Este campo es obligatorio.'
                    : null
              : null),
    ),
  );

  String? _experienceValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return parseCandidateExperience(value) == null
        ? 'Escribe un número entero válido.'
        : null;
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({this.profile});

  final Candidate? profile;

  @override
  Widget build(BuildContext context) {
    final photoUrl = profile?.photoUrl;
    final name = '${profile?.firstName ?? ''} ${profile?.lastName ?? ''}'
        .trim();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 72,
              height: 72,
              child: photoUrl == null || photoUrl.isEmpty
                  ? const ColoredBox(
                      color: AppColors.secondaryBlue,
                      child: Icon(
                        LucideIcons.user,
                        color: AppColors.primaryBlue,
                      ),
                    )
                  : Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const ColoredBox(
                            color: AppColors.secondaryBlue,
                            child: Icon(
                              LucideIcons.user,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Tu perfil' : name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                Text(profile?.role ?? 'Candidato'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    ),
  );
}
