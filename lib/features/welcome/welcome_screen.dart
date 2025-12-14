import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'welcome_controller.dart';
import '../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WelcomeController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Elements
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF140B0B), AppColors.background],
                ),
              ),
            ),
          ),

          // Content
          Column(
            children: [
              Expanded(
                child: PageView(
                  controller: controller.pageController,
                  onPageChanged: controller.updatePage,
                  physics:
                      const NeverScrollableScrollPhysics(), // Control navigation manually
                  children: [
                    _buildIntroPage(),
                    _buildBioPage(controller, context),
                    _buildGenresPage(controller),
                    _buildTourPage(),
                  ],
                ),
              ),

              // Bottom Controls
              _buildBottomControls(controller),
            ],
          ),

          // Skip Button (Top Right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 24,
            child: Obx(
              () => controller.currentPage.value < 3
                  ? TextButton(
                      onPressed: controller.skip,
                      child: Text(
                        'Pular',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroPage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_filter_rounded, size: 80, color: AppColors.primary),
          const SizedBox(height: 32),
          Text(
            'Bem-vindo ao\nCineMatch',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sua jornada cinematográfica começa aqui. Vamos personalizar sua experiência?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioPage(WelcomeController controller, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sobre você',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Isso nos ajuda a sugerir filmes que você vai amar (opcional).',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 48),

          // Gender
          Text(
            'Gênero',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildGenderOption(controller, 'Feminino', Icons.female),
              const SizedBox(width: 16),
              _buildGenderOption(controller, 'Masculino', Icons.male),
            ],
          ),
          const SizedBox(height: 32),

          // Birth Date
          Text(
            'Data de Nascimento',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.dark(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        surface: AppColors.surface,
                        onSurface: AppColors.textPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) controller.setBirthDate(date);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceLight),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Obx(
                    () => Text(
                      controller.selectedBirthDate.value != null
                          ? DateFormat(
                              'dd/MM/yyyy',
                            ).format(controller.selectedBirthDate.value!)
                          : 'Selecionar data',
                      style: TextStyle(
                        color: controller.selectedBirthDate.value != null
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(
    WelcomeController controller,
    String label,
    IconData icon,
  ) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedGender.value == label;
        return GestureDetector(
          onTap: () => controller.setGender(label),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.2)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.surfaceLight,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGenresPage(WelcomeController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'Seus Gostos',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecione os gêneros que você curte.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingGenres.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              return SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: controller.genres.map((genre) {
                    final isSelected = controller.selectedGenreIds.contains(
                      genre.id,
                    );
                    return FilterChip(
                      label: Text(genre.name),
                      selected: isSelected,
                      onSelected: (_) => controller.toggleGenre(genre.id),
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : AppColors.surfaceLight,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTourPage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFeatureItem(
            Icons.shuffle_rounded,
            'Descubra',
            'Encontre filmes aleatórios baseados no que você gosta de assistir.',
          ),
          const SizedBox(height: 40),
          _buildFeatureItem(
            Icons.play_circle_outline_rounded,
            'Onde Assistir',
            'Saiba exatamente em qual streaming o filme está disponível.',
          ),
          const SizedBox(height: 40),
          _buildFeatureItem(
            Icons.history_rounded,
            'Histórico',
            'Mantenha um registro de tudo que você descobriu.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String desc) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 32),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(WelcomeController controller) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: SafeArea(
        // Using safe area here or ensure bottom padding respects it
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Indicators
            Obx(
              () => Row(
                children: List.generate(4, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 8),
                    width: controller.currentPage.value == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: controller.currentPage.value == index
                          ? AppColors.primary
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Next Button
            Obx(() {
              final isLast = controller.currentPage.value == 3;
              return ElevatedButton(
                onPressed: controller.nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLast
                      ? AppColors.primary
                      : AppColors.surface,
                  foregroundColor: isLast
                      ? Colors.white
                      : AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  children: [
                    Text(isLast ? 'Começar' : 'Próximo'),
                    const SizedBox(width: 8),
                    Icon(
                      isLast ? Icons.check : Icons.arrow_forward_rounded,
                      size: 18,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
