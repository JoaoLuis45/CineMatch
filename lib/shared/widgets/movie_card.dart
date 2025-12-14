import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/api_constants.dart';
import '../../core/models/movie.dart';
import '../../core/theme/app_theme.dart';

/// Card do filme com efeito glassmorphism
class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;
  final VoidCallback? onTryAnother;
  final List<String> genreNames;
  final bool isWatched;

  const MovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.onTryAnother,
    this.genreNames = const [],
    this.isWatched = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        constraints: const BoxConstraints(minHeight: 500),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppShadows.large,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Backdrop como fundo
              Positioned.fill(child: _buildBackdrop()),

              // Gradiente escuro
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.95),
                      ],
                      stops: const [0.0, 0.4, 0.8],
                    ),
                  ),
                ),
              ),

              // Conteúdo
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nota no topo
                    _buildRatingBadge(),

                    const SizedBox(height: 180),

                    // Poster e informações
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Poster
                        _buildPoster(),
                        const SizedBox(width: 16),

                        // Informações
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildTitle(),
                              const SizedBox(height: 4),
                              _buildYear(),
                              const SizedBox(height: 12),
                              _buildStarRating(),
                              if (genreNames.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                _buildGenreTags(),
                              ],
                              if (isWatched) ...[
                                const SizedBox(height: 8),
                                _buildWatchedTag(),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Sinopse
                    _buildOverview(),

                    const SizedBox(height: 20),

                    // Botão tentar outro
                    if (onTryAnother != null) _buildTryAnotherButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackdrop() {
    final backdropUrl = ApiConstants.getBackdropUrl(
      movie.backdropPath,
      size: ApiConstants.backdropSizeOriginal,
    );

    if (backdropUrl.isEmpty) {
      return Container(color: AppColors.surface);
    }

    return CachedNetworkImage(
      imageUrl: backdropUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: AppColors.surface,
        highlightColor: AppColors.surfaceLight,
        child: Container(color: AppColors.surface),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.surface,
        child: const Icon(Icons.movie, size: 50, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildRatingBadge() {
    return Align(
      alignment: Alignment.topRight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  movie.formattedRating,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPoster() {
    final posterUrl = ApiConstants.getPosterUrl(
      movie.posterPath,
      size: ApiConstants.posterSizeMedium,
    );

    return Container(
      width: 120,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.large,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: posterUrl.isEmpty
            ? Container(
                color: AppColors.surface,
                child: const Icon(
                  Icons.movie,
                  size: 40,
                  color: AppColors.textMuted,
                ),
              )
            : CachedNetworkImage(
                imageUrl: posterUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: AppColors.surface,
                  highlightColor: AppColors.surfaceLight,
                  child: Container(color: AppColors.surface),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surface,
                  child: const Icon(
                    Icons.broken_image,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      movie.title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildYear() {
    return Text(
      movie.releaseYear,
      style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
    );
  }

  Widget _buildStarRating() {
    return Row(
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final rating = movie.starRating;

        IconData icon;
        Color color;

        if (starValue <= rating) {
          icon = Icons.star_rounded;
          color = AppColors.secondary;
        } else if (starValue - 0.5 <= rating) {
          icon = Icons.star_half_rounded;
          color = AppColors.secondary;
        } else {
          icon = Icons.star_outline_rounded;
          color = Colors.white.withOpacity(0.3);
        }

        return Icon(icon, color: color, size: 20);
      }),
    );
  }

  Widget _buildGenreTags() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: genreNames.take(3).map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Text(
            genre,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOverview() {
    return Text(
      movie.overview.isEmpty ? 'Sinopse não disponível.' : movie.overview,
      style: TextStyle(
        fontSize: 14,
        color: Colors.white.withOpacity(0.85),
        height: 1.5,
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTryAnotherButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTryAnother,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Tentar Outro'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary.withOpacity(0.9),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildWatchedTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.5), width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 14, color: Colors.green),
          SizedBox(width: 4),
          Text(
            'Assistido',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
