import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/api_constants.dart';
import '../../core/controllers/auth_controller.dart';
import '../../core/controllers/movie_controller.dart';
import '../../core/models/movie.dart';
import '../../core/services/movie_service.dart';
import '../../core/theme/app_theme.dart';

/// Aba de filmes em alta (Top Filmes)
class TrendingTab extends StatefulWidget {
  const TrendingTab({super.key});

  @override
  State<TrendingTab> createState() => _TrendingTabState();
}

class _TrendingTabState extends State<TrendingTab> {
  final MovieService _movieService = MovieService();
  final MovieController _movieController = Get.find<MovieController>();

  final Map<int, List<Movie>> _moviesByGenre = {};
  final Set<int> _loadingGenres = {};

  // Gêneros populares para exibir
  final List<Map<String, dynamic>> _popularGenres = [
    {'id': 28, 'name': 'Ação', 'icon': Icons.sports_mma},
    {'id': 35, 'name': 'Comédia', 'icon': Icons.sentiment_very_satisfied},
    {'id': 27, 'name': 'Terror', 'icon': Icons.mood_bad},
    {'id': 878, 'name': 'Ficção Científica', 'icon': Icons.rocket_launch},
    {'id': 10749, 'name': 'Romance', 'icon': Icons.favorite},
    {'id': 18, 'name': 'Drama', 'icon': Icons.theater_comedy},
    {'id': 16, 'name': 'Animação', 'icon': Icons.animation},
    {'id': 53, 'name': 'Suspense', 'icon': Icons.psychology},
  ];

  @override
  void initState() {
    super.initState();
    _loadAllGenres();
  }

  Future<void> _loadAllGenres() async {
    for (final genre in _popularGenres) {
      await _loadMoviesForGenre(genre['id'] as int);
    }
  }

  Future<void> _loadMoviesForGenre(int genreId) async {
    if (_loadingGenres.contains(genreId)) return;

    setState(() => _loadingGenres.add(genreId));

    try {
      final movies = await _movieService.discoverMovies(
        genreIds: [genreId],
        minRating: 7.0,
        sortBy: 'vote_average.desc',
      );

      // Filtra apenas filmes com poster e nota alta
      final filteredMovies = movies
          .where((m) => m.posterPath != null && m.posterPath!.isNotEmpty)
          .take(10)
          .toList();

      setState(() {
        _moviesByGenre[genreId] = filteredMovies;
        _loadingGenres.remove(genreId);
      });
    } catch (e) {
      setState(() => _loadingGenres.remove(genreId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          _buildAppBar(),

          // Conteúdo
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Seções por gênero
                ..._popularGenres.map(
                  (genre) => _buildGenreSection(
                    genreId: genre['id'] as int,
                    genreName: genre['name'] as String,
                    genreIcon: genre['icon'] as IconData,
                  ),
                ),

                const SizedBox(height: 100),
              ],
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
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() {
                  final userName = Get.find<AuthController>().userName;
                  final firstName = userName.split(' ').first;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Olá, $firstName',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Vamos assistir algo hoje?',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  );
                }),
              ),
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

  Widget _buildGenreSection({
    required int genreId,
    required String genreName,
    required IconData genreIcon,
  }) {
    final movies = _moviesByGenre[genreId] ?? [];
    final isLoading = _loadingGenres.contains(genreId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do gênero
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(genreIcon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  genreName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (movies.isNotEmpty)
                  Text(
                    '${movies.length} filmes',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Lista horizontal de filmes
          SizedBox(
            height: 200,
            child: isLoading || movies.isEmpty
                ? _buildLoadingRow()
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      return _buildMovieCard(movies[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingRow() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppColors.surface,
          highlightColor: AppColors.surfaceLight,
          child: Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        // Definir o filme recomendado e ir para a tela de resultado
        _movieController.recommendedMovie.value = movie;
        Get.toNamed('/result');
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl:
                          '${ApiConstants.imageBaseUrl}${ApiConstants.posterSizeSmall}${movie.posterPath}',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(
                        color: AppColors.surface,
                        child: const Center(
                          child: Icon(
                            Icons.movie_rounded,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surface,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Badge de nota
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.secondary,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Título
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
