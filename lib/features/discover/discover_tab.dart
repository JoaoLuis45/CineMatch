import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/movie_controller.dart';
import '../../core/services/user_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/genre_chip.dart';
import '../discover/discover_screen.dart';
import '../search/movie_search_screen.dart';

/// Aba de descoberta de filmes - Redesenhada
class DiscoverTab extends StatefulWidget {
  const DiscoverTab({super.key});

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  final MovieController _movieController = Get.find<MovieController>();
  final UserService _userService = UserService();

  // Estado local dos filtros
  final Set<int> _selectedProviders = {};
  List<String> _userFavoriteGenres = [];
  List<int> _userFavoriteGenreIds = [];
  bool _excludeWatched = false;

  // Provedores de streaming populares
  final List<Map<String, dynamic>> _streamingProviders = [
    {'id': 8, 'name': 'Netflix', 'color': const Color(0xFFE50914)},
    {'id': 119, 'name': 'Prime Video', 'color': const Color(0xFF00A8E1)},
    {'id': 337, 'name': 'Disney+', 'color': const Color(0xFF113CCF)},
    {'id': 384, 'name': 'HBO Max', 'color': const Color(0xFF5822B4)},
    {'id': 531, 'name': 'Paramount+', 'color': const Color(0xFF0068DE)},
    {'id': 350, 'name': 'Apple TV+', 'color': const Color(0xFF555555)},
    {'id': 283, 'name': 'Crunchyroll', 'color': const Color(0xFFF47521)},
    {'id': 307, 'name': 'Globoplay', 'color': const Color(0xFFFF0000)},
  ];

  // Ícones de gêneros
  final Map<int, IconData> _genreIcons = {
    28: Icons.sports_mma,
    12: Icons.explore,
    16: Icons.animation,
    35: Icons.sentiment_very_satisfied,
    80: Icons.local_police,
    99: Icons.videocam,
    18: Icons.theater_comedy,
    10751: Icons.family_restroom,
    14: Icons.auto_fix_high,
    36: Icons.history_edu,
    27: Icons.mood_bad,
    10402: Icons.music_note,
    9648: Icons.search,
    10749: Icons.favorite,
    878: Icons.rocket_launch,
    10770: Icons.tv,
    53: Icons.psychology,
    10752: Icons.military_tech,
    37: Icons.landscape,
  };

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarrega preferências sempre que a tela fica visível
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    try {
      final profile = await _userService.loadUserProfile();
      if (profile != null && mounted) {
        setState(() {
          _userFavoriteGenres = List<String>.from(
            profile['favoriteGenres'] ?? [],
          );
          _userFavoriteGenreIds = List<int>.from(
            profile['favoriteGenreIds'] ?? [],
          );
        });
      }
    } catch (e) {
      // Ignora erro
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildQuickDiscoverySection(),
                  const SizedBox(height: 28),
                  _buildStreamingSection(),
                  const SizedBox(height: 28),
                  _buildGenresSection(),
                  const SizedBox(height: 28),
                  _buildRatingSection(),
                  const SizedBox(height: 24),
                  _buildWatchedFilterSection(),
                  const SizedBox(height: 32),
                  _buildDiscoverButton(),
                  const SizedBox(height: 180),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      floating: true,
      pinned: false,
      expandedHeight: 100,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.movie_filter_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Descobrir',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Encontre seu próximo filme',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Botão de busca
              GestureDetector(
                onTap: () => Get.to(() => MovieSearchScreen()),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Botão de perfil
              GestureDetector(
                onTap: () => Get.toNamed('/profile'),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickDiscoverySection() {
    final hasPreferences = _userFavoriteGenreIds.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Discovery Automático',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      hasPreferences
                          ? '${_userFavoriteGenres.length} gêneros configurados'
                          : 'Baseado nos seus gêneros preferidos',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleAutoDiscovery,
              icon: Icon(
                hasPreferences ? Icons.shuffle_rounded : Icons.settings_rounded,
                size: 20,
              ),
              label: Text(
                hasPreferences ? 'Descobrir Agora' : 'Configurar Preferências',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamingSection() {
    return _buildSection(
      icon: Icons.play_circle_outline_rounded,
      title: 'Onde Assistir',
      subtitle: 'Filtre por plataforma de streaming',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _streamingProviders.map((provider) {
          final isSelected = _selectedProviders.contains(provider['id']);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedProviders.remove(provider['id']);
                } else {
                  _selectedProviders.add(provider['id'] as int);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? (provider['color'] as Color).withOpacity(0.2)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? provider['color'] as Color
                      : AppColors.surfaceLight,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: provider['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    provider['name'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? provider['color'] as Color
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGenresSection() {
    return _buildSection(
      icon: Icons.category_rounded,
      title: 'Gêneros',
      subtitle: 'Selecione um ou mais gêneros',
      trailing: Obx(() {
        final count = _movieController.selectedGenres.length;
        if (count == 0) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => _movieController.clearSelection(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Limpar ($count)',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
      child: Obx(() {
        if (_movieController.genres.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _movieController.genres.map((genre) {
            return GenreChip(
              label: genre.name,
              isSelected: _movieController.isGenreSelected(genre),
              onTap: () => _movieController.toggleGenre(genre),
              icon: _genreIcons[genre.id],
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildRatingSection() {
    return _buildSection(
      icon: Icons.star_rounded,
      title: 'Nota Mínima',
      subtitle: 'Apenas filmes bem avaliados',
      child: Obx(
        () => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    final rating = (index + 1) * 2;
                    final isActive = _movieController.minRating.value >= rating;
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.star_rounded,
                        size: 24,
                        color: isActive
                            ? AppColors.secondary
                            : AppColors.surfaceLight,
                      ),
                    );
                  }),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_movieController.minRating.value.toStringAsFixed(1)}+',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.secondary,
                inactiveTrackColor: AppColors.surfaceLight,
                thumbColor: AppColors.secondary,
                overlayColor: AppColors.secondary.withOpacity(0.2),
                trackHeight: 4,
              ),
              child: Slider(
                value: _movieController.minRating.value,
                min: 0,
                max: 10,
                divisions: 20,
                onChanged: (value) => _movieController.minRating.value = value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchedFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility_off_rounded,
            color: _excludeWatched ? Colors.green : AppColors.textMuted,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ocultar filmes assistidos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Não incluir filmes que você já viu',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: _excludeWatched,
            onChanged: (value) => setState(() => _excludeWatched = value),
            activeColor: Colors.green,
            activeTrackColor: Colors.green.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildDiscoverButton() {
    return Obx(() {
      final hasSelection =
          _movieController.selectedGenres.isNotEmpty ||
          _selectedProviders.isNotEmpty;

      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: hasSelection ? _handleDiscover : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.surface,
            disabledForegroundColor: AppColors.textMuted,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: hasSelection ? 8 : 0,
            shadowColor: AppColors.primary.withOpacity(0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasSelection
                    ? Icons.movie_filter_rounded
                    : Icons.touch_app_rounded,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                hasSelection ? 'Descobrir Filme' : 'Selecione os filtros',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _handleAutoDiscovery() {
    if (_userFavoriteGenreIds.isEmpty) {
      Get.toNamed('/profile');
      Get.snackbar(
        'Configure seu perfil',
        'Selecione seus gêneros preferidos para usar o Discovery Automático',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } else {
      _movieController.clearSelection();

      for (final genreId in _userFavoriteGenreIds) {
        final genre = _movieController.genres.firstWhereOrNull(
          (g) => g.id == genreId,
        );
        if (genre != null) {
          _movieController.toggleGenre(genre);
        }
      }

      _handleDiscover();
    }
  }

  void _handleDiscover() {
    Get.to(() => const DiscoverScreen(), transition: Transition.rightToLeft);
  }
}
