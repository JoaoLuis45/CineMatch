import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/controllers/movie_controller.dart';
import '../../core/services/user_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/movie_card.dart';
import '../../shared/widgets/streaming_providers_widget.dart';

/// Tela de resultado do filme encontrado
class MovieResultScreen extends StatefulWidget {
  const MovieResultScreen({super.key});

  @override
  State<MovieResultScreen> createState() => _MovieResultScreenState();
}

class _MovieResultScreenState extends State<MovieResultScreen> {
  final MovieController _controller = Get.find<MovieController>();
  final UserService _userService = UserService();

  bool _isWatched = false;
  bool _isLoadingWatched = true;

  @override
  void initState() {
    super.initState();
    _checkIfWatched();
  }

  Future<void> _checkIfWatched() async {
    final movie = _controller.recommendedMovie.value;
    if (movie != null) {
      final watched = await _userService.isWatched(movie.id);
      if (mounted) {
        setState(() {
          _isWatched = watched;
          _isLoadingWatched = false;
        });
      }
    } else {
      setState(() => _isLoadingWatched = false);
    }
  }

  Future<void> _toggleWatched() async {
    final movie = _controller.recommendedMovie.value;
    if (movie == null) return;

    setState(() => _isLoadingWatched = true);

    try {
      if (_isWatched) {
        await _userService.unmarkAsWatched(movie.id);
      } else {
        await _userService.markAsWatched(movie.id);
      }

      setState(() {
        _isWatched = !_isWatched;
        _isLoadingWatched = false;
      });

      Get.snackbar(
        _isWatched ? 'Marcado como assistido' : 'Removido dos assistidos',
        _isWatched ? 'Filme adicionado à sua lista' : 'Filme removido da lista',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _isWatched ? Colors.green : AppColors.surface,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      setState(() => _isLoadingWatched = false);
      Get.snackbar(
        'Erro',
        'Não foi possível atualizar',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _shareMovie() async {
    final movie = _controller.recommendedMovie.value;
    if (movie == null) return;

    final year = movie.releaseYear.isNotEmpty ? ' (${movie.releaseYear})' : '';
    final rating = movie.voteAverage.toStringAsFixed(1);

    final shareText =
        '''
🎬 *${movie.title}*$year

⭐ Nota: $rating/10

📝 ${movie.overview.length > 200 ? '${movie.overview.substring(0, 200)}...' : movie.overview}

🔗 https://www.themoviedb.org/movie/${movie.id}

Encontrado com o CineMatch! 🍿
''';

    await Share.share(
      shareText.trim(),
      subject: 'Confira esse filme: ${movie.title}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Botão compartilhar
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.share_rounded, size: 20),
            ),
            onPressed: _shareMovie,
          ),
          // Botão home
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.home_rounded, size: 20),
            ),
            onPressed: () {
              _controller.resetAll();
              Get.offAllNamed('/home');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final movie = _controller.recommendedMovie.value;

        if (movie == null) {
          return _buildNoMovieState(context);
        }

        return _buildMovieResult(context);
      }),
    );
  }

  Widget _buildNoMovieState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_filter_outlined,
            size: 80,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum filme encontrado',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar seus filtros',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieResult(BuildContext context) {
    final movie = _controller.recommendedMovie.value!;

    return Stack(
      children: [
        // Background dinâmico
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.background,
                ],
              ),
            ),
          ),
        ),

        // Conteúdo principal
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Título da seção
                _buildSectionTitle(context),
                const SizedBox(height: 16),

                // Card do filme com tag de assistido
                MovieCard(
                  movie: movie,
                  genreNames: _getGenreNames(movie.genreIds),
                  isWatched: _isWatched,
                  onTryAnother: () async {
                    await _controller.findRandomMovie();
                    _checkIfWatched();
                  },
                ),

                const SizedBox(height: 16),

                // Provedores de streaming
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(
                    () => StreamingProvidersWidget(
                      providers: _controller.watchProviders.value,
                      isLoading: _controller.isLoadingProviders.value,
                      movieTitle: movie.title,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Botão de marcar como assistido
                _buildWatchedButton(),

                const SizedBox(height: 16),

                // Botões de ação
                _buildActionButtons(context),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWatchedButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _isLoadingWatched ? null : _toggleWatched,
          icon: _isLoadingWatched
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  _isWatched
                      ? Icons.check_circle_rounded
                      : Icons.visibility_rounded,
                  size: 22,
                ),
          label: Text(
            _isWatched ? 'Assistido ✓' : 'Marcar como Assistido',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isWatched ? Colors.green : AppColors.secondary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, color: AppColors.secondary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Encontramos para você!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _controller.clearRecommendation();
                Get.back();
                Get.back();
              },
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Novos Gêneros'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.surfaceLight),
                padding: const EdgeInsets.symmetric(vertical: 16),
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

  List<String> _getGenreNames(List<int> genreIds) {
    return genreIds
        .map((id) {
          final genre = _controller.genres.firstWhereOrNull((g) => g.id == id);
          return genre?.name ?? '';
        })
        .where((name) => name.isNotEmpty)
        .toList();
  }
}
