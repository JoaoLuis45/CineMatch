import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/api_constants.dart';
import '../../core/controllers/movie_controller.dart';
import '../../core/models/movie.dart';
import '../../core/theme/app_theme.dart';

/// Aba de histórico de filmes descobertos
class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final MovieController _controller = Get.find<MovieController>();

  // Filtros
  String? _selectedYear;
  int? _selectedGenreId;
  double? _minRating;
  bool _showFilters = false;

  List<Movie> get _filteredHistory {
    var movies = _controller.movieHistory.toList();

    // Filtrar por ano
    if (_selectedYear != null) {
      movies = movies.where((m) => m.releaseYear == _selectedYear).toList();
    }

    // Filtrar por gênero
    if (_selectedGenreId != null) {
      movies = movies
          .where((m) => m.genreIds.contains(_selectedGenreId))
          .toList();
    }

    // Filtrar por nota mínima
    if (_minRating != null) {
      movies = movies.where((m) => m.voteAverage >= _minRating!).toList();
    }

    // Ordenar por mais recente
    return movies.reversed.toList();
  }

  List<String> get _availableYears {
    final years = _controller.movieHistory
        .map((m) => m.releaseYear)
        .where((y) => y.isNotEmpty)
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  void _clearFilters() {
    setState(() {
      _selectedYear = null;
      _selectedGenreId = null;
      _minRating = null;
    });
  }

  bool get _hasActiveFilters =>
      _selectedYear != null || _selectedGenreId != null || _minRating != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (_showFilters) _buildFiltersSection(),
            Expanded(
              child: Obx(() {
                final history = _filteredHistory;

                if (_controller.movieHistory.isEmpty) {
                  return _buildEmptyState();
                }

                if (history.isEmpty && _hasActiveFilters) {
                  return _buildNoResultsState();
                }

                return _buildHistoryList(history);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Histórico',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Obx(
                  () => Text(
                    '${_controller.movieHistory.length} filmes descobertos',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          // Botão de filtro
          GestureDetector(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _showFilters || _hasActiveFilters
                    ? AppColors.primary.withOpacity(0.2)
                    : AppColors.surface,
                shape: BoxShape.circle,
                border: _hasActiveFilters
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: Icon(
                Icons.filter_list_rounded,
                color: _showFilters || _hasActiveFilters
                    ? AppColors.primary
                    : AppColors.textPrimary,
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
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_hasActiveFilters)
                GestureDetector(
                  onTap: _clearFilters,
                  child: const Text(
                    'Limpar',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Filtro por Ano
          _buildFilterDropdown(
            label: 'Ano',
            icon: Icons.calendar_today_rounded,
            value: _selectedYear,
            items: _availableYears,
            onChanged: (value) => setState(() => _selectedYear = value),
          ),
          const SizedBox(height: 12),

          // Filtro por Gênero
          Obx(() => _buildGenreFilter()),
          const SizedBox(height: 12),

          // Filtro por Nota
          _buildRatingFilter(),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            hint: Text(
              'Todos',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            underline: const SizedBox(),
            isDense: true,
            dropdownColor: AppColors.surface,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos')),
              ...items.map(
                (item) => DropdownMenuItem(value: item, child: Text(item)),
              ),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildGenreFilter() {
    final genres = _controller.genres;

    // Pegar apenas gêneros presentes no histórico
    final historyGenreIds = _controller.movieHistory
        .expand((m) => m.genreIds)
        .toSet();
    final availableGenres = genres
        .where((g) => historyGenreIds.contains(g.id))
        .toList();

    return Row(
      children: [
        Icon(Icons.category_rounded, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Text(
          'Gênero',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<int?>(
            value: _selectedGenreId,
            hint: Text(
              'Todos',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            underline: const SizedBox(),
            isDense: true,
            dropdownColor: AppColors.surface,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos')),
              ...availableGenres.map(
                (g) => DropdownMenuItem(value: g.id, child: Text(g.name)),
              ),
            ],
            onChanged: (value) => setState(() => _selectedGenreId = value),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Row(
      children: [
        Icon(Icons.star_rounded, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 10),
        Text(
          'Nota mínima',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<double?>(
            value: _minRating,
            hint: Text(
              'Todas',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            underline: const SizedBox(),
            isDense: true,
            dropdownColor: AppColors.surface,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            items: const [
              DropdownMenuItem(value: null, child: Text('Todas')),
              DropdownMenuItem(value: 5.0, child: Text('5.0+')),
              DropdownMenuItem(value: 6.0, child: Text('6.0+')),
              DropdownMenuItem(value: 7.0, child: Text('7.0+')),
              DropdownMenuItem(value: 8.0, child: Text('8.0+')),
            ],
            onChanged: (value) => setState(() => _minRating = value),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.movie_filter_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Nenhum filme descoberto ainda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Descubra filmes incríveis na aba Descobrir!',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text(
            'Nenhum filme encontrado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Limpar filtros'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<Movie> history) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final movie = history[index];
        return _buildHistoryCard(movie);
      },
    );
  }

  Widget _buildHistoryCard(Movie movie) {
    // Mapear IDs de gêneros para nomes
    final genreNames = movie.genreIds
        .map(
          (id) => _controller.genres.firstWhereOrNull((g) => g.id == id)?.name,
        )
        .where((name) => name != null)
        .cast<String>()
        .take(3)
        .toList();

    return GestureDetector(
      onTap: () {
        _controller.recommendedMovie.value = movie;
        Get.toNamed('/result');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceLight),
        ),
        child: Row(
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: movie.posterPath != null
                    ? '${ApiConstants.imageBaseUrl}${ApiConstants.posterSizeSmall}${movie.posterPath}'
                    : '',
                width: 70,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 70,
                  height: 100,
                  color: AppColors.backgroundLight,
                  child: const Icon(
                    Icons.movie_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 70,
                  height: 100,
                  color: AppColors.backgroundLight,
                  child: const Icon(
                    Icons.movie_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Informações
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Ano e Nota
                  Row(
                    children: [
                      if (movie.releaseDate.isNotEmpty) ...[
                        Text(
                          movie.releaseYear,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.secondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movie.voteAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  // Tags de gêneros
                  if (genreNames.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: genreNames.map((genre) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
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
                    ),
                  ],
                ],
              ),
            ),

            // Ícone de seta
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
