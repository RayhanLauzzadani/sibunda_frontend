import 'package:common/arch/domain/model/profile_data.dart';
import 'package:common/arch/ui/page/secondary_frames.dart';
import 'package:common/arch/ui/widget/_basic_widget.dart';
import 'package:common/arch/ui/widget/_items_profile.dart';
import 'package:common/config/_config.dart';
import 'package:common/res/string/_string.dart';
import 'package:common/util/assets.dart';
import 'package:common/util/ui.dart';
import 'package:core/ui/base/async_view_model_observer.dart';
import 'package:core/ui/base/live_data_observer.dart';
import 'package:core/ui/base/view_model.dart';
import 'package:core/util/_consoles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:profile/config/profile_routes.dart';
import 'package:profile/ui/home/profile_home_vm.dart';
import 'package:profile/ui/edit/profile_edit_page.dart';
import 'package:profile/di/profile_vm_di.dart';


class ProfileHomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final vm = ViewModelProvider.of<ProfileHomeVm>(context)
        ..getProfile();

    vm.onLogout.observe(vm, (success) {
      if(success == true) {
        vm.toLoginPage(context);
      } else {
        showSnackBar(context, Strings.error_occurred_when_logout);
      }
    });

    return TopBarTitleAndBackFrame(
      //withTopOffset: true,
      title: "Profile",
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            LiveDataObserver<Profile>(
              liveData: vm.profile,
              builder: (ctx, data) => data != null ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ItemProfilePic.fromData(data),
                  _MenuList(profile: data),
                ],
              ) : defaultLoading(),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: LiveDataObserver(
                  liveData: vm.profile,
                  builder: (ctx, data) => data != null ? AsyncVmObserver<ProfileHomeVm, bool>(
                    liveDataGetter: (vm) => vm.onLogout,
                    preAsyncBuilder: (ctx, key) {
                      if(key == ProfileHomeVm.logoutKey) {
                        return CircularProgressIndicator();
                      }
                    },
                    builder: (ctx, data) => Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: TxtBtn(
                        Strings.logout,
                        isHollow: true,
                        onTap: () => vm.logout(),
                      ),
                    ),
                  ) : defaultEmptyWidget(),
                ),
              ),
            ),
          ],
        ),
          //BelowTopBarScrollContentArea(slivers: [SliverList(delegate: SliverChildListDelegate.fixed([]),),]),
      ),
    );
  }
}


class _MenuList extends StatelessWidget {
  final Profile profile;

  _MenuList({
    required this.profile
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
              onTap: () async {
                final res = await ProfileRoutes.profileEditPage.go(context, profile);
                if(res == true) {
                  ViewModelProvider.of<ProfileHomeVm>(context).getProfile(forceLoad: true);
                }
              },
          child: ListTile(
            leading: SibImages.get("ic_profile_sm.png", package: "common"),
            title: Text("Edit Profil"),
          ),
        ),
        InkWell(
          onTap: () async {
            final res = await ProfileRoutes.familyEditPage.goToPage(context);
            if(res == true) {
              ViewModelProvider.of<ProfileHomeVm>(context).getProfile(forceLoad: true);
            }
          },
          child: ListTile(
            leading: SibImages.get("ic_wallet.png", package: "common"),
            title: Text("Edit Data Keluarga"),
          ),
        ),
        Visibility(
          visible: false,
          child: Column(
            children: [
              InkWell(
                child: ListTile(
                  leading: SibImages.get("ic_verified.png", package: "common"),
                  title: Text("Pusat Bantuan"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}