import 'package:get/get.dart';
import '../models/genre.dart';
import '../models/movie.dart';
import '../models/watch_provider.dart';
import '../services/movie_service.dart';
import '../services/user_service.dart';

/// Controller principal para gerenciamento de filmes
class MovieController extends GetxController {
  final MovieService _movieService = MovieService();
  final UserService _userService = UserService();

  // Estados observáveis
  final RxList<Genre> genres = <Genre>[].obs;
  final RxList<Genre> selectedGenres = <Genre>[].obs;
  final Rx<Movie?> recommendedMovie = Rx<Movie?>(null);
  final RxBool isLoadingGenres = false.obs;
  final RxBool isSearching = false.obs;
  final RxString errorMessage = ''.obs;
  final RxDouble minRating = 6.0.obs;
  final Rx<WatchProviders?> watchProviders = Rx<WatchProviders?>(null);
  final RxBool isLoadingProviders = false.obs;
  final RxList<Movie> movieHistory = <Movie>[].obs;
  // Resultados da busca
  final RxList<Movie> searchResults = <Movie>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchGenres();
    loadHistory();
  }

  /// Carrega histórico do Firestore
  Future<void> loadHistory() async {
    try {
      final history = await _userService.loadHistory();
      movieHistory.assignAll(history);
    } catch (e) {
      // Ignora erro se não conseguir carregar
    }
  }

  /// Limpa histórico local (ao deslogar)
  void clearHistory() {
    movieHistory.clear();
    watchProviders.value = null;
    recommendedMovie.value = null;
    selectedGenres.clear();
  }

  /// Busca lista de gêneros
  Future<void> fetchGenres() async {
    try {
      isLoadingGenres.value = true;
      errorMessage.value = '';
      final result = await _movieService.getGenres();
      genres.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoadingGenres.value = false;
    }
  }

  /// Alterna seleção de um gênero
  void toggleGenre(Genre genre) {
    if (selectedGenres.contains(genre)) {
      selectedGenres.remove(genre);
    } else {
      selectedGenres.add(genre);
    }
  }

  /// Verifica se um gênero está selecionado
  bool isGenreSelected(Genre genre) {
    return selectedGenres.contains(genre);
  }

  /// Limpa todos os gêneros selecionados
  void clearSelection() {
    selectedGenres.clear();
  }

  /// Define a nota mínima
  void setMinRating(double rating) {
    minRating.value = rating;
  }

  /// Busca um filme aleatório baseado nos filtros
  Future<void> findRandomMovie() async {
    if (selectedGenres.isEmpty) {
      errorMessage.value = 'Selecione pelo menos um gênero';
      return;
    }

    try {
      isSearching.value = true;
      errorMessage.value = '';
      watchProviders.value = null;

      final genreIds = selectedGenres.map((g) => g.id).toList();

      final movie = await _movieService.getRandomMovie(
        genreIds: genreIds,
        minRating: minRating.value,
      );

      if (movie != null) {
        recommendedMovie.value = movie;
        // Adiciona ao histórico
        _addToHistory(movie);
        // Busca provedores de streaming
        _fetchWatchProviders(movie.id);
      } else {
        errorMessage.value = 'Nenhum filme encontrado com esses critérios';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isSearching.value = false;
    }
  }

  /// Busca filmes pelo nome
  Future<void> searchMovie(String query) async {
    try {
      isSearching.value = true;
      errorMessage.value = '';
      watchProviders.value = null;
      searchResults.clear();

      final movies = await _movieService.searchMovies(query);

      if (movies.isNotEmpty) {
        searchResults.assignAll(movies);
      } else {
        errorMessage.value = 'Nenhum filme encontrado';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isSearching.value = false;
    }
  }

  /// Busca provedores de streaming para um filme
  Future<void> _fetchWatchProviders(int movieId) async {
    try {
      isLoadingProviders.value = true;
      final providers = await _movieService.getWatchProviders(movieId);
      watchProviders.value = providers;
    } catch (e) {
      // Ignora erros de providers
    } finally {
      isLoadingProviders.value = false;
    }
  }

  /// Adiciona filme ao histórico (evita duplicatas)
  void _addToHistory(Movie movie) {
    // Remove se já existe (para mover para o final)
    movieHistory.removeWhere((m) => m.id == movie.id);
    // Adiciona ao final
    movieHistory.add(movie);
    // Limita a 50 filmes
    if (movieHistory.length > 50) {
      movieHistory.removeAt(0);
    }
    // Salva no Firestore
    _userService.addToHistory(movie);
  }

  /// Limpa resultados da busca
  void clearSearch() {
    searchResults.clear();
    errorMessage.value = '';
    isSearching.value = false;
  }

  /// Limpa o filme recomendado
  void clearRecommendation() {
    recommendedMovie.value = null;
  }

  /// Reseta todos os filtros
  void resetAll() {
    selectedGenres.clear();
    recommendedMovie.value = null;
    minRating.value = 6.0;
    errorMessage.value = '';
  }

  /// Retorna nomes dos gêneros selecionados
  String get selectedGenresText {
    if (selectedGenres.isEmpty) return 'Nenhum selecionado';
    return selectedGenres.map((g) => g.name).join(', ');
  }

  /// Verifica se pode buscar
  bool get canSearch => selectedGenres.isNotEmpty;
}
