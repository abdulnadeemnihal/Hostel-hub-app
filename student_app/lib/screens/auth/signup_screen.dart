import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../home/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Personal Info
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rollController = TextEditingController();
  String _selectedGender = AppConstants.genders.first;

  // Academic Info
  String _selectedDepartment = AppConstants.departments.first;
  String _selectedBranch = AppConstants.branches.first;
  String _selectedYear = AppConstants.years.first;

  // Family & Address
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Preferences
  String _selectedFood = AppConstants.foodPreferences.first;
  String _selectedRoom = AppConstants.roomPreferences.first;
  final List<String> _selectedLanguages = ['English'];

  // Security
  final _referralController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _rollController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _addressController.dispose();
    _referralController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate referral code
    if (_referralController.text.trim().toUpperCase() != AppConstants.validReferralCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid referral code'), backgroundColor: Colors.red),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
      phone: _phoneController.text,
      rollNumber: _rollController.text,
      department: _selectedDepartment,
      branch: _selectedBranch,
      year: _selectedYear,
      parentName: _parentNameController.text,
      parentPhone: _parentPhoneController.text,
      address: _addressController.text,
      gender: _selectedGender,
      foodPreference: _selectedFood,
      roomPreference: _selectedRoom,
      languages: _selectedLanguages,
      referralCode: _referralController.text.trim().toUpperCase(),
    );
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 3) {
              setState(() => _currentStep++);
            } else {
              _handleSignUp();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
          },
          controlsBuilder: (context, details) {
            final isLast = _currentStep == 3;
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return ElevatedButton(
                          onPressed: (auth.isLoading && isLast) ? null : details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: (auth.isLoading && isLast)
                              ? const SizedBox(height: 20, width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(isLast ? 'Create Account' : 'Continue'),
                        );
                      },
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            // ── Step 1: Personal Info ──
            Step(
              title: const Text('Personal Info'),
              subtitle: const Text('Name, email, phone'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      if (auth.error != null) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [
                            Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(auth.error!, style: TextStyle(color: Colors.red[700]))),
                            IconButton(icon: const Icon(Icons.close, size: 18), onPressed: auth.clearError),
                          ]),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  _field(_nameController, 'Full Name', Icons.person_outlined,
                      validator: _required),
                  _field(_emailController, 'Email', Icons.email_outlined,
                      keyboard: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter email';
                        if (!v.contains('@')) return 'Invalid email';
                        return null;
                      }),
                  _field(_phoneController, 'Phone Number', Icons.phone_outlined,
                      keyboard: TextInputType.phone, validator: _required),
                  _field(_rollController, 'Roll Number', Icons.badge_outlined,
                      validator: _required),
                  const SizedBox(height: 8),
                  _segmentedSelector(
                    label: 'Gender',
                    options: AppConstants.genders,
                    selected: _selectedGender,
                    onChanged: (v) => setState(() => _selectedGender = v),
                  ),
                ],
              ),
            ),

            // ── Step 2: Academic & Address ──
            Step(
              title: const Text('Academic & Family'),
              subtitle: const Text('Dept, parent, address'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  _dropdown('Department', AppConstants.departments, _selectedDepartment,
                      Icons.business_outlined, (v) => setState(() => _selectedDepartment = v!)),
                  _dropdown('Branch', AppConstants.branches, _selectedBranch,
                      Icons.school_outlined, (v) => setState(() => _selectedBranch = v!)),
                  _dropdown('Year', AppConstants.years, _selectedYear,
                      Icons.calendar_today_outlined, (v) => setState(() => _selectedYear = v!)),
                  const Divider(height: 32),
                  _field(_parentNameController, 'Parent / Guardian Name', Icons.family_restroom,
                      validator: _required),
                  _field(_parentPhoneController, 'Parent Phone (permanent)', Icons.phone_callback_outlined,
                      keyboard: TextInputType.phone, validator: _required),
                  _field(_addressController, 'Home Address', Icons.home_outlined,
                      maxLines: 2, validator: _required),
                ],
              ),
            ),

            // ── Step 3: Preferences ──
            Step(
              title: const Text('Preferences'),
              subtitle: const Text('Food, room, languages'),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _segmentedSelector(
                    label: 'Food Preference',
                    options: AppConstants.foodPreferences,
                    selected: _selectedFood,
                    onChanged: (v) => setState(() => _selectedFood = v),
                  ),
                  const SizedBox(height: 16),
                  _segmentedSelector(
                    label: 'Room Sharing',
                    options: AppConstants.roomPreferences,
                    selected: _selectedRoom,
                    onChanged: (v) => setState(() => _selectedRoom = v),
                  ),
                  const SizedBox(height: 16),
                  const Text('Languages You Speak',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E1E2D))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.languages.map((lang) {
                      final selected = _selectedLanguages.contains(lang);
                      return FilterChip(
                        label: Text(lang),
                        selected: selected,
                        selectedColor: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                        checkmarkColor: const Color(0xFF4F46E5),
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _selectedLanguages.add(lang);
                            } else {
                              _selectedLanguages.remove(lang);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  if (_selectedLanguages.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Select at least one language',
                          style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                ],
              ),
            ),

            // ── Step 4: Security ──
            Step(
              title: const Text('Security'),
              subtitle: const Text('Referral code & password'),
              isActive: _currentStep >= 3,
              state: _currentStep > 3 ? StepState.complete : StepState.indexed,
              content: Column(
                children: [
                  _field(_referralController, 'Referral Code', Icons.vpn_key_outlined,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter referral code';
                        return null;
                      },
                      hint: 'Required to verify you\'re a student'),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter password';
                      if (v.length < 6) return 'Min 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (v) {
                      if (v != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──

  String? _required(String? v) => (v == null || v.isEmpty) ? 'This field is required' : null;

  Widget _field(TextEditingController ctrl, String label, IconData icon, {
    TextInputType? keyboard,
    String? Function(String?)? validator,
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
      ),
    );
  }

  Widget _dropdown(String label, List<String> items, String value, IconData icon,
      void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        items: items.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _segmentedSelector({
    required String label,
    required List<String> options,
    required String selected,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E1E2D))),
        const SizedBox(height: 8),
        Row(
          children: options.map((opt) {
            final isSelected = opt == selected;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: opt != options.last ? 8 : 0),
                child: ChoiceChip(
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(opt, textAlign: TextAlign.center,
                        style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF1E1E2D),
                            fontWeight: FontWeight.w500)),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF4F46E5),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[300]!),
                  ),
                  onSelected: (_) => onChanged(opt),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
