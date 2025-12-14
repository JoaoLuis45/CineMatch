import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/movie_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/animated_search_button.dart';
import '../result/movie_result_screen.dart';

/// Tela de descoberta com botão animado
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MovieController controller = Get.find<MovieController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF1A0F0F), AppColors.background],
          ),
        ),
        child: SafeArea(child: Obx(() => _buildContent(context, controller))),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MovieController controller) {
    return Column(
      children: [
        const Spacer(flex: 1),

        // Título
        _buildTitle(context),
        const SizedBox(height: 16),

        // Gêneros selecionados
        _buildSelectedGenres(controller),

        const Spacer(flex: 1),

        // Botão central animado
        Center(
          child: AnimatedSearchButton(
            isLoading: controller.isSearching.value,
            isEnabled: controller.canSearch,
            onPressed: () => _handleDiscoverPress(controller),
          ),
        ),

        const Spacer(flex: 1),

        // Instruções
        _buildInstructions(),

        const Spacer(flex: 1),
      ],
    );
  }

  void _handleDiscoverPress(MovieController controller) async {
    try {
      await controller.findRandomMovie();

      if (controller.errorMessage.isNotEmpty) {
        Get.snackbar(
          'Atenção',
          controller.errorMessage.value,
          backgroundColor: AppColors.surface,
          colorText: AppColors.textPrimary,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
          ),
        );
        controller.errorMessage.value = '';
        return;
      }

      if (controller.recommendedMovie.value != null) {
        Get.to(
          () => const MovieResultScreen(),
          transition: Transition.zoom,
          duration: const Duration(milliseconds: 400),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Ocorreu um erro ao buscar o filme. Tente novamente.',
        backgroundColor: AppColors.surface,
        colorText: AppColors.textPrimary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            'Pronto para descobrir?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no botão para encontrar seu filme',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedGenres(MovieController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: controller.selectedGenres.map((genre) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.5)),
            ),
            child: Text(
              genre.name,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInstructions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app_rounded, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(
            'Toque para descobrir',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
