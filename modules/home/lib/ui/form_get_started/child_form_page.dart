
import 'package:common/arch/domain/model/img_data.dart';
import 'package:common/arch/domain/model/profile_data.dart';
import 'package:common/arch/ui/widget/_basic_widget.dart';
import 'package:common/arch/ui/widget/form_controller.dart';
import 'package:common/arch/ui/widget/form_generic_vm_group_observer.dart';
import 'package:common/arch/ui/widget/form_vm_observer.dart';
import 'package:common/arch/ui/widget/picker_icon_widget.dart';
import 'package:common/config/manifest.dart';
import 'package:common/res/string/_string.dart';
import 'package:common/res/theme/_theme.dart';
import 'package:common/util/navigations.dart';
import 'package:common/util/ui.dart';
import 'package:common/value/const_values.dart';
import 'package:core/ui/base/live_data.dart';
import 'package:core/ui/base/live_data_observer.dart';
import 'package:core/ui/base/view_model.dart';
import 'package:core/util/_consoles.dart';
import 'package:flutter/material.dart';
import 'package:home/config/home_routes.dart';
import 'package:home/ui/form_get_started/child_form_vm.dart';

class ChildFormPage extends StatelessWidget {
  final PageController? pageControll;
  final MutableLiveData<PageController>? nestedPageControll;
  final PageController innerPageControll = PageController();
  final FormGroupInterceptor? interceptor;
  //final LiveData<int>? childCount;
  final int defaultChildCount = 1;
  final bool onlySinglePage;

  ChildFormPage({
    this.pageControll,
    this.nestedPageControll,
    //this.childCount,
    this.interceptor,
    this.onlySinglePage = true,
  });

  @override
  Widget build(BuildContext context) {
    prind("ChildFormPage.build()");
    final credential = getArgs<ProfileCredential>(context, Const.KEY_CREDENTIAL);
    final isEdit = getArgs<bool>(context, Const.KEY_IS_EDIT) == true;

    final vm = ViewModelProvider.of<ChildFormVm>(context)
      // Force reload when editing so form always reflects latest backend data.
      ..getChildData(credential: credential, forceLoad: isEdit)
      //..childCount.value = childCount
/*
      ..onActiveInParent = () {
        nestedPageControll?.value = innerPageControll;
      }
 */
      ..onSaveBatch.observeForever((canProceed) {
        // NOTE: Saat mode edit anak, navigasi & result dikendalikan khusus
        // di _ChildSingleFormPage (mengembalikan {id, name}) agar parent
        // bisa patch nama secara lokal tanpa reload penuh.
        if(isEdit) return; // Jangan auto-pop di mode edit.
        if(canProceed == true) {
          if(!onlySinglePage) {
            if(pageControll != null) {
              pageControll!.animateToPage(
                pageControll!.page!.toInt() +1,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            } else {
              HomeRoutes.newAccountConfirmPage.goToPage(context);
            }
          } else {
            backPage(context, result: true);
          }
        }
      });

    bool isBuilt = false;
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      innerPageControll.jumpToPage(0);
      innerPageControll.notifyListeners();
      nestedPageControll?.value = innerPageControll;
      isBuilt = true;
      //vm.pageInParent = pageControll?.page?.toInt();
    });

    pageControll?.addListener(() {
      final currPage = pageControll!.page;
      if(currPage != null) {
        int currPageInt;
        prind("pageControll?.addListener(()) isBuilt= $isBuilt currPage= $currPage vm.pageInParent= ${vm.pageInParent}");
        if(isBuilt && currPage == (currPageInt = currPage.toInt())) {
          nestedPageControll?.value = vm.checkPageActiveInParent(currPageInt)
              ? innerPageControll : null;
        }
      }
    });

    innerPageControll.addListener(() {
      final page = innerPageControll.page;
      if(page != null) {
        int pageInt;
        if(page == (pageInt = page.toInt())) {
          vm.initPage(pageInt);
        }
      }
    });

    final builder = (ctx, count) {
      prind("ChildFormPage LiveDataObserver.builder count= $count");
      return count != null ? PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: innerPageControll,
        children: List.generate(
          count, (index) => _ChildSingleFormPage(
            page: index,
            vm: vm,
            interceptor: interceptor,
            innerPageControll: innerPageControll,
            pageControll: pageControll,
            onlySinglePage: onlySinglePage,
            isEdit: isEdit,
          ),
        ),
      ) : defaultLoading();
    };

    return LiveDataObserver<int>(
      liveData: vm.childCount,
      builder: builder,
    );
  }
}

class _ChildSingleFormPage extends StatelessWidget {
  final bool onlySinglePage;
  final PageController innerPageControll;
  final PageController? pageControll;
  final FormGroupInterceptor? interceptor;
  final ChildFormVm vm;
  final int page;
  final bool isEdit;

  _ChildSingleFormPage({
    required this.vm,
    required this.page,
    required this.innerPageControll,
    required this.pageControll,
    required this.interceptor,
    required this.onlySinglePage,
    required this.isEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
      children: [
        Text(
          (!isEdit ? Strings.fill_child_data : Strings.edit_child_data) +"\n(${page+1})",
          style: SibTextStyles.header1,
          textAlign: TextAlign.center,
        ).withMargin(EdgeInsets.only(top: 60)),
        //ImgPick().withMargin(EdgeInsets.only(top: 10, bottom: 15)),
        LiveDataObserver<ImgData>(
          liveData: vm.imgProfile,
          builder: (ctx, img) => ImgPick(
            pic: img,
            onImgPick: (file) => vm.imgProfile.value = file != null
                ? ImgData.fromXFile(file) : null,
          ),
        ).withMargin(EdgeInsets.only(top: 10, bottom: 20,)),
        /*TxtLink(
          Strings.skip,
          onTap: () => showSnackBar(context, "dipencet"),
        ),*/
        FormVmGroupObserver<ChildFormVm>(
          vm: vm,
          showHeader: false,
          interceptor: interceptor,
          submissionKeys: {
            ChildFormVm.saveBatchChildrenKey,
          },
          pickerIconBuilder: (group, key, data) {
            if(group == 0) {
              switch(key) {
                case Const.KEY_BIRTH_PLACE:
                  return CityPickerIcon(
                    onItemSelected: (city) async {
                      data.value = city;
                    },
                  );
                case Const.KEY_BABY_GENDER:
                  return GenderPickerIcon(
                    onItemSelected: (gender) async {
                      data.value = gender?.name[0];
                    },
                  );
                case Const.KEY_BLOOD_TYPE:
                  return BloodTypePickerIcon(
                    onItemSelected: (bloodType) async {
                      data.value = bloodType?.name;
                    },
                  );
              }
            }
          },
          onPreSubmit: (ctx, canProceed) {
            if(canProceed != true) {
              showSnackBar(ctx, Strings.there_still_invalid_fields);
            }
          },
          onSubmit: (ctx, success) {
            prind("page < vm.childCount.value! -1 success= $success page= $page vm.currentPage= ${vm.currentPage} vm.childCount= ${vm.childCount}");
            if(success) {
              if(isEdit) {
                // Ambil nama baru dari form sebelum request update jalan.
                final respMap = vm.getResponseMap();
                final newName = (respMap[Const.KEY_NAME_INDO] ?? respMap[Const.KEY_NAME])?.toString();
                // Ambil tanggal lahir (DateTime atau String) dan normalisasi yyyy-MM-dd
                final bdObj = respMap[Const.KEY_BIRTH_DATE];
                String? birthDateStr;
                if(bdObj is DateTime) {
                  birthDateStr = bdObj.toIso8601String().substring(0,10);
                } else if(bdObj is String && bdObj.isNotEmpty) {
                  birthDateStr = bdObj.length >= 10 ? bdObj.substring(0,10) : bdObj;
                }
                // Observer sekali saja untuk menunggu sukses update.
                void onceObserver(bool? v) {
                  if(v == true) {
                    vm.onSaveBatch.removeObserver(onceObserver);
                    backPage(context, result: {
                      'id': vm.currentCredentialId,
                      'name': newName,
                      if(birthDateStr != null) 'birthDate': birthDateStr,
                    });
                  }
                }
                vm.onSaveBatch.observeForever(onceObserver);
                vm.saveBatchChildren();
              } else {
                if(vm.currentPage.value! < vm.childCount.value! -1) { // It should be impossible to be null cuz off course if null, then this `_ChildSingleFormPage` won't be built.
                  innerPageControll.animateToPage(
                    innerPageControll.page!.toInt() +1,
                    duration: Duration(milliseconds: 600,),
                    curve: Curves.easeOut,
                  );
                } else {
                  vm.saveBatchChildren();
                }
              }
/*
              // It has been handled in parent page by observing `onSaveBatch`.
              else {
                if(pageControll != null) {
                  pageControll!.animateToPage(
                    pageControll!.page!.toInt() +1,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  );
                } else {
                  HomeRoutes.newAccountConfirmPage.goToPage(context);
                }
              }
 */
            } else {
              showSnackBar(context, "Terjadi kesalahan",);
            }
          },
          submitBtnMargin: !onlySinglePage ? EdgeInsets.only(bottom: 15,) : null,
          submitBtnBuilder: (ctx, canProceed) => !isEdit ? FloatingActionButton(
            child: Icon(Icons.arrow_forward_rounded,),
            backgroundColor: canProceed == true ? pink_300 : grey,
            onPressed: null,
          ) : TxtBtn(
            Strings.update_data,
            color: canProceed == true ? Manifest.theme.colorPrimary : grey,
          ),
        ),
      ],
    ).insideScroll(),
        // Overlay dihapus agar konsisten dengan form ibu/ayah (hanya loader di posisi tombol).
      ],
    );
  }
}