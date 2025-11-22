import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_model.dart';
import '../models/user_model.dart';
import '../core/theme/app_colors.dart';
import 'auth_provider.dart';

/// ========================================
/// HOME PROVIDER - SiBunda
/// Riverpod state management for home screen
/// ========================================

// Home Controller State Notifier
class HomeController extends StateNotifier<HomeState> {
  final Ref ref;

  HomeController(this.ref) : super(const HomeState());

  /// Initialize home data
  Future<void> initializeHome() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Load all data in parallel
      await Future.wait([
        loadProfile(),
        loadStatusList(),
        loadMenuList(),
        loadTipsList(),
      ]);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load user profile
  Future<void> loadProfile() async {
    try {
      final userAsync = ref.read(currentUserProvider);

      userAsync.whenData((user) {
        if (user != null) {
          state = state.copyWith(
            profile: HomeProfile(
              name: user.displayName ?? 'Bunda',
              photoUrl: user.photoURL,
              email: user.email,
              age: user.birthDate != null
                  ? _calculateAge(user.birthDate!)
                  : null,
            ),
          );
        }
      });
    } catch (e) {
      // Profile error is not critical, just log it
      debugPrint('Error loading profile: $e');
    }
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Load status list (health status cards)
  Future<void> loadStatusList() async {
    try {
      // TODO: Replace with actual API call
      // For now, use dummy data matching repo lama
      await Future.delayed(const Duration(milliseconds: 300));

      state = state.copyWith(
        statusList: [
          const HomeStatus(
            id: '1',
            desc: 'Kesehatan Bunda baik',
            icon: Icons.favorite,
            color: AppColors.greenSafe,
          ),
          const HomeStatus(
            id: '2',
            desc: 'Jadwal imunisasi minggu ini',
            icon: Icons.calendar_today,
            color: AppColors.yellow,
          ),
          const HomeStatus(
            id: '3',
            desc: 'Pertumbuhan bayi normal',
            icon: Icons.child_care,
            color: AppColors.greenSafe,
          ),
        ],
      );
    } catch (e) {
      debugPrint('Error loading status list: $e');
    }
  }

  /// Load menu list
  Future<void> loadMenuList() async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 300));

      state = state.copyWith(
        menuList: [
          const HomeMenu(
            id: '1',
            name: 'Kehamilan Ku',
            moduleName: 'pregnancy',
            icon: Icons.pregnant_woman,
          ),
          const HomeMenu(
            id: '2',
            name: 'Bayi Ku',
            moduleName: 'baby',
            icon: Icons.child_care,
          ),
        ],
      );
    } catch (e) {
      debugPrint('Error loading menu list: $e');
    }
  }

  /// Load tips list
  Future<void> loadTipsList() async {
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 300));

      state = state.copyWith(
        tipsList: [
          const HomeTips(
            id: '1',
            title: 'Tips Menjaga Kesehatan Ibu Hamil',
            kind: 'Kehamilan',
          ),
          const HomeTips(
            id: '2',
            title: 'Nutrisi Penting untuk Tumbuh Kembang Bayi',
            kind: 'Nutrisi',
          ),
          const HomeTips(
            id: '3',
            title: 'Cara Menyusui yang Benar',
            kind: 'ASI',
          ),
        ],
      );
    } catch (e) {
      debugPrint('Error loading tips list: $e');
    }
  }

  /// Refresh all home data
  Future<void> refresh() async {
    await initializeHome();
  }
}

// Home Controller Provider
final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController(ref);
});

// Individual state selectors for optimization
final homeProfileProvider = Provider<HomeProfile?>((ref) {
  return ref.watch(homeControllerProvider).profile;
});

final homeStatusListProvider = Provider<List<HomeStatus>>((ref) {
  return ref.watch(homeControllerProvider).statusList;
});

final homeMenuListProvider = Provider<List<HomeMenu>>((ref) {
  return ref.watch(homeControllerProvider).menuList;
});

final homeTipsListProvider = Provider<List<HomeTips>>((ref) {
  return ref.watch(homeControllerProvider).tipsList;
});

final homeLoadingProvider = Provider<bool>((ref) {
  return ref.watch(homeControllerProvider).isLoading;
});
