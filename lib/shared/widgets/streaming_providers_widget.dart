import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/watch_provider.dart';
import '../../core/theme/app_theme.dart';

/// Widget para exibir provedores de streaming
class StreamingProvidersWidget extends StatelessWidget {
  final WatchProviders? providers;
  final bool isLoading;
  final String movieTitle;

  const StreamingProvidersWidget({
    super.key,
    required this.providers,
    this.isLoading = false,
    required this.movieTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (providers == null || !providers!.hasAnyProvider) {
      return _buildNoProvidersState();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Row(
            children: [
              Icon(
                Icons.play_circle_outline_rounded,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Onde assistir',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Streaming (flatrate)
          if (providers!.streamingProviders.isNotEmpty) ...[
            _buildSection('Streaming', providers!.streamingProviders),
          ],

          // Alugar
          if (providers!.rent.isNotEmpty) ...[
            if (providers!.streamingProviders.isNotEmpty)
              const SizedBox(height: 12),
            _buildSection('Alugar', providers!.rent),
          ],

          // Comprar
          if (providers!.buy.isNotEmpty) ...[
            if (providers!.streamingProviders.isNotEmpty ||
                providers!.rent.isNotEmpty)
              const SizedBox(height: 12),
            _buildSection('Comprar', providers!.buy),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.surface,
            highlightColor: AppColors.surfaceLight,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Buscando onde assistir...',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNoProvidersState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Informação de streaming não disponível para este filme no Brasil',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _launchGoogleSearch,
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Buscar no Google'),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.backgroundLight,
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(color: AppColors.surfaceLight),
                padding: const EdgeInsets.symmetric(vertical: 12),
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

  Future<void> _launchGoogleSearch() async {
    final query = Uri.encodeComponent('onde assistir $movieTitle');
    final url = Uri.parse('https://www.google.com/search?q=$query');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Erro ao abrir navegador: $e');
    }
  }

  Widget _buildSection(String title, List<WatchProvider> providersList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: providersList.map((provider) {
            return _buildProviderChip(provider);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProviderChip(WatchProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo do provedor
          if (provider.logoUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: provider.logoUrl,
                width: 24,
                height: 24,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(width: 24, height: 24, color: AppColors.surface),
                errorWidget: (context, url, error) => Icon(
                  Icons.play_arrow_rounded,
                  size: 24,
                  color: AppColors.textMuted,
                ),
              ),
            )
          else
            Icon(
              Icons.play_arrow_rounded,
              size: 24,
              color: AppColors.textMuted,
            ),
          const SizedBox(width: 6),
          Text(
            provider.providerName,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
