import 'package:flutter/material.dart';
import '../theme/daynote_theme.dart';
import '../viewmodels/auth_viewmodel.dart';

enum AuthMode { signIn, signUp, forgotPassword }

class AuthScreen extends StatefulWidget {
  final AuthViewModel authViewModel;

  const AuthScreen({
    super.key,
    required this.authViewModel,
  });

  static Future<void> show(BuildContext context, AuthViewModel authViewModel) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AuthScreen(authViewModel: authViewModel),
      ),
    );
  }

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _mode = AuthMode.signIn;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode mode) {
    widget.authViewModel.clearMessages();
    setState(() {
      _mode = mode;
    });
  }

  Future<void> _handleSubmit() async {
    final vm = widget.authViewModel;
    final email = _emailController.text;
    final password = _passwordController.text;

    bool success = false;
    if (_mode == AuthMode.signIn) {
      success = await vm.signIn(email: email, password: password);
    } else if (_mode == AuthMode.signUp) {
      success = await vm.signUp(
        email: email,
        password: password,
        confirmPassword: _confirmPasswordController.text,
      );
    } else if (_mode == AuthMode.forgotPassword) {
      await vm.sendPasswordReset(email: email);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = DayNoteTheme.textPrimary(context);
    final bg = DayNoteTheme.background(context);
    final accent = DayNoteTheme.accent(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: primary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                physics: const BouncingScrollPhysics(),
                child: ListenableBuilder(
                  listenable: widget.authViewModel,
                  builder: (context, _) {
                    final vm = widget.authViewModel;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Brand / Logo Title
                        Center(
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: primary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'D',
                                      style: DayNoteTheme.button(context).copyWith(
                                        color: bg,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'DAYNOTE',
                                    style: DayNoteTheme.heading(context).copyWith(
                                      fontSize: 24,
                                      letterSpacing: 3.0,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Cloud sync for daily planner & notes',
                                style: DayNoteTheme.body(context).copyWith(
                                  fontSize: 13.5,
                                  color: DayNoteTheme.textSecondary(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Full-width form header
                        Text(
                          _mode == AuthMode.signIn
                              ? 'Sign In to Your Journal'
                              : _mode == AuthMode.signUp
                                  ? 'Create Your Account'
                                  : 'Reset Password',
                          style: DayNoteTheme.heading(context).copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _mode == AuthMode.forgotPassword
                              ? 'Enter your registered email address to receive a password reset link.'
                              : 'Your private thoughts and daily plans, securely synchronized.',
                          style: DayNoteTheme.body(context).copyWith(
                            fontSize: 13,
                            color: DayNoteTheme.textSecondary(context),
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Error Message Banner
                        if (vm.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: DayNoteTheme.priorityHighBg(context),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: DayNoteTheme.priorityHigh(context).withValues(alpha: 0.5), width: 0.8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 16, color: DayNoteTheme.priorityHigh(context)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    vm.errorMessage!,
                                    style: DayNoteTheme.body(context).copyWith(
                                      fontSize: 13,
                                      color: DayNoteTheme.priorityHigh(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Success Message Banner
                        if (vm.successMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: DayNoteTheme.priorityLowBg(context),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: DayNoteTheme.priorityLow(context).withValues(alpha: 0.5), width: 0.8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_outline, size: 16, color: DayNoteTheme.priorityLow(context)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    vm.successMessage!,
                                    style: DayNoteTheme.body(context).copyWith(
                                      fontSize: 13,
                                      color: DayNoteTheme.priorityLow(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Email Field
                        _buildTextField(
                          context,
                          controller: _emailController,
                          label: 'EMAIL ADDRESS',
                          hint: 'your.name@example.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.mail_outline,
                        ),

                        // Password Field (Sign In & Sign Up)
                        if (_mode != AuthMode.forgotPassword) ...[
                          const SizedBox(height: 14),
                          _buildTextField(
                            context,
                            controller: _passwordController,
                            label: 'PASSWORD',
                            hint: '••••••••',
                            obscureText: _obscurePassword,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: DayNoteTheme.textTertiary(context),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ],

                        // Confirm Password Field (Sign Up only)
                        if (_mode == AuthMode.signUp) ...[
                          const SizedBox(height: 14),
                          _buildTextField(
                            context,
                            controller: _confirmPasswordController,
                            label: 'CONFIRM PASSWORD',
                            hint: '••••••••',
                            obscureText: _obscureConfirmPassword,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: DayNoteTheme.textTertiary(context),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ],

                        // Forgot Password link (in Sign In mode)
                        if (_mode == AuthMode.signIn) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => _switchMode(AuthMode.forgotPassword),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                                child: Text(
                                  'Forgot password?',
                                  style: DayNoteTheme.caption(context).copyWith(
                                    color: accent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Full-width Submit Button
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: bg,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: vm.isLoading ? null : _handleSubmit,
                            child: vm.isLoading
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: bg,
                                    ),
                                  )
                                : Text(
                                    _mode == AuthMode.signIn
                                        ? 'Sign In'
                                        : _mode == AuthMode.signUp
                                            ? 'Create Account'
                                            : 'Send Reset Link',
                                    style: DayNoteTheme.button(context).copyWith(
                                      color: bg,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Toggle mode footer
                        Center(
                          child: _mode == AuthMode.signIn
                              ? Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    Text(
                                      "Don't have an account?",
                                      style: DayNoteTheme.body(context).copyWith(
                                        fontSize: 13.5,
                                        color: DayNoteTheme.textSecondary(context),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _switchMode(AuthMode.signUp),
                                      child: Text(
                                        'Create one',
                                        style: DayNoteTheme.button(context).copyWith(
                                          fontSize: 13.5,
                                          color: accent,
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : InkWell(
                                  onTap: () => _switchMode(AuthMode.signIn),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                    child: Text(
                                      '← Back to Sign In',
                                      style: DayNoteTheme.button(context).copyWith(
                                        fontSize: 13.5,
                                        color: accent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    final highlight = DayNoteTheme.surfaceHighlight(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DayNoteTheme.caption(context).copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: DayNoteTheme.textSecondary(context),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textCapitalization: TextCapitalization.none,
          style: DayNoteTheme.body(context),
          cursorColor: DayNoteTheme.accent(context),
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          decoration: InputDecoration(
            filled: true,
            fillColor: highlight,
            hintText: hint,
            hintStyle: DayNoteTheme.body(context).copyWith(
              color: DayNoteTheme.textDisabled(context),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: DayNoteTheme.textTertiary(context))
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 42),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 1.5),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
