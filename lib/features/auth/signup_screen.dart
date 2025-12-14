import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';

/// Tela de Cadastro
class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

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
                  const SizedBox(height: 40),

                  // Botão Voltar
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Título
                  _buildHeader(),
                  const SizedBox(height: 40),

                  // Campo Nome
                  _buildNameField(controller),
                  const SizedBox(height: 16),

                  // Campo Email
                  _buildEmailField(controller),
                  const SizedBox(height: 16),

                  // Campo Senha
                  _buildPasswordField(controller),
                  const SizedBox(height: 16),

                  // Campo Confirmar Senha
                  _buildConfirmPasswordField(controller),
                  const SizedBox(height: 24),

                  // Mensagem de erro
                  _buildErrorMessage(controller),

                  // Botão Cadastrar
                  _buildSignUpButton(controller),
                  const SizedBox(height: 24),

                  // Link para login
                  _buildLoginLink(),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Criar Conta',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Junte-se à comunidade de cinéfilos',
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildNameField(AuthController controller) {
    return TextFormField(
      controller: controller.nameController,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Nome',
        labelStyle: TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(
          Icons.person_outline_rounded,
          color: AppColors.textMuted,
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
      validator: controller.validateName,
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
          helperText: 'Mínimo 6 caracteres',
          helperStyle: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        validator: controller.validatePassword,
      ),
    );
  }

  Widget _buildConfirmPasswordField(AuthController controller) {
    return Obx(
      () => TextFormField(
        controller: controller.confirmPasswordController,
        obscureText: !controller.isConfirmPasswordVisible.value,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: 'Confirmar Senha',
          labelStyle: TextStyle(color: AppColors.textMuted),
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: AppColors.textMuted,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              controller.isConfirmPasswordVisible.value
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.textMuted,
            ),
            onPressed: controller.toggleConfirmPasswordVisibility,
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
        validator: controller.validateConfirmPassword,
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

  Widget _buildSignUpButton(AuthController controller) {
    return Obx(
      () => SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    final success = await controller.signUp();
                    if (success) {
                      Get.offAllNamed('/welcome');
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
                  'Criar Conta',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Já tem uma conta? ',
          style: TextStyle(color: AppColors.textMuted),
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: const Text(
            'Entrar',
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
