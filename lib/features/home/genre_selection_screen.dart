import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/controllers/movie_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/genre_chip.dart';
import '../discover/discover_screen.dart';

/// Tela de seleção de gêneros
class GenreSelectionScreen extends StatelessWidget {
  const GenreSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializa o controller
    final MovieController controller = Get.put(MovieController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),

            // Conteúdo
            Expanded(
              child: Obx(() {
                if (controller.isLoadingGenres.value) {
                  return _buildLoadingState();
                }

                if (controller.errorMessage.isNotEmpty &&
                    controller.genres.isEmpty) {
                  return _buildErrorState(controller);
                }

                return _buildGenreGrid(controller);
              }),
            ),

            // Rodapé com selecionados e botão
            Obx(() => _buildFooter(context, controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.movie_filter_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'CineMatch',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Ícone de perfil
              GestureDetector(
                onTap: () => Get.toNamed('/profile'),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surfaceLight),
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
          const SizedBox(height: 24),
          Text(
            'O que você quer assistir hoje?',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecione um ou mais gêneros para encontrar o filme perfeito',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(
          10,
          (index) => Shimmer.fromColors(
            baseColor: AppColors.surface,
            highlightColor: AppColors.surfaceLight,
            child: Container(
              width: 100,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(MovieController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColors.error.withOpacity(0.8),
          ),
          const SizedBox(height: 16),
          Text(
            'Ops! Algo deu errado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.fetchGenres(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreGrid(MovieController controller) {
    final genres = controller.genres;

    // Ícones para cada gênero
    final genreIcons = <int, IconData>{
      28: Icons.sports_mma, // Ação
      12: Icons.explore, // Aventura
      16: Icons.animation, // Animação
      35: Icons.sentiment_very_satisfied, // Comédia
      80: Icons.local_police, // Crime
      99: Icons.videocam, // Documentário
      18: Icons.theater_comedy, // Drama
      10751: Icons.family_restroom, // Família
      14: Icons.auto_fix_high, // Fantasia
      36: Icons.history_edu, // História
      27: Icons.mood_bad, // Terror
      10402: Icons.music_note, // Música
      9648: Icons.search, // Mistério
      10749: Icons.favorite, // Romance
      878: Icons.rocket_launch, // Ficção científica
      10770: Icons.tv, // Cinema TV
      53: Icons.psychology, // Thriller
      10752: Icons.military_tech, // Guerra
      37: Icons.landscape, // Faroeste
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: genres.map((genre) {
          return GenreChip(
            label: genre.name,
            isSelected: controller.isGenreSelected(genre),
            onTap: () => controller.toggleGenre(genre),
            icon: genreIcons[genre.id],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, MovieController controller) {
    final selectedCount = controller.selectedGenres.length;
    final canContinue = selectedCount > 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Contador e limpar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$selectedCount ',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    TextSpan(
                      text: selectedCount == 1
                          ? 'gênero selecionado'
                          : 'gêneros selecionados',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedCount > 0)
                TextButton(
                  onPressed: () => controller.clearSelection(),
                  child: const Text(
                    'Limpar',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Botão continuar
          SizedBox(
            width: double.infinity,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton(
                onPressed: canContinue
                    ? () => Get.to(
                        () => const DiscoverScreen(),
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300),
                      )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canContinue
                      ? AppColors.primary
                      : AppColors.surface,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.surface,
                  disabledForegroundColor: AppColors.textMuted,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      canContinue ? 'Continuar' : 'Selecione um gênero',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (canContinue) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
