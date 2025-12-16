import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/movie_controller.dart';
import '../../core/theme/app_theme.dart';
import '../result/movie_result_screen.dart';

class AIDiscoveryScreen extends StatefulWidget {
  const AIDiscoveryScreen({super.key});

  @override
  State<AIDiscoveryScreen> createState() => _AIDiscoveryScreenState();
}

class _AIDiscoveryScreenState extends State<AIDiscoveryScreen> {
  final MovieController _controller = Get.find<MovieController>();
  final TextEditingController _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    // Fecha o teclado
    FocusScope.of(context).unfocus();

    await _controller.searchMovieByPrompt(prompt);

    if (_controller.errorMessage.isNotEmpty) {
      Get.snackbar(
        'Ops!',
        _controller.errorMessage.value,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } else if (_controller.recommendedMovie.value != null) {
      Get.to(() => const MovieResultScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Descobrir com IA'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.auto_awesome, size: 48, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'Me diga o que você quer assistir',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ex: "Filme de terror psicológico que se passa em um hotel" ou "Comédia romântica dos anos 90"',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceLight),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _promptController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Digite aqui...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _controller.isAiLoading.value
                      ? null
                      : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _controller.isAiLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome),
                            SizedBox(width: 12),
                            Text(
                              'Encontrar Filme Mágico',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
