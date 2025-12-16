import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/controllers/auth_controller.dart';
import '../../core/controllers/movie_controller.dart';
import '../../core/services/user_service.dart';
import '../../core/theme/app_theme.dart';

/// Tela de Perfil do Usuário
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final MovieController _movieController = Get.find<MovieController>();
  final UserService _userService = UserService();

  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String? _selectedGender; // Novo campo de gênero
  final Set<int> _selectedGenreIds = {};
  File? _imageFile;
  bool _isEditing = false;
  bool _isLoading = true;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _nameController.text = _authController.userName;
    _loadUserProfile();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = 'Versão ${info.version}';
        });
      }
    } catch (e) {
      // Ignora erro (comum em hot-reload ao adicionar plugins nativos)
      debugPrint('Erro ao carregar versão: $e');
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _userService.loadUserProfile();
      if (profile != null && mounted) {
        setState(() {
          final genreIds = profile['favoriteGenreIds'];
          if (genreIds != null) {
            _selectedGenreIds.addAll(List<int>.from(genreIds));
          }
          if (profile['birthDate'] != null) {
            _birthDate = (profile['birthDate'] as dynamic).toDate();
          }
          if (profile['gender'] != null) {
            _selectedGender = profile['gender'];
          }

          // Se o nome do controller estiver vazio mas tiver no profile, atualiza
          if (_nameController.text.isEmpty ||
              _nameController.text == 'Cinéfilo') {
            if (profile['displayName'] != null) {
              _nameController.text = profile['displayName'];
            }
          }

          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Meu Perfil'),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (!_authController.isGuest)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                color: _isEditing ? Colors.green : AppColors.textPrimary,
              ),
              onPressed: () {
                if (_isEditing) {
                  _saveProfile();
                }
                setState(() => _isEditing = !_isEditing);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Foto de perfil
            _buildProfilePhoto(),
            const SizedBox(height: 32),

            // Informações do perfil
            if (_authController.isGuest)
              _buildGuestInfo()
            else
              _buildProfileInfo(),
            const SizedBox(height: 32),

            // Preferências
            if (!_authController.isGuest) ...[
              _buildPreferences(),
              const SizedBox(height: 40),
            ],

            // Botão Logout
            _buildLogoutButton(),
            const SizedBox(height: 32),

            // Versão
            Text(
              _appVersion,
              style: TextStyle(
                color: AppColors.textMuted.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhoto() {
    final user = _authController.user.value;
    final photoUrl = user?.photoURL;

    return GestureDetector(
      onTap: _isEditing ? _pickImage : null,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: ClipOval(
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : photoUrl != null && photoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: photoUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _buildDefaultAvatar(),
                        errorWidget: (_, __, ___) => _buildDefaultAvatar(),
                      )
                    : _buildDefaultAvatar(),
              ),
            ),
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Text(
          _authController.userName.isNotEmpty
              ? _authController.userName[0].toUpperCase()
              : '?',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        children: [
          // Nome
          _buildInfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Nome',
            value: _authController.userName, // Fallback visual
            isEditable: _isEditing,
            controller: _nameController,
          ),
          const Divider(color: AppColors.surfaceLight, height: 24),

          // Email
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: _authController.userEmail,
            isEditable: false,
          ),
          const Divider(color: AppColors.surfaceLight, height: 24),

          // Gênero
          _buildGenderRow(),
          const Divider(color: AppColors.surfaceLight, height: 24),

          // Data de nascimento
          _buildDateRow(),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isEditable = false,
    TextEditingController? controller,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              isEditable && controller != null
                  ? TextField(
                      controller: controller,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                    )
                  : Text(
                      (isEditable &&
                              controller != null &&
                              controller.text.isNotEmpty)
                          ? controller.text
                          : (value.isEmpty ? 'Não informado' : value),
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            (value.isEmpty &&
                                (controller?.text.isEmpty ?? true))
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderRow() {
    return Row(
      children: [
        Icon(
          _selectedGender == 'Feminino'
              ? Icons.female
              : _selectedGender == 'Masculino'
              ? Icons.male
              : Icons.people_outline_rounded,
          color: AppColors.textMuted,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gênero',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              if (_isEditing)
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: ['Feminino', 'Masculino'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  dropdownColor: AppColors.surface,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.primary,
                  ),
                )
              else
                Text(
                  _selectedGender ?? 'Conte-nos (Opcional)',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedGender == null
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow() {
    return GestureDetector(
      onTap: _isEditing ? _pickDate : null,
      child: Row(
        children: [
          Icon(Icons.cake_outlined, color: AppColors.textMuted, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data de Nascimento',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _birthDate != null
                          ? '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}'
                          : 'Não informado',
                      style: TextStyle(
                        fontSize: 16,
                        color: _birthDate != null
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                    if (_isEditing) ...[
                      const Spacer(),
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferences() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.movie_filter_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gêneros Preferidos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _selectedGenreIds.isEmpty
                          ? 'Selecione seus gêneros favoritos'
                          : '${_selectedGenreIds.length} selecionado(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedGenreIds.isNotEmpty && _isEditing)
                GestureDetector(
                  onTap: () => setState(() => _selectedGenreIds.clear()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Limpar',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (_movieController.genres.isEmpty) {
              return Text(
                'Carregando gêneros...',
                style: TextStyle(color: AppColors.textMuted),
              );
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _movieController.genres.map((genre) {
                final isSelected = _selectedGenreIds.contains(genre.id);
                return GestureDetector(
                  onTap: _isEditing
                      ? () {
                          setState(() {
                            if (isSelected) {
                              _selectedGenreIds.remove(genre.id);
                            } else {
                              _selectedGenreIds.add(genre.id);
                            }
                          });
                        }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceLight,
                      ),
                    ),
                    child: Text(
                      genre.name,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGuestInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_circle_outlined,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          const Text(
            'Você é um visitante',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie uma conta para salvar seu histórico, preferências e acessar em outros dispositivos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    final isGuest = _authController.isGuest;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: Icon(isGuest ? Icons.login_rounded : Icons.logout_rounded),
        label: Text(isGuest ? 'Fazer Login / Criar Conta' : 'Sair da Conta'),
        style: OutlinedButton.styleFrom(
          foregroundColor: isGuest ? AppColors.primary : AppColors.error,
          side: BorderSide(
            color: isGuest
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.error.withOpacity(0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível selecionar a imagem',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _birthDate = date);
    }
  }

  Future<void> _saveProfile() async {
    try {
      if (_isLoading) return;

      setState(() => _isLoading = true);

      // Upload da imagem se houver
      String? photoUrl;
      if (_imageFile != null) {
        photoUrl = await _userService.uploadProfileImage(_imageFile!);
        if (photoUrl != null) {
          await _authController.updatePhotoUrl(photoUrl);
        }
      }

      // Obtém os nomes dos gêneros selecionados
      final selectedGenreNames = _movieController.genres
          .where((g) => _selectedGenreIds.contains(g.id))
          .map((g) => g.name)
          .toList();

      // Salva no Firestore
      await _userService.saveUserProfile(
        displayName: _nameController.text,
        gender: _selectedGender,
        birthDate: _birthDate,
        photoUrl: photoUrl,
        favoriteGenres: selectedGenreNames,
        favoriteGenreIds: _selectedGenreIds.toList(),
      );

      // Atualiza o nome no AuthController se houver mudança
      if (_nameController.text.isNotEmpty) {
        await _authController.updateDisplayName(_nameController.text);
      }

      // Recarrega dados localmente
      await _loadUserProfile();

      Get.snackbar(
        'Sucesso',
        'Perfil atualizado!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Não foi possível salvar o perfil: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Sair da conta?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Você precisará fazer login novamente.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authController.signOut();
      Get.offAllNamed('/login');
    }
  }
}
