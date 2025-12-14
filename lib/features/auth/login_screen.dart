import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import 'signup_screen.dart';

/// Tela de Login
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0F0F), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),

                  // Logo/Título
                  _buildHeader(),
                  const SizedBox(height: 48),

                  // Campo Email
                  _buildEmailField(controller),
                  const SizedBox(height: 16),

                  // Campo Senha
                  _buildPasswordField(controller),
                  const SizedBox(height: 8),

                  // Esqueceu a senha?
                  _buildForgotPassword(controller),
                  const SizedBox(height: 32),

                  // Mensagem de erro
                  _buildErrorMessage(controller),

                  // Botão Login
                  _buildLoginButton(controller),
                  const SizedBox(height: 24),

                  // Divider
                  _buildDivider(),
                  const SizedBox(height: 24),

                  // Botão Google
                  _buildGoogleButton(controller),
                  const SizedBox(height: 24),

                  // Link para cadastro
                  _buildSignUpLink(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Ícone de cinema
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.movie_filter_rounded,
            size: 48,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'CineMatch',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Entre para descobrir seu próximo filme',
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildEmailField(AuthController controller) {
    return TextFormField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
      ),
      validator: controller.validateEmail,
    );
  }

  Widget _buildPasswordField(AuthController controller) {
    return Obx(
      () => TextFormField(
        controller: controller.passwordController,
        obscureText: !controller.isPasswordVisible.value,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: 'Senha',
          labelStyle: TextStyle(color: AppColors.textMuted),
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: AppColors.textMuted,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              controller.isPasswordVisible.value
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.textMuted,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        validator: controller.validatePassword,
      ),
    );
  }

  Widget _buildForgotPassword(AuthController controller) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _showForgotPasswordDialog(controller),
        child: Text(
          'Esqueceu a senha?',
          style: TextStyle(color: AppColors.primary, fontSize: 13),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(AuthController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Recuperar Senha',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Digite seu email para receber o link de recuperação',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.emailController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.resetPassword();
              Get.back();
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(AuthController controller) {
    return Obx(() {
      if (controller.errorMessage.isEmpty) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                controller.errorMessage.value,
                style: TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLoginButton(AuthController controller) {
    return Obx(
      () => SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    final success = await controller.signIn();
                    if (success) {
                      if (await controller.shouldShowWelcome()) {
                        Get.offAllNamed('/welcome');
                      } else {
                        Get.offAllNamed('/home');
                      }
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Entrar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.surfaceLight)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ou',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
        Expanded(child: Divider(color: AppColors.surfaceLight)),
      ],
    );
  }

  Widget _buildGoogleButton(AuthController controller) {
    return Obx(
      () => SizedBox(
        height: 54,
        child: OutlinedButton(
          onPressed: controller.isLoading.value
              ? null
              : () async {
                  final success = await controller.signInWithGoogle();
                  if (success) {
                    if (await controller.shouldShowWelcome()) {
                      Get.offAllNamed('/welcome');
                    } else {
                      Get.offAllNamed('/home');
                    }
                  }
                },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: BorderSide(color: AppColors.surfaceLight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                height: 24,
                width: 24,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.g_mobiledata_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Continuar com Google',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Não tem uma conta? ',
          style: TextStyle(color: AppColors.textMuted),
        ),
        TextButton(
          onPressed: () => Get.to(() => SignUpScreen()),
          child: const Text(
            'Cadastre-se',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
