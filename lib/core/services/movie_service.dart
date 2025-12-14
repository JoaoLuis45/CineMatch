import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/genre.dart';
import '../models/movie.dart';
import '../models/watch_provider.dart';

/// Serviço para comunicação com a TMDB API
class MovieService {
  late final Dio _dio;

  MovieService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        queryParameters: {
          'api_key': ApiConstants.apiKey,
          'language': ApiConstants.language,
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }

  /// Busca lista de gêneros disponíveis
  Future<List<Genre>> getGenres() async {
    try {
      final response = await _dio.get(ApiConstants.genresEndpoint);
      final List<dynamic> genresJson = response.data['genres'] ?? [];
      return genresJson.map((json) => Genre.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Descobre filmes com base nos filtros selecionados
  Future<List<Movie>> discoverMovies({
    List<int>? genreIds,
    double? minRating,
    int? year,
    String sortBy = 'popularity.desc',
    int page = 1,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'sort_by': sortBy,
        'page': page,
        'include_adult': false,
        'include_video': false,
      };

      if (genreIds != null && genreIds.isNotEmpty) {
        queryParams['with_genres'] = genreIds.join(',');
      }

      if (minRating != null) {
        queryParams['vote_average.gte'] = minRating;
      }

      if (year != null) {
        queryParams['primary_release_year'] = year;
      }

      final response = await _dio.get(
        ApiConstants.discoverEndpoint,
        queryParameters: queryParams,
      );

      final List<dynamic> moviesJson = response.data['results'] ?? [];
      return moviesJson.map((json) => Movie.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Busca detalhes de um filme específico
  Future<Movie> getMovieDetails(int movieId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.movieDetailsEndpoint}/$movieId',
      );
      return Movie.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Busca um filme aleatório baseado nos filtros
  Future<Movie?> getRandomMovie({
    List<int>? genreIds,
    double? minRating,
  }) async {
    try {
      // Busca filmes populares com os filtros
      final queryParams = <String, dynamic>{
        'sort_by': 'popularity.desc',
        'include_adult': false,
        'include_video': false,
        'vote_count.gte':
            100, // Mínimo de 100 votos para evitar filmes obscuros
      };

      if (genreIds != null && genreIds.isNotEmpty) {
        queryParams['with_genres'] = genreIds.join(',');
      }

      if (minRating != null && minRating > 0) {
        queryParams['vote_average.gte'] = minRating;
        queryParams['vote_average.lte'] = 9.5; // Máximo para evitar filmes fake
      }

      // Pega informações da primeira página para saber total
      final response = await _dio.get(
        ApiConstants.discoverEndpoint,
        queryParameters: {...queryParams, 'page': 1},
      );

      final totalPages = (response.data['total_pages'] as int?) ?? 1;
      final totalResults = (response.data['total_results'] as int?) ?? 0;

      if (totalResults == 0) return null;

      // Limita a 20 páginas para manter filmes mais populares
      final maxPage = totalPages > 20 ? 20 : totalPages;

      // Escolhe uma página aleatória
      final random = DateTime.now().millisecondsSinceEpoch;
      final randomPage = (random % maxPage) + 1;

      // Busca filmes da página aleatória
      final moviesResponse = await _dio.get(
        ApiConstants.discoverEndpoint,
        queryParameters: {...queryParams, 'page': randomPage},
      );

      final List<dynamic> moviesJson = moviesResponse.data['results'] ?? [];
      final movies = moviesJson.map((json) => Movie.fromJson(json)).toList();

      if (movies.isEmpty) return null;

      // Filtra apenas filmes com poster e sinopse
      final validMovies = movies
          .where(
            (m) =>
                m.posterPath != null &&
                m.posterPath!.isNotEmpty &&
                m.overview.isNotEmpty,
          )
          .toList();

      if (validMovies.isEmpty) {
        // Se não houver filmes válidos, tenta a primeira página
        final firstPageMovies = moviesJson
            .map((json) => Movie.fromJson(json))
            .toList();
        final firstValidMovies = firstPageMovies
            .where((m) => m.posterPath != null && m.posterPath!.isNotEmpty)
            .toList();

        if (firstValidMovies.isEmpty) return movies.first;
        return firstValidMovies[random % firstValidMovies.length];
      }

      // Escolhe um filme aleatório da lista válida
      final randomIndex = random % validMovies.length;
      return validMovies[randomIndex];
    } catch (e) {
      return null;
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await _dio.get(
        '/search/movie',
        queryParameters: {'query': query, 'include_adult': false},
      );

      final List<dynamic> moviesJson = response.data['results'] ?? [];

      if (moviesJson.isEmpty) return [];

      // Retorna todos os resultados mapeados
      return moviesJson.map((json) => Movie.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Busca provedores de streaming para um filme específico
  /// Retorna os provedores disponíveis no Brasil (BR)
  Future<WatchProviders?> getWatchProviders(int movieId) async {
    try {
      final response = await _dio.get('/movie/$movieId/watch/providers');

      final results = response.data['results'] as Map<String, dynamic>?;

      if (results == null) return null;

      // Busca provedores do Brasil
      final brProviders = results['BR'] as Map<String, dynamic>?;

      if (brProviders == null) return null;

      return WatchProviders.fromJson(brProviders);
    } catch (e) {
      return null;
    }
  }

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tempo de conexão esgotado. Verifique sua internet.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return 'API Key inválida. Verifique sua configuração.';
        } else if (statusCode == 404) {
          return 'Recurso não encontrado.';
        }
        return 'Erro no servidor: $statusCode';
      case DioExceptionType.cancel:
        return 'Requisição cancelada.';
      default:
        return 'Erro de conexão. Verifique sua internet.';
    }
  }
}
