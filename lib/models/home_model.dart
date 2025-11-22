import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// ========================================
/// HOME MODELS - SiBunda
/// Matching repo lama home_data.dart
/// ========================================

/// Status card data for home dashboard
class HomeStatus {
  final String id;
  final String desc;
  final String? imageUrl;
  final IconData? icon;
  final Color color;

  const HomeStatus({
    required this.id,
    required this.desc,
    this.imageUrl,
    this.icon,
    this.color = AppColors.greenSafe,
  });
}

/// Menu item data for home dashboard
class HomeMenu {
  final String id;
  final String name;
  final String? imageUrl;
  final IconData? icon;
  final String moduleName;

  const HomeMenu({
    required this.id,
    required this.name,
    required this.moduleName,
    this.imageUrl,
    this.icon,
  });
}

/// Tips/Education data for home dashboard
class HomeTips {
  final String id;
  final String title;
  final String kind;
  final String? imageUrl;
  final String? contentUrl;

  const HomeTips({
    required this.id,
    required this.title,
    required this.kind,
    this.imageUrl,
    this.contentUrl,
  });
}

/// Profile data for display in home
class HomeProfile {
  final String name;
  final String? photoUrl;
  final int? age; // in years
  final String? email;

  const HomeProfile({
    required this.name,
    this.photoUrl,
    this.age,
    this.email,
  });
}

/// Combined home state
class HomeState {
  final HomeProfile? profile;
  final List<HomeStatus> statusList;
  final List<HomeMenu> menuList;
  final List<HomeTips> tipsList;
  final bool isLoading;
  final String? errorMessage;

  const HomeState({
    this.profile,
    this.statusList = const [],
    this.menuList = const [],
    this.tipsList = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeProfile? profile,
    List<HomeStatus>? statusList,
    List<HomeMenu>? menuList,
    List<HomeTips>? tipsList,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      profile: profile ?? this.profile,
      statusList: statusList ?? this.statusList,
      menuList: menuList ?? this.menuList,
      tipsList: tipsList ?? this.tipsList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
