import 'package:common/arch/domain/model/profile_data.dart';
import 'package:common/arch/ui/page/_page.dart';
import 'package:common/config/_config.dart';
import 'package:common/util/providers.dart';
import 'package:common/value/const_values.dart';
import 'package:flutter/cupertino.dart';
import 'package:profile/di/profile_vm_di.dart';
import 'package:profile/ui/edit/profile_edit_page.dart';
import 'package:profile/ui/edit_family/edit_family_home_page.dart';
import 'package:profile/ui/home/profile_home_page.dart';

class ProfileRoutes extends ModuleRoute {
  ProfileRoutes._(): super(GlobalRoutes.manager);
  static final obj = ProfileRoutes._();

  @override
  SibRoute get entryPoint => profileHomePage;

  @override
  String get name => GlobalRoutes.profile;

  @override
  Set<SibRoute> get routes => {
    profileHomePage,
    profileEditPage._route,
  };


  static final profileHomePage = SibRoute("ProfileHomePage", ProfileHomePage, (ctx) => MainFrame(
    body: ProfileHomePage().inVmProvider([
      (ctx) => ProfileVmDi.obj.profileHomeVm(context: ctx),
    ]),
  ));
  static final profileEditPage = _ProfileEditPageRoute.obj;
  static final familyEditPage = SibRoute("EditFamilyHomePage", EditFamilyHomePage, (ctx) => MainFrame(
    body: EditFamilyHomePage().inVmProvider([
          (ctx) => ProfileVmDi.obj.editFamilyHomeVm(context: ctx),
    ]),
  ));
}


class _ProfileEditPageRoute {
  _ProfileEditPageRoute._();
  static final obj = _ProfileEditPageRoute._();

  final _route = SibRoute("ProfileEditPage", ProfileEditPage, (ctx) => MainFrame(
    body: ProfileEditPage().inVmProvider([
          (ctx) => ProfileVmDi.obj.profileEditVm(context: ctx),
    ]),
  ));

  Future<T?> go<T>(BuildContext context, Profile data) {
    return _route.goToPage<T>(context, args: { Const.KEY_DATA: data });
  }

  Widget buildWithArgs(Profile data) {
    // Fallback: Use existing route go() (non-awaitable) – this builder returns standard page without args.
    // Caller should pass args via route go(); for awaiting result we won't support custom builder now.
    return MainFrame(
      body: ProfileEditPage().inVmProvider([
            (ctx) => ProfileVmDi.obj.profileEditVm(context: ctx),
      ]),
    );
  }
}