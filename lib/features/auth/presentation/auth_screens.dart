import 'package:bookapp/app/router/app_router.dart';
import 'package:bookapp/app/theme/app_tokens.dart';
import 'package:bookapp/features/auth/domain/auth_state.dart';
import 'package:bookapp/features/auth/presentation/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RequireAuth extends ConsumerWidget {
  const RequireAuth({required this.child, this.message, super.key});
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    if (auth.status == AuthStatus.restoring) {
      return const Center(child: CircularProgressIndicator());
    }
    if (auth.isAuthenticated) return child;
    return _SignInIntroduction(message: message);
  }
}

class _SignInIntroduction extends StatelessWidget {
  const _SignInIntroduction({this.message});
  final String? message;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Your Leaf & Loom account',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message ??
                  'Sign in to manage your bag, addresses, and order history.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => context.push(AppRoutes.login),
              child: const Text('Sign in'),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.signUp),
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    ),
  );
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref
        .read(authControllerProvider.notifier)
        .login(email: _email.text, password: _password.text);
    if (success && mounted) context.go(AppRoutes.profile);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return _AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to continue with your account.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _EmailField(controller: _email),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: _requiredPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show password' : 'Hide password',
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            _AuthFeedback(state: auth),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: auth.isBusy ? null : _submit,
                child: auth.isBusy
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign in'),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: auth.isBusy
                  ? null
                  : () => context.push(AppRoutes.forgotPassword),
              child: const Text('Forgot password?'),
            ),
            TextButton(
              onPressed: auth.isBusy
                  ? null
                  : () => context.push(AppRoutes.signUp),
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = List.generate(7, (_) => TextEditingController());
  bool _obscure = true;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authControllerProvider.notifier).signUp({
      'email': _controllers[0].text.trim(),
      'password': _controllers[1].text,
      'passwordConfirm': _controllers[2].text,
      'firstName': _nullableText(_controllers[3].text),
      'lastName': _nullableText(_controllers[4].text),
      'gender': _nullableText(_controllers[5].text),
      'phoneNumber': _nullableText(_controllers[6].text),
    });
    if (success && mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return _AuthScaffold(
      title: 'Create your account',
      subtitle: 'Use the details required by the bookstore service.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _EmailField(controller: _controllers[0]),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _controllers[1],
              obscureText: _obscure,
              validator: _requiredPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show passwords' : 'Hide passwords',
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _controllers[2],
              obscureText: _obscure,
              validator: (value) => value != _controllers[1].text
                  ? 'Passwords do not match.'
                  : _requiredPassword(value),
              decoration: const InputDecoration(labelText: 'Confirm password'),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controllers[3],
                    decoration: const InputDecoration(labelText: 'First name'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _controllers[4],
                    decoration: const InputDecoration(labelText: 'Last name'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _controllers[5],
              decoration: const InputDecoration(
                labelText: 'Gender (optional)',
                helperText: 'The API does not document a fixed set of values.',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _controllers[6],
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
              decoration: const InputDecoration(
                labelText: 'Phone number (optional)',
              ),
            ),
            _AuthFeedback(state: auth),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: auth.isBusy ? null : _submit,
                child: auth.isBusy
                    ? const CircularProgressIndicator()
                    : const Text('Create account'),
              ),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('Already have an account? Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordRecoveryScreen extends ConsumerStatefulWidget {
  const PasswordRecoveryScreen({required this.reset, super.key});
  final bool reset;

  @override
  ConsumerState<PasswordRecoveryScreen> createState() =>
      _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState
    extends ConsumerState<PasswordRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _token = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _token.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(authControllerProvider.notifier);
    final success = widget.reset
        ? await controller.resetPassword(
            password: _password.text,
            passwordConfirm: _confirm.text,
            token: _token.text,
          )
        : await controller.forgotPassword(_email.text);
    if (success && mounted && widget.reset) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    return _AuthScaffold(
      title: widget.reset ? 'Reset password' : 'Recover access',
      subtitle: widget.reset
          ? 'Enter the reset token supplied by the backend and choose a new password.'
          : 'Request reset instructions for your account email.',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            if (!widget.reset)
              _EmailField(controller: _email)
            else ...[
              TextFormField(
                controller: _token,
                validator: (value) => value?.trim().isEmpty ?? true
                    ? 'Enter the reset token.'
                    : null,
                decoration: const InputDecoration(labelText: 'Reset token'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _password,
                obscureText: true,
                validator: _requiredPassword,
                decoration: const InputDecoration(labelText: 'New password'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _confirm,
                obscureText: true,
                validator: (value) => value != _password.text
                    ? 'Passwords do not match.'
                    : _requiredPassword(value),
                decoration: const InputDecoration(
                  labelText: 'Confirm new password',
                ),
              ),
            ],
            _AuthFeedback(state: state),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: state.isBusy ? null : _submit,
                child: Text(widget.reset ? 'Update password' : 'Request reset'),
              ),
            ),
            if (!widget.reset)
              TextButton(
                onPressed: () => context.push(AppRoutes.resetPassword),
                child: const Text('I already have a reset token'),
              ),
          ],
        ),
      ),
    );
  }
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.midnight,
    appBar: AppBar(
      leading: const BackButton(),
      title: const Text('LEAF & LOOM'),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Text(title, style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: TextInputType.emailAddress,
    autofillHints: const [AutofillHints.email],
    textInputAction: TextInputAction.next,
    validator: (value) {
      final email = value?.trim() ?? '';
      if (email.isEmpty) return 'Enter your email address.';
      if (!email.contains('@') || !email.contains('.')) {
        return 'Enter a valid email address.';
      }
      return null;
    },
    decoration: const InputDecoration(labelText: 'Email address'),
  );
}

class _AuthFeedback extends StatelessWidget {
  const _AuthFeedback({required this.state});
  final AuthState state;

  @override
  Widget build(BuildContext context) {
    final text = state.errorMessage ?? state.message;
    if (text == null) return const SizedBox.shrink();
    final error = state.errorMessage != null;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Semantics(
        liveRegion: true,
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: error
                ? Theme.of(context).colorScheme.error
                : AppColors.success,
          ),
        ),
      ),
    );
  }
}

String? _requiredPassword(String? value) {
  if (value == null || value.isEmpty) return 'Enter a password.';
  if (value.length < 6) return 'Use at least 6 characters.';
  return null;
}

String? _nullableText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
