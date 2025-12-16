import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/movie.dart';

/// Serviço para gerenciar dados do usuário no Firestore
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Referência ao documento do usuário atual
  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return _firestore.collection('users').doc(userId);
  }

  // ============ PERFIL DO USUÁRIO ============

  /// Salva ou atualiza os dados do perfil do usuário
  Future<void> saveUserProfile({
    String? displayName,
    String? photoUrl,
    String? gender,
    DateTime? birthDate,
    List<String>? favoriteGenres,
    List<int>? favoriteGenreIds,
  }) async {
    final doc = _userDoc;
    if (doc == null) {
      throw Exception('Usuário não autenticado');
    }

    final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};

    if (displayName != null) data['displayName'] = displayName;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (gender != null) data['gender'] = gender;
    if (birthDate != null) data['birthDate'] = Timestamp.fromDate(birthDate);
    if (favoriteGenres != null) data['favoriteGenres'] = favoriteGenres;
    if (favoriteGenreIds != null) data['favoriteGenreIds'] = favoriteGenreIds;

    await doc.set(data, SetOptions(merge: true));
  }

  /// Marca o tutorial de boas-vindas como completo
  Future<void> completeWelcome() async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.set({
      'welcomeCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Verifica se o tutorial de boas-vindas foi completado
  Future<bool> isWelcomeCompleted() async {
    final profile = await loadUserProfile();
    if (profile == null) return false;
    return profile['welcomeCompleted'] ?? false;
  }

  /// Carrega os dados do perfil do usuário
  Future<Map<String, dynamic>?> loadUserProfile() async {
    final doc = _userDoc;
    if (doc == null) return null;

    final snapshot = await doc.get();
    return snapshot.data();
  }

  /// Obtém os gêneros favoritos do usuário
  Future<List<String>> getFavoriteGenres() async {
    final profile = await loadUserProfile();
    if (profile == null) return [];
    return List<String>.from(profile['favoriteGenres'] ?? []);
  }

  /// Obtém os IDs dos gêneros favoritos do usuário
  Future<List<int>> getFavoriteGenreIds() async {
    final profile = await loadUserProfile();
    if (profile == null) return [];
    return List<int>.from(profile['favoriteGenreIds'] ?? []);
  }

  // ============ HISTÓRICO DE FILMES ============

  /// Adiciona um filme ao histórico do usuário
  Future<void> addToHistory(Movie movie) async {
    final doc = _userDoc;
    if (doc == null) return;

    final historyRef = doc.collection('history').doc(movie.id.toString());

    await historyRef.set({
      'movieId': movie.id,
      'title': movie.title,
      'posterPath': movie.posterPath,
      'backdropPath': movie.backdropPath,
      'overview': movie.overview,
      'voteAverage': movie.voteAverage,
      'voteCount': movie.voteCount,
      'releaseDate': movie.releaseDate,
      'genreIds': movie.genreIds,
      'popularity': movie.popularity,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Carrega o histórico de filmes do usuário
  Future<List<Movie>> loadHistory({int limit = 50}) async {
    final doc = _userDoc;
    if (doc == null) return [];

    final snapshot = await doc
        .collection('history')
        .orderBy('addedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Movie(
        id: data['movieId'] as int,
        title: data['title'] as String,
        posterPath: data['posterPath'] as String?,
        backdropPath: data['backdropPath'] as String?,
        overview: data['overview'] as String,
        voteAverage: (data['voteAverage'] as num).toDouble(),
        voteCount: data['voteCount'] as int,
        releaseDate: data['releaseDate'] as String? ?? '',
        genreIds: List<int>.from(data['genreIds'] ?? []),
        popularity: (data['popularity'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  /// Remove um filme do histórico
  Future<void> removeFromHistory(int movieId) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.collection('history').doc(movieId.toString()).delete();
  }

  /// Limpa todo o histórico
  Future<void> clearHistory() async {
    final doc = _userDoc;
    if (doc == null) return;

    final snapshot = await doc.collection('history').get();
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // ============ FILMES ASSISTIDOS ============

  /// Marca um filme como assistido
  Future<void> markAsWatched(int movieId) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.collection('watched').doc(movieId.toString()).set({
      'movieId': movieId,
      'watchedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove a marca de assistido de um filme
  Future<void> unmarkAsWatched(int movieId) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.collection('watched').doc(movieId.toString()).delete();
  }

  /// Verifica se um filme foi assistido
  Future<bool> isWatched(int movieId) async {
    final doc = _userDoc;
    if (doc == null) return false;

    final snapshot = await doc
        .collection('watched')
        .doc(movieId.toString())
        .get();
    return snapshot.exists;
  }

  /// Carrega lista de IDs de filmes assistidos
  Future<Set<int>> loadWatchedMovieIds() async {
    final doc = _userDoc;
    if (doc == null) return {};

    final snapshot = await doc.collection('watched').get();
    return snapshot.docs.map((doc) => int.parse(doc.id)).toSet();
  }

  // ============ PREFERÊNCIAS ============

  /// Salva os provedores de streaming preferidos
  Future<void> savePreferredProviders(List<int> providerIds) async {
    final doc = _userDoc;
    if (doc == null) return;

    await doc.set({
      'preferredProviders': providerIds,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Carrega os provedores de streaming preferidos
  Future<List<int>> loadPreferredProviders() async {
    final profile = await loadUserProfile();
    if (profile == null) return [];
    return List<int>.from(profile['preferredProviders'] ?? []);
  }

  // ============ INICIALIZAÇÃO ============

  /// Cria o documento do usuário se não existir
  Future<void> initializeUser() async {
    final doc = _userDoc;
    if (doc == null) return;

    final snapshot = await doc.get();
    if (!snapshot.exists) {
      final user = _auth.currentUser;
      await doc.set({
        'email': user?.email,
        'displayName': user?.displayName,
        'photoUrl': user?.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Upload da foto de perfil para o Firebase Storage
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${user.uid}.jpg');

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      throw 'Falha ao fazer upload da imagem: $e';
    }
  }

  /// Exclui todos os dados do usuário (Firestore e Storage)
  Future<void> deleteUserData() async {
    final user = _auth.currentUser;
    final doc = _userDoc;
    if (user == null || doc == null) return;

    // 1. Excluir subcoleções (Firestore não deleta recursivamente)
    await clearHistory();

    // Excluir watched
    final watchedSnapshot = await doc.collection('watched').get();
    final batch = _firestore.batch();
    for (final doc in watchedSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    // 2. Excluir foto de perfil no Storage
    try {
      if (user.photoURL != null && user.photoURL!.contains('profile_photos')) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_photos')
            .child('${user.uid}.jpg');
        await ref.delete();
      }
    } catch (e) {
      // Ignora erro se imagem não existir
    }

    // 3. Excluir documento do usuário
    await doc.delete();
  }
}
