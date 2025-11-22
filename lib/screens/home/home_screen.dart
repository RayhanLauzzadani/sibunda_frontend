import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/home_widgets.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/home_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../../routes/app_router.dart';

/// ========================================
/// HOME SCREEN - SiBunda
/// Matching repo lama home_page.dart (101%)
/// ========================================

// Constants matching repo lama secondary_frames.dart
const double _topBarHeight = 120.0;
const double _stdTopMargin = _topBarHeight + 10;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize home data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeControllerProvider.notifier).initializeHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeControllerProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.greyCalmer,
      body: Stack(
        children: [
          // Main content with scroll
          _buildMainContent(homeState),

          // Top bar overlay
          _buildTopBar(homeState, currentUserAsync),

          // Bottom navigation bar
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomNavBar(),
          ),
        ],
      ),
    );
  }

  /// Build top navigation bar matching repo lama
  Widget _buildTopBar(HomeState homeState, AsyncValue<UserModel?> userAsync) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      height: _topBarHeight + topPadding,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Stack(
          children: [
            // Profile widget (left)
            Align(
              alignment: Alignment.centerLeft,
              child: _buildProfileWidget(homeState, userAsync),
            ),

            // Notification button (right)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(top: 15, right: 15),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: InkWell(
                    onTap: _onNotificationTap,
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build profile widget for top bar
  Widget _buildProfileWidget(
      HomeState homeState, AsyncValue<UserModel?> userAsync) {
    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const SizedBox.shrink();
        }

        return InkWell(
          onTap: _onProfileTap,
          child: ItemProfile(
            name: user.displayName ?? 'Bunda',
            desc: user.birthDate != null
                ? '${_calculateAge(user.birthDate!)} tahun'
                : null,
            photoUrl: user.photoURL,
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.only(left: 30),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: AppColors.white,
            strokeWidth: 2,
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
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

  /// Build main scrollable content
  Widget _buildMainContent(HomeState homeState) {
    if (homeState.isLoading && homeState.statusList.isEmpty) {
      return const Center(child: LoadingWidget(message: 'Memuat data...'));
    }

    return CustomScrollView(
      slivers: [
        // Top margin for top bar
        SliverToBoxAdapter(
          child: SizedBox(height: _stdTopMargin),
        ),

        // Status list section
        SliverToBoxAdapter(
          child: _buildStatusSection(homeState.statusList),
        ),

        // Menu list section
        SliverToBoxAdapter(
          child: _buildMenuSection(homeState.menuList),
        ),

        // Tips header
        if (homeState.tipsList.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              alignment: Alignment.centerLeft,
              margin: const EdgeInsets.only(left: 20, bottom: 20, top: 40),
              child: Text(
                'Baca Tips dan Info untuk Bunda',
                style: AppTextStyles.size0Bold,
              ),
            ),
          ),

        // Tips list
        _buildTipsList(homeState.tipsList),

        // "Lihat Selengkapnya" button
        if (homeState.tipsList.isNotEmpty)
          SliverToBoxAdapter(
            child: Column(
              children: [
                InkWell(
                  onTap: _onSeeMoreTips,
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 15),
                    child: Text(
                      'Lihat Selengkapnya',
                      style: AppTextStyles.sizeMin1ColorPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
    );
  }

  /// Build status cards section (horizontal scroll)
  Widget _buildStatusSection(List<HomeStatus> statusList) {
    if (statusList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 20, bottom: 20, top: 30),
          child: Text(
            'Yuk Lihat Kesehatan Keluarga',
            style: AppTextStyles.size0Bold,
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: statusList.length,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemBuilder: (ctx, i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: ItemDashboardStatus.fromData(statusList[i]),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  /// Build menu section (row of menu items)
  Widget _buildMenuSection(List<HomeMenu> menuList) {
    if (menuList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 20, bottom: 20),
          child: Text(
            'Jelajahi Menu siBunda',
            style: AppTextStyles.size0Bold,
          ),
        ),
        SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: menuList.asMap().entries.map((entry) {
              final data = entry.value;
              return ItemDashboardMenu.fromData(
                data,
                onClick: () => _onMenuTap(data.moduleName),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Build tips list (sliver)
  Widget _buildTipsList(List<HomeTips> tipsList) {
    if (tipsList.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final tips = tipsList[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: ItemTips.fromData(
                tips,
                onTap: () => _onTipsTap(tips),
              ),
            );
          },
          childCount: tipsList.length,
        ),
      ),
    );
  }

  /// Build bottom navigation bar
  Widget _buildBottomNavBar() {
    return MiddleBtnBottomNavBar(
      midBtnOnClick: _onInfoButtonTap,
      midBtnChild: Padding(
        padding: const EdgeInsets.all(3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              'Info',
              style: AppTextStyles.sizeMin2.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      onTap: (index) {
        if (index == 1) {
          _onProfileTap();
        }
      },
      items: const [
        BottomNavigationBarItem(
          label: 'Beranda',
          icon: Icon(Icons.home_rounded),
        ),
        BottomNavigationBarItem(
          label: 'Profil',
          icon: Icon(Icons.person),
        ),
      ],
    );
  }

  // ========================================
  // NAVIGATION HANDLERS
  // ========================================

  void _onProfileTap() {
    // TODO: Navigate to profile module
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil - Coming soon')),
    );
  }

  void _onNotificationTap() {
    // TODO: Navigate to notifications
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifikasi - Coming soon')),
    );
  }

  void _onMenuTap(String moduleName) {
    // TODO: Navigate to module
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Menu: $moduleName - Coming soon')),
    );
  }

  void _onTipsTap(HomeTips tips) {
    // TODO: Navigate to tips detail
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tips: ${tips.title}')),
    );
  }

  void _onInfoButtonTap() {
    // TODO: Navigate to education module
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Info/Edukasi - Coming soon')),
    );
  }

  void _onSeeMoreTips() {
    // TODO: Navigate to education module
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lihat semua tips - Coming soon')),
    );
  }
}
