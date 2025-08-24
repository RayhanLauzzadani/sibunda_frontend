import 'package:common/arch/data/local/db/app_db.dart';
import 'package:common/arch/data/local/entity/account_entity.dart';
import 'package:common/util/db_util.dart';
import 'package:core/util/_consoles.dart';
import 'package:moor/moor.dart';

part 'account_dao.g.dart';

@UseDao(tables: [CredentialEntities])
class CredentialDao extends DatabaseAccessor<AppDatabase> with _$CredentialDaoMixin {
  CredentialDao(AppDatabase attachedDatabase) : super(attachedDatabase);

  Future<bool> dropTable() async {
    try {
      await customStatement(getDropTableStatement(credentialEntities.tableName));
      return true;
    } catch(e, stack) {
      prine(e);
      prine(stack);
      return false;
    }
  }
  Future<int> insert(Insertable<CredentialEntity> e) => into(credentialEntities).insert(e);
  Future<void> insertAll(List<Insertable<CredentialEntity>> e) => batch((batch) => batch.insertAll(credentialEntities, e));
  Future<int> deleteData(Insertable<CredentialEntity> e) => delete(credentialEntities).delete(e);
  Future<int> deleteAll() => delete(credentialEntities).go();
  Future<CredentialEntity?> getByEmail(String email) => (select(credentialEntities)..where((it) => it.email.equals(email))).getSingleOrNull();
  Future<CredentialEntity?> getById(int id) => (select(credentialEntities)..where((it) => it.id.equals(id))).getSingleOrNull();
}

@UseDao(tables: [RoleEntities])
class RoleDao extends DatabaseAccessor<AppDatabase> with _$RoleDaoMixin {
  RoleDao(AppDatabase attachedDatabase) : super(attachedDatabase);

  Future<bool> dropTable() async {
    try {
      await customStatement(getDropTableStatement(roleEntities.tableName));
      return true;
    } catch(e, stack) {
      prine(e);
      prine(stack);
      return false;
    }
  }
  Future<int> insert(Insertable<RoleEntity> e) => into(roleEntities).insert(e);
  Future<void> insertAll(List<Insertable<RoleEntity>> e) => batch((batch) => batch.insertAll(roleEntities, e));
  Future<int> deleteData(Insertable<RoleEntity> e) => delete(roleEntities).delete(e);
}


@UseDao(tables: [ProfileTypeEntities])
class ProfileTypeDao extends DatabaseAccessor<AppDatabase> with _$ProfileTypeDaoMixin {
  ProfileTypeDao(AppDatabase attachedDatabase) : super(attachedDatabase);

  Future<bool> dropTable() async {
    try {
      await customStatement(getDropTableStatement(profileTypeEntities.tableName));
      return true;
    } catch(e, stack) {
      prine(e);
      prine(stack);
      return false;
    }
  }
  Future<int> insert(Insertable<ProfileTypeEntity> e) => into(profileTypeEntities).insert(e);
  Future<void> insertAll(List<Insertable<ProfileTypeEntity>> e) => batch((batch) => batch.insertAll(profileTypeEntities, e));
  Future<int> deleteData(Insertable<ProfileTypeEntity> e) => delete(profileTypeEntities).delete(e);
}

@UseDao(tables: [ProfileEntities, CredentialEntities, ProfileTypeEntities])
class ProfileDao extends DatabaseAccessor<AppDatabase> with _$ProfileDaoMixin {
  ProfileDao(AppDatabase attachedDatabase) : super(attachedDatabase);

  Future<bool> dropTable() async {
    try {
      await customStatement(getDropTableStatement(profileEntities.tableName));
      return true;
    } catch(e, stack) {
      prine(e);
      prine(stack);
      return false;
    }
  }
  Future<int> insert(Insertable<ProfileEntity> e) => into(profileEntities).insert(e);
  Future<void> insertAll(List<Insertable<ProfileEntity>> e) => batch((batch) => batch.insertAll(profileEntities, e));
  Future<int> deleteData(Insertable<ProfileEntity> e) => delete(profileEntities).delete(e);
  Future<int> deleteAll() => delete(profileEntities).go();

  Future<int?> getCredentialIdByNik(String nik, { int? type }) async {
    final sel = select(profileEntities)..where((it) => it.nik.equals(nik));
    if(type != null) {
      sel.where((it) => it.type.equals(type));
    }
    return (await sel.getSingleOrNull())?.userId;
  }

  Future<ProfileEntity?> getByNik(String nik, { int? type }) async {
    final sel = select(profileEntities)..where((it) => it.nik.equals(nik));
    if(type != null) {
      sel.where((it) => it.type.equals(type));
    }
    return sel.getSingleOrNull();
  }
  Future<ProfileEntity?> getByServerId(int serverId, { int? type }) async {
    final sel = select(profileEntities)..where((it) => it.serverId.equals(serverId));
    if(type != null) {
      sel.where((it) => it.type.equals(type));
    }
    return sel.getSingleOrNull();
  }
  Future<ProfileEntity?> getByPregnancyId(int pregnancyId, { int? type }) async {
    final sel = select(profileEntities)..where((it) => it.pregnancyId.equals(pregnancyId));
    if(type != null) {
      sel.where((it) => it.type.equals(type));
    }
    return sel.getSingleOrNull();
  }

  /// It returns [Map]<int, List<String>> that maps [ProfileEntities.type]
  /// to map that maps [ProfileEntities.serverId] to [ProfileEntities.nik].
  /// Why map? Because, there may multiple children
  /// that belong to same [email] of mother.
  Future<Map<int, Map<int, String>>> getNiksByEmail(String email, { int? type }) async {
    prind("ProfileDao getNiksByEmail() email= $email type= $type");
    final credentials = await (select(credentialEntities)..where((it) => it.email.equals(email))).get();
    prind("ProfileDao getNiksByEmail() credentials = $credentials");
    if(credentials.isEmpty) {
      return Map.unmodifiable({});
    }
    final id = credentials.first.id;
    var sel = select(profileEntities)..where((it) => it.userId.equals(id));
    if(type != null) {
      sel = sel..where((it) => it.type.equals(type));
    }

    final queried = await sel.map((it) => {it.type: it}).get();
    final res = <int, Map<int, String>>{};
    for(final e in queried) {
      final map = res[e.keys.first] ??= {};
      map[e.values.first.serverId] = e.values.first.nik;
      //res.addAll(e);
    }
    return res;
  }

  /// It returns [Map]<int, List<String>> that maps [ProfileEntities.type]
  /// to list of [ProfileEntities.nik]. Why list? Because, there may multiple children
  /// that belong to same [email] of mother.
  Future<Map<int, List<ProfileEntity>>> getProfilesByEmail(String email, { int? type }) async {
    prind("ProfileDao getNiksByEmail() email= $email type= $type");
    final credentials = await (select(credentialEntities)..where((it) => it.email.equals(email))).get();
    prind("ProfileDao getNiksByEmail() credentials = $credentials");
    if(credentials.isEmpty) {
      return Map.unmodifiable({});
    }
    final id = credentials.first.id;
    var sel = select(profileEntities)..where((it) => it.userId.equals(id));
    if(type != null) {
      sel = sel..where((it) => it.type.equals(type));
    }

    final queried = await sel.map((it) => {it.type: it}).get();
    final res = <int, List<ProfileEntity>>{};
    for(final e in queried) {
      final list = res[e.keys.first] ??= [];
      list.add(e.values.first);
      //res.addAll(e);
    }
    return res;
  }

  /// It returns [Map]<int, String> that maps [ProfileEntities.type] to [ProfileEntities.serverId];
  Future<Map<int, int>> getServerIdByNik(String nik, { int? type }) async {
    final sel = (select(profileEntities)..where((it) => it.nik.equals(nik)));
    if(type != null) {
      sel.where((it) => it.type.equals(type));
    }

    final queried = await sel.map((it) => {it.type: it.serverId}).get();
    final res = <int, int>{};
    for(final e in queried) {
      res.addAll(e);
    }
    return res;
  }

  Future<int> updateChildName({required int serverId, required String newName}) async {
    return (update(profileEntities)..where((tbl) => tbl.serverId.equals(serverId)))
        .write(ProfileEntitiesCompanion(name: Value(newName)));
  }

  Future<int> updateProfileMeta({
    required int serverId,
    String? name,
    String? birthDateIso, // expected yyyy-MM-dd
    int? birthPlace,
  }) async {
    DateTime? bd;
    if(birthDateIso != null) {
      var s = birthDateIso;
      if(s.length > 10) s = s.substring(0,10);
      try { bd = DateTime.tryParse(s); } catch(_){ bd = null; }
    }
    final companion = ProfileEntitiesCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      birthDate: bd != null ? Value(bd) : const Value.absent(),
      birthPlace: birthPlace != null ? Value(birthPlace) : const Value.absent(),
    );
  if(companion == ProfileEntitiesCompanion()) return 0; // nothing to update
    return (update(profileEntities)..where((tbl) => tbl.serverId.equals(serverId))).write(companion);
  }
}