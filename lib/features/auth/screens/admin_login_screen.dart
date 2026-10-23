import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:verso_admin/core/design/design.dart';
import 'package:verso_admin/core/error/app_error_handler.dart';
import 'package:verso_admin/features/auth/providers/admin_auth_provider.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success =
        await ref.read(adminLoginControllerProvider.notifier).login(
              email: _emailController.text,
              password: _passwordController.text,
            );

    if (!mounted) return;

    if (success) {
      VersoSnackbar.success(
        context,
        message: 'Admin access granted. Welcome to Verso Admin.',
      );
      context.go('/dashboard');
    } else {
      final state = ref.read(adminLoginControllerProvider);
      final errorMsg = state.hasError
          ? AppErrorHandler.getMessage(state.error!)
          : 'Authentication failed. Please check your credentials.';
      VersoSnackbar.error(context, message: errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(adminLoginControllerProvider);
    final isLoading = loginState.isLoading;
    final textTheme = context.textTheme;
    final colors = context.colors;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: VersoAuthGradient.of(context)),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: Spacing.pagePadding,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Admin Header Icon
                      const Center(
                        child: VersoHeaderIcon(
                          icon: Icons.admin_panel_settings_rounded,
                          size: 80,
                          iconSize: 40,
                        ),
                      ),
                      const Gap(Spacing.lg),

                      // Title
                      Text(
                        'Verso Administration',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const Gap(Spacing.xs),
                      Text(
                        'Real-time operations, user telemetry & telemetry portal',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const Gap(Spacing.xxl),

                      // Card with Inputs
                      VersoCard(
                        padding: const EdgeInsets.all(Spacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            VersoTextField(
                              controller: _emailController,
                              label: 'Admin Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!val.contains('@')) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const Gap(Spacing.md),
                            VersoTextField(
                              controller: _passwordController,
                              label: 'Master Password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  size: 20,
                                  color: colors.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Password is required';
                                }
                                if (val.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const Gap(Spacing.xl),
                            VersoGradientButton(
                              label: 'Sign In to Console',
                              isLoading: isLoading,
                              onPressed: _submit,
                            ),
                          ],
                        ),
                      ),
                      const Gap(Spacing.lg),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 16,
                            color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Secured with Supabase RBAC & Audit Trails',
                            style: textTheme.labelSmall?.copyWith(
                              color:
                                  colors.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
