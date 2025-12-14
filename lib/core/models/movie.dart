import 'genre.dart';

/// Modelo de Filme
class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String releaseDate;
  final List<int> genreIds;
  final List<Genre>? genres;
  final double popularity;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    required this.releaseDate,
    required this.genreIds,
    this.genres,
    required this.popularity,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      releaseDate: json['release_date'] ?? '',
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      genres: json['genres'] != null
          ? List<Genre>.from(
              (json['genres'] as List).map((g) => Genre.fromJson(g)))
          : null,
      popularity: (json['popularity'] ?? 0).toDouble(),
    );
  }

  /// Retorna o ano de lançamento
  String get releaseYear {
    if (releaseDate.isEmpty || releaseDate.length < 4) return '';
    return releaseDate.substring(0, 4);
  }

  /// Retorna a nota formatada (0.0 - 10.0)
  String get formattedRating => voteAverage.toStringAsFixed(1);

  /// Retorna a nota em estrelas (0 - 5)
  double get starRating => voteAverage / 2;

  @override
  String toString() => 'Movie(id: $id, title: $title)';
}
