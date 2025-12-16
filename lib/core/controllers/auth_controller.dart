import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'movie_controller.dart';

/// Controller de autenticação GetX
class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  // Estados observáveis
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  // Controllers de formulário
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Escuta mudanças no estado de autenticação
    user.bindStream(_authService.authStateChanges);

    // Reage a mudanças no usuário
    ever(user, (User? u) {
      if (Get.isRegistered<MovieController>()) {
        final movieController = Get.find<MovieController>();
        if (u != null) {
          movieController.loadHistory();
        } else {
          movieController.clearHistory();
        }
      }
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    super.onClose();
  }

  /// Retorna se o usuário está logado
  bool get isLoggedIn => user.value != null;

  /// Retorna o nome do usuário
  String get userName => user.value?.displayName ?? 'Cinéfilo';

  /// Retorna o email do usuário
  String get userEmail => user.value?.email ?? '';

  /// Retorna se é um usuário visitante
  bool get isGuest => user.value?.isAnonymous ?? false;

  /// Login Anônimo (Visitante)
  Future<bool> signInAnonymously() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.signInAnonymously();

      // Inicializa estrutura básica no Firestore (opcional, mas bom pra evitar erros)
      await _userService.initializeUser();

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle visibilidade da senha
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Toggle visibilidade da confirmação de senha
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  /// Limpa os controllers
  void clearControllers() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    errorMessage.value = '';
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
  }

  /// Validação de email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite seu email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Digite um email válido';
    }
    return null;
  }

  /// Validação de senha
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite sua senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  /// Validação de confirmação de senha
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme sua senha';
    }
    if (value != passwordController.text) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  /// Validação de nome
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite seu nome';
    }
    if (value.length < 2) {
      return 'Nome muito curto';
    }
    return null;
  }

  final UserService _userService = UserService();

  /// Login com email e senha
  Future<bool> signIn() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.signInWithEmail(
        email: emailController.text,
        password: passwordController.text,
      );

      // Garante que o usuário existe no Firestore
      await _userService.initializeUser();

      clearControllers();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Cadastro com email e senha
  Future<bool> signUp() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.signUpWithEmail(
        email: emailController.text,
        password: passwordController.text,
        displayName: nameController.text,
      );

      // Salva dados iniciais explicitamente
      await _userService.saveUserProfile(displayName: nameController.text);
      await _userService.initializeUser();

      clearControllers();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Login com Google
  Future<bool> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _authService.signInWithGoogle();

      if (result == null) {
        // Usuário cancelou
        return false;
      }

      // Garante que o usuário existe no Firestore
      await _userService.initializeUser();

      clearControllers();
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Verifica se deve mostrar o welcome
  Future<bool> shouldShowWelcome() async {
    final completed = await _userService.isWelcomeCompleted();
    return !completed;
  }

  /// Logout
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
    } finally {
      isLoading.value = false;
    }
  }

  /// Recuperação de senha
  Future<bool> resetPassword() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _authService.resetPassword(emailController.text);

      Get.snackbar(
        'Sucesso',
        'Email de recuperação enviado!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Atualiza o nome do usuário
  Future<void> updateDisplayName(String name) async {
    await _authService.updateDisplayName(name);
    // Força atualização do estado do usuário
    user.value = _authService.currentUser;
  }

  /// Atualiza a foto do usuário
  Future<void> updatePhotoUrl(String photoUrl) async {
    await _authService.updatePhotoUrl(photoUrl);
    // Força atualização do estado do usuário
    user.value = _authService.currentUser;
  }

  /// Exclui a conta e dados do usuário
  Future<bool> deleteAccount() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // 1. Excluir dados do Firestore/Storage
      await _userService.deleteUserData();

      // 2. Excluir usuário do Auth
      await _authService.deleteAccount();

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
