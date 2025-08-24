import 'package:common/arch/domain/model/child.dart';
import 'package:common/arch/domain/model/father.dart';
import 'package:common/arch/domain/model/mother.dart';
import 'package:common/arch/domain/model/profile_data.dart';
import 'package:common/arch/domain/repo/_repos.dart';
import 'package:common/arch/domain/repo/mother_repo.dart';
import 'package:core/domain/model/result.dart';

mixin GetMotherData {
  Future<Result<Mother>> call(ProfileCredential credential);
}

mixin GetFatherData {
  Future<Result<Father>> call(ProfileCredential credential);
}

// Return ChildEntity to expose stable non-null data shape.
mixin GetChildData {
  Future<Result<ChildEntity>> call(ProfileCredential credential);
}


class GetMotherDataImpl with GetMotherData {
  final MotherRepo _repo;
  GetMotherDataImpl(this._repo);
  @override
  Future<Result<Mother>> call(ProfileCredential credential) => _repo.getMotherData(credential);
}

class GetFatherDataImpl with GetFatherData {
  final FatherRepo _repo;
  GetFatherDataImpl(this._repo);
  @override
  Future<Result<Father>> call(ProfileCredential credential) => _repo.getFatherData(credential);
}

class GetChildDataImpl with GetChildData {
  final ChildRepo _repo;
  GetChildDataImpl(this._repo);
  @override
  Future<Result<ChildEntity>> call(ProfileCredential credential) => _repo.getChildData(credential);
}