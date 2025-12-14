/// Constantes da API TMDB
class ApiConstants {
  ApiConstants._();

  /// Base URL da API TMDB
  static const String baseUrl = 'https://api.themoviedb.org/3';

  /// Base URL para imagens
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  /// API Key - Substitua pela sua chave obtida em https://www.themoviedb.org/settings/api
  static const String apiKey = '065fcbe5de8fc43cb5b49da232d1fa31';

  /// Idioma padrão
  static const String language = 'pt-BR';

  /// Endpoints
  static const String genresEndpoint = '/genre/movie/list';
  static const String discoverEndpoint = '/discover/movie';
  static const String movieDetailsEndpoint = '/movie';
  static const String watchProvidersEndpoint = '/movie/{id}/watch/providers';

  /// Tamanhos de poster
  static const String posterSizeSmall = '/w185';
  static const String posterSizeMedium = '/w342';
  static const String posterSizeLarge = '/w500';
  static const String posterSizeOriginal = '/original';

  /// Tamanhos de backdrop
  static const String backdropSizeMedium = '/w780';
  static const String backdropSizeOriginal = '/original';

  /// Monta URL completa do poster
  static String getPosterUrl(
    String? posterPath, {
    String size = posterSizeMedium,
  }) {
    if (posterPath == null || posterPath.isEmpty) {
      return '';
    }
    return '$imageBaseUrl$size$posterPath';
  }

  /// Monta URL completa do backdrop
  static String getBackdropUrl(
    String? backdropPath, {
    String size = backdropSizeMedium,
  }) {
    if (backdropPath == null || backdropPath.isEmpty) {
      return '';
    }
    return '$imageBaseUrl$size$backdropPath';
  }
}
