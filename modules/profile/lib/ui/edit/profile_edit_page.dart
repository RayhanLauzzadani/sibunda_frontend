import 'package:profile/ui/home/profile_home_vm.dart';
import 'package:common/arch/domain/model/img_data.dart';
import 'package:common/arch/domain/model/profile_data.dart';
import 'package:common/arch/ui/page/secondary_frames.dart';
import 'package:common/arch/ui/widget/_basic_widget.dart';
import 'package:common/arch/ui/widget/form_generic_vm_group_observer.dart';
import 'package:common/config/_config.dart';
import 'package:common/res/string/_string.dart';
import 'package:common/res/theme/_theme.dart';
import 'package:common/util/navigations.dart';
import 'package:common/util/ui.dart';
import 'package:common/value/const_values.dart';
import 'package:core/ui/base/live_data_observer.dart';
import 'package:core/ui/base/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:profile/ui/edit/profile_edit_vm.dart';

// ignore: must_be_immutable
class ProfileEditPage extends StatelessWidget {
  final Profile? initialProfile;
  ProfileEditPage({Key? key, this.initialProfile}) : super(key: key);

  late void Function(bool?) _onChange;

  @override
  Widget build(BuildContext context) {
    final profile = initialProfile ?? getArgs<Profile>(context, Const.KEY_DATA);
    if(profile == null) {
      throw "$runtimeType needs `Profile` argument or initialProfile";
    }

    final vm = ViewModelProvider.of<ProfileEditVm>(context);
    _onChange = (bool? isReady) {
      if(isReady == true) {
        vm.setProfile(profile);
        vm.isFormReady.removeObserver(_onChange);
      }
    };
    vm.isFormReady.observeForever(_onChange);
    vm.init();

    return TopBarTitleAndBackFrame(
      withTopOffset: true,
      title: "Edit Profil Bunda",
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10,),
        child: BelowTopBarScrollContentArea(slivers: [
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              /*
              Container(
                margin: EdgeInsets.only(bottom: 20,),
                child: ImgPick(pic: profile.img,),
              ),
               */
              LiveDataObserver<ImgData>(
                liveData: vm.imgProfile,
                builder: (ctx, img) => ImgPick(
                  pic: img,
                  onImgPick: (file) => vm.imgProfile.value = file != null
                      ? ImgData.fromXFile(file) : null,
                ),
              ).withMargin(EdgeInsets.only(top: 10, bottom: 20,)),
              FormVmGroupObserver<ProfileEditVm>(
                vm: vm,
                showHeader: false,
                onPreSubmit: (ctx, canProceed) {
                  if(canProceed != true) {
                    showSnackBar(context, Strings.there_still_invalid_fields,);
                  }
                },
                pickerIconBuilder: (group, key, liveData) {
                  if(key == Const.KEY_EMAIL) {
                    return LiveDataObserver<bool>(
                      liveData: vm.isEmailAvailable,
                      builder: (ctx, available) {
                        if(available == null) return defaultLoading(showText: false);
                        return defaultEmptyWidget();
                      },
                    );
                  }
                },
                onSubmit: (ctx, success) {
                  if(success) {
                    showSnackBar(context, Strings.form_submission_success, backgroundColor: Colors.green,);
                    Navigator.pop(context, true);
                  } else {
                    showSnackBar(context, Strings.form_submission_fail,);
                  }
                },
                submitBtnBuilder: (ctx, canProceed) => TxtBtn(
                  "Update Profil Saya",
                  color: canProceed == true ? Manifest.theme.colorPrimary : grey,
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}