import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/models/genre.dart';
import '../../core/services/movie_service.dart';
import '../../core/services/user_service.dart';

class WelcomeController extends GetxController {
  final UserService _userService = UserService();
  final MovieService _movieService = MovieService();

  final pageController = PageController();
  final RxInt currentPage = 0.obs;

  // Form Data
  final Rx<String?> selectedGender = Rx<String?>(null);
  final Rx<DateTime?> selectedBirthDate = Rx<DateTime?>(null);

  // Genres
  final RxList<Genre> genres = <Genre>[].obs;
  final RxList<int> selectedGenreIds = <int>[].obs;
  final RxBool isLoadingGenres = false.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchGenres();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void nextPage() {
    if (currentPage.value < 3) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      completeWelcome();
    }
  }

  void updatePage(int index) {
    currentPage.value = index;
  }

  // --- Gender & Bio ---
  void setGender(String? gender) {
    selectedGender.value = gender;
  }

  void setBirthDate(DateTime date) {
    selectedBirthDate.value = date;
  }

  // --- Genres ---
  Future<void> _fetchGenres() async {
    try {
      isLoadingGenres.value = true;
      final result = await _movieService.getGenres();
      genres.assignAll(result);
    } catch (e) {
      // Handle error cleanly
    } finally {
      isLoadingGenres.value = false;
    }
  }

  void toggleGenre(int genreId) {
    if (selectedGenreIds.contains(genreId)) {
      selectedGenreIds.remove(genreId);
    } else {
      // Limit selection if needed, or allow unlimited
      selectedGenreIds.add(genreId);
    }
  }

  // --- Completion ---
  Future<void> completeWelcome() async {
    // Save data sequentially to avoid errors blocking navigation
    try {
      await _userService.saveUserProfile(
        gender: selectedGender.value,
        birthDate: selectedBirthDate.value,
        favoriteGenreIds: selectedGenreIds.toList(),
      );
    } catch (e) {
      debugPrint('Error saving welcome info: $e');
    }

    try {
      await _userService.completeWelcome();
    } catch (e) {
      debugPrint('Error marking welcome complete: $e');
    }

    Get.offAllNamed('/home');
  }

  void skip() {
    completeWelcome();
  }

  bool get canProceedFromBio => true; // Optional fields, so always true
  bool get canProceedFromGenres => true; // Optional fields
}
