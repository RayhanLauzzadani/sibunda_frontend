import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../models/home_model.dart';

/// ========================================
/// HOME WIDGETS - SiBunda
/// Matching repo lama _items_home.dart
/// ========================================

const double _cornerRadius = 10.0;
const double _paddingSmall = 10.0;

// Size constants matching repo lama
const double _size3 = 80.0;
const double _size4 = 100.0;
const double _size9 = 240.0;

/// Status card widget for home dashboard
/// Matches ItemDashboardStatus from repo lama
class ItemDashboardStatus extends StatelessWidget {
  final String content;
  final IconData? icon;
  final String? imageUrl;
  final Color bgColor;

  const ItemDashboardStatus({
    super.key,
    required this.content,
    this.icon,
    this.imageUrl,
    this.bgColor = AppColors.greenSafe,
  });

  factory ItemDashboardStatus.fromData(HomeStatus data) {
    return ItemDashboardStatus(
      content: data.desc,
      icon: data.icon,
      imageUrl: data.imageUrl,
      bgColor: data.color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final imgChild = Container(
      margin: const EdgeInsets.only(right: _paddingSmall),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(_cornerRadius)),
        child: SizedBox(
          width: _size3,
          height: _size3,
          child: _buildImage(),
        ),
      ),
    );

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(_cornerRadius)),
      child: Container(
        width: _size9,
        height: _size4,
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              imgChild,
              Expanded(
                child: Text(
                  content,
                  style: AppTextStyles.sizeMin1,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildIconFallback(),
      );
    }
    return _buildIconFallback();
  }

  Widget _buildIconFallback() {
    return Container(
      color: AppColors.white.withValues(alpha: 0.3),
      child: Icon(
        icon ?? Icons.health_and_safety,
        size: 40,
        color: AppColors.white,
      ),
    );
  }
}

/// Menu item widget for home dashboard
/// Matches ItemDashboardMenu from repo lama
class ItemDashboardMenu extends StatelessWidget {
  final String text;
  final IconData? icon;
  final String? imageUrl;
  final VoidCallback? onClick;

  const ItemDashboardMenu({
    super.key,
    required this.text,
    this.icon,
    this.imageUrl,
    this.onClick,
  });

  factory ItemDashboardMenu.fromData(HomeMenu data, {VoidCallback? onClick}) {
    return ItemDashboardMenu(
      text: data.name,
      icon: data.icon,
      imageUrl: data.imageUrl,
      onClick: onClick,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: AppColors.primary.withValues(alpha: 0.3),
      onTap: onClick,
      child: SizedBox(
        height: 200,
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.all(Radius.circular(_cornerRadius)),
              child: Container(
                color: AppColors.primary,
                height: 70,
                width: 70,
                child: _buildImage(),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: Text(
                text,
                style: AppTextStyles.sizeMin1BoldColorPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildIconFallback(),
      );
    }
    return _buildIconFallback();
  }

  Widget _buildIconFallback() {
    return Icon(
      icon ?? Icons.menu,
      size: 40,
      color: AppColors.white,
    );
  }
}

/// Profile widget for home top bar
/// Matches ItemProfile from repo lama
class ItemProfile extends StatelessWidget {
  final String name;
  final String? desc;
  final String? photoUrl;
  final Color? nameColor;
  final Color? descColor;

  const ItemProfile({
    super.key,
    required this.name,
    this.desc,
    this.photoUrl,
    this.nameColor,
    this.descColor,
  });

  factory ItemProfile.fromData(HomeProfile data) {
    return ItemProfile(
      name: data.name,
      desc: data.age != null ? '${data.age} tahun' : null,
      photoUrl: data.photoUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nameTextStyle = AppTextStyles.sizePlus2ColorOnPrimary.copyWith(
      color: nameColor ?? AppColors.white,
    );
    final descTextStyle = AppTextStyles.sizeMin1.copyWith(
      color: descColor ?? AppColors.yellow,
    );

    final txtChildren = <Widget>[
      Text(name, style: nameTextStyle),
    ];

    if (desc != null) {
      txtChildren.add(
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: Text(desc!, style: descTextStyle),
        ),
      );
    }

    return Container(
      height: 60,
      margin: const EdgeInsets.only(left: 30),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 50,
              height: 50,
              color: AppColors.white.withValues(alpha: 0.3),
              child: _buildProfileImage(),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: txtChildren,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return Image.network(
        photoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildAvatarFallback(),
      );
    }
    return _buildAvatarFallback();
  }

  Widget _buildAvatarFallback() {
    return const Icon(
      Icons.person,
      size: 30,
      color: AppColors.white,
    );
  }
}

/// Tips item widget for home
/// Matches ItemTips from repo lama
class ItemTips extends StatelessWidget {
  final String headline;
  final String kind;
  final String? imageUrl;
  final VoidCallback? onTap;

  const ItemTips({
    super.key,
    required this.headline,
    required this.kind,
    this.imageUrl,
    this.onTap,
  });

  factory ItemTips.fromData(HomeTips data, {VoidCallback? onTap}) {
    return ItemTips(
      headline: data.title,
      kind: data.kind,
      imageUrl: data.imageUrl,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    const parentHeight = 100.0;

    final imgChild = Container(
      margin: const EdgeInsets.only(right: 10),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        child: SizedBox(
          height: parentHeight,
          width: parentHeight,
          child: _buildImage(),
        ),
      ),
    );

    final txtChild = Expanded(
      child: Container(
        height: parentHeight,
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                headline,
                style: AppTextStyles.sizeMin1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                kind,
                style: AppTextStyles.sizeMin2ColorPrimary,
              ),
            ),
          ],
        ),
      ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(15)),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        child: Container(
          color: Colors.white,
          child: Row(
            children: [
              imgChild,
              txtChild,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImageFallback(),
      );
    }
    return _buildImageFallback();
  }

  Widget _buildImageFallback() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.2),
      child: const Icon(
        Icons.article,
        size: 40,
        color: AppColors.primary,
      ),
    );
  }
}

/// Custom bottom navigation bar with middle FAB button
/// Matches MiddleBtnBottomNavBar from repo lama
class MiddleBtnBottomNavBar extends StatelessWidget {
  final void Function(int)? onTap;
  final List<BottomNavigationBarItem> items;
  final Widget? midBtnChild;
  final VoidCallback? midBtnOnClick;
  final int currentIndex;

  const MiddleBtnBottomNavBar({
    super.key,
    required this.midBtnChild,
    required this.items,
    this.onTap,
    this.midBtnOnClick,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: ClipPath(
            clipper: _BottomNavBarClipper(),
            child: Container(
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: BottomNavigationBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: const Color(0xFFE5E5E5),
                currentIndex: currentIndex,
                onTap: onTap,
                items: items,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 46,
            width: 46,
            margin: const EdgeInsets.only(bottom: 42),
            child: FloatingActionButton(
              elevation: 0,
              backgroundColor: AppColors.primary,
              onPressed: midBtnOnClick,
              child: midBtnChild,
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomNavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(size.width / 2 - 28, 0);
    path.quadraticBezierTo(size.width / 2 - 28, 33, size.width / 2, 33);
    path.quadraticBezierTo(size.width / 2 + 28, 33, size.width / 2 + 28, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Top navigation bar with rounded background
/// Matches RoundedTopNavBarBg from repo lama
class RoundedTopNavBar extends StatelessWidget {
  final List<Widget> children;
  final double height;

  const RoundedTopNavBar({
    super.key,
    required this.children,
    this.height = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      height: height + topPadding,
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
          children: children,
        ),
      ),
    );
  }
}
