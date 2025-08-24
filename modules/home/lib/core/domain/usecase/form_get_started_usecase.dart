import 'package:common/arch/domain/model/child.dart';
import 'package:common/arch/domain/model/father.dart';
import 'package:common/arch/domain/model/mother.dart';
import 'package:common/arch/domain/repo/_repos.dart';
import 'package:core/domain/model/result.dart';

// Accept ChildEntity for saving (clean data to server) rather than raw.
mixin SaveChildrenData {
  Future<Result<bool>> call({
    required List<ChildEntity> data,
    required String email,
    required int? pregnancyId,
  });
}

mixin UpdateChildData {
  Future<Result<bool>> call({required int id, required Map<String, dynamic> body});
}

mixin SaveFatherData {
  Future<Result<bool>> call(Father data);
}

mixin UpdateFatherData {
  Future<Result<bool>> call({required int id, required Map<String, dynamic> body});
}

mixin SaveMotherData {
  Future<Result<bool>> call(Mother data);
}

mixin UpdateMotherData {
  Future<Result<bool>> call({required int id, required Map<String, dynamic> body});
}

mixin SaveMotherHpl {
  Future<Result<bool>> call({
    required DateTime date,
    required String motherNik,
  });
}


mixin SaveChildrenCount {
  Future<Result<bool>> call(int count);
}

mixin DeleteCurrentMotherHpl {
  Future<Result<bool>> call();
}





class SaveFatherDataImpl with SaveFatherData {
  SaveFatherDataImpl(this.repo);
  final FatherRepo repo;
  @override
  Future<Result<bool>> call(Father data) => repo.saveFatherData(data);
}

class UpdateFatherDataImpl with UpdateFatherData {
  UpdateFatherDataImpl(this.repo);
  final FatherRepo repo;
  @override
  Future<Result<bool>> call({required int id, required Map<String, dynamic> body}) => repo.updateFatherData(id: id, body: body);
}

class SaveMotherDataImpl with SaveMotherData {
  SaveMotherDataImpl(this.repo);
  final MotherRepo repo;
  @override
  Future<Result<bool>> call(Mother data) => repo.saveMotherData(data);
}

class UpdateMotherDataImpl with UpdateMotherData {
  UpdateMotherDataImpl(this.repo);
  final MotherRepo repo;
  @override
  Future<Result<bool>> call({required int id, required Map<String, dynamic> body}) => repo.updateMotherData(id: id, body: body);
}

class SaveMotherHplImpl with SaveMotherHpl {
  final MotherRepo _repo;
  SaveMotherHplImpl(this._repo);
  Future<Result<bool>> call({
    required DateTime date,
    required String motherNik,
  }) => _repo.saveMotherHpl(
    date: date,
    motherNik: motherNik,
  );
}

class SaveChildrenCountImpl with SaveChildrenCount {
  final ChildRepo _repo;
  SaveChildrenCountImpl(this._repo);
  Future<Result<bool>> call(int count) => _repo.saveChildrenCount(count);
}
class SaveChildrenDataImpl with SaveChildrenData {
  final ChildRepo _repo;
  SaveChildrenDataImpl(this._repo);
  @override
  Future<Result<bool>> call({
    required List<ChildEntity> data,
    required String email,
    required int? pregnancyId,
  }) => _repo.saveChildrenData(
    data: data,
    email: email,
    pregnancyId: pregnancyId
  );
}

class UpdateChildDataImpl with UpdateChildData {
  final ChildRepo _repo;
  UpdateChildDataImpl(this._repo);
  @override
  Future<Result<bool>> call({required int id, required Map<String, dynamic> body}) => _repo.updateChildData(id: id, body: body);
}

class DeleteCurrentMotherHplImpl with DeleteCurrentMotherHpl {
  final MotherRepo _repo;
  DeleteCurrentMotherHplImpl(this._repo);
  @override
  Future<Result<bool>> call() => _repo.deleteCurrentMotherHpl();
}