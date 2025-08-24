import 'package:common/arch/domain/dummy_data.dart';
import 'package:common/arch/ui/vm/form_vm_group.dart';
import 'package:common/arch/ui/widget/_basic_widget.dart';
import 'package:common/arch/ui/widget/form_generic_vm_group_observer.dart';
import 'package:common/arch/ui/widget/img_pick.dart';
import 'package:common/res/string/_string.dart';
import 'package:common/res/theme/_theme.dart';
import 'package:common/util/assets.dart';
import 'package:common/util/ui.dart';
import 'package:common/value/const_values.dart';
import 'package:core/domain/model/wrapper.dart';
import 'package:core/ui/base/async_view_model_observer.dart';
import 'package:core/ui/base/live_data.dart';
import 'package:core/ui/base/live_data_observer.dart';
import 'package:core/ui/base/view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home/config/home_routes.dart';
import 'package:home/ui/form_get_started/get_started_form_main_vm.dart';


class NewAccountConfirmPage extends StatelessWidget {
  final PageController? pageControll; //TODO: not used yet.
  final Var<void Function()?>? onBackPressedContainer; //TODO: not used yet.

  NewAccountConfirmPage({
    this.pageControll,
    this.onBackPressedContainer,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final imgSize = screenSize.width /2;

    final vm = ViewModelProvider.of<GetStartedFormMainVm>(context)
      ..onSubmit.observeForever((success) {
        if(success != true) {
          showSnackBar(context, Strings.form_submission_fail);
        }
      })
      ..onLogin.observeForever((success) {
        if(success == true) {
          // Tampilkan snackbar SEBELUM navigasi untuk menghindari akses context disposed
          showSnackBar(context, Strings.welcome_mother, backgroundColor: Colors.green);
          HomeRoutes.homePage.goToPage(context, clearPrevs: true);
        } else {
          showSnackBar(context, Strings.form_submission_fail);
        }
      });

    final nameLiveData = MutableLiveData<String>();
    vm.signUpFormVm.isFormReady.observeForever((isFormReady) {
      if(isFormReady == true) {
        nameLiveData.value = vm.signUpFormVm.responseGroupList.first[Const.KEY_NAME]?.response.value;
      }
    });
    if(vm.signUpFormVm.isFormReady.value == true) {
      nameLiveData.value = vm.signUpFormVm.responseGroupList.first[Const.KEY_NAME]?.response.value;
    }

    onBackPressedContainer?.value = () {
      if(pageControll != null) {
        final count = vm.childrenCountVm.childrenCount.value;
        final diff = count != null && count > 0 ? 1 : 2;
        pageControll!.animateToPage(
          pageControll!.page!.toInt() -diff,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    };

    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Text(
            Strings.confirm_new_account,
            style: SibTextStyles.header1,
          ).withMargin(EdgeInsets.only(top: 60)),
        ),
        //ImgPick().withMargin(EdgeInsets.only(top: 10)),
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: SibImages.resolve(
                  dummyImg_profile,
                  width: imgSize,
                  height: imgSize,
                ),
              ),
              Text(
                Strings.welcome_mother,
                style: SibTextStyles.header1.copyWith(
                    fontWeight: FontWeight.normal,
                ),
              ).withMargin(EdgeInsets.only(top: 15)),
              LiveDataObserver<String>(
                liveData: nameLiveData,
                builder: (ctx, name) => Text(
                  name ?? "<null>",
                  style: SibTextStyles.header1,
                ).withMargin(EdgeInsets.only(top: 10)),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 90,
            ),
            child: Builder(
              builder: (ctx) {
                final submitBtnBuilder = (ctx, data) {
                  return TxtBtn(
                    Strings.make_new_mother_account,
                    color: green_calm, //data == true ? green_calm : grey,
                    onTap: () => vm.sendData(), //data == true ? () => vm.sendData() : null,
                  );
                };
                return AsyncVmObserver<GetStartedFormMainVm, bool>(
                  vm: vm,
                  liveDataGetter: (vm) => vm.onSubmit,
                  preAsyncBuilder: (BuildContext ctx, String key) {
                    if(key == GetStartedFormMainVm.sendDataKey) {
                      return defaultLoading();
                    }
                  },
                  postAsyncBuilder: (ctx, key) {
                    if(key == GetStartedFormMainVm.sendDataKey) {
                      return submitBtnBuilder(ctx, true);
                    }
                  },
                  builder: submitBtnBuilder,
                );
              },
            ),
          ),
        ).withMargin(EdgeInsets.only(bottom: 55)),
      ],
    ); //.insideScroll();
  }
}