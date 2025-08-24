import 'package:common/arch/data/local/db/app_db.dart';
import 'package:common/arch/data/remote/model/baby_overview_api_model.dart';
import 'package:common/arch/data/remote/model/data_api_model.dart';
import 'package:common/arch/domain/dummy_data.dart';
import 'package:common/arch/domain/model/baby_data.dart';
import 'package:common/arch/domain/model/img_data.dart';
import 'package:common/util/type_util.dart';
import 'package:common/value/const_values.dart';
import 'package:common/value/db_const.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_data.freezed.dart';
part 'profile_data.g.dart';

@freezed
class ProfileCredential with _$ProfileCredential {
  const factory ProfileCredential({
    required int id,
    required String nik,
  }) = _ProfileCredential;

  factory ProfileCredential.fromChildResponse(BabyHomeChildResponse response) =>
      ProfileCredential(id: response.id, nik: response.nik,);

  factory ProfileCredential.fromBabyOverlay(BabyOverlayData data) =>
      ProfileCredential(id: data.id, nik: data.nik,);

  factory ProfileCredential.fromProfile(Profile data) =>
      ProfileCredential(id: data.id, nik: data.nik,);
}

class Profile extends Equatable {
  /// Server id
  final int id;
  final String nik;
  final String name;
  final String email;
  final DateTime birthDate;
  final ImgData img;

  Profile({
    required this.id,
    required this.nik,
    required this.name,
    required this.email,
    required this.birthDate,
    required this.img,
  });

  Profile.empty():
    id = -1,
    nik = "",
    name = "",
    email = "",
    birthDate = DateTime.now(),
    img = dummyImg_profile
  ;

  factory Profile.fromEntity({
    required ProfileEntity entity,
    required String email,
  }) => Profile(
    id: entity.serverId,
    nik: entity.nik,
    name: entity.name,
    email: email,
    img: dummyImg_profile, //dummyImg_profile_preset, //
    birthDate: entity.birthDate,
  );

  Profile copyWithNewName(String name) => Profile(
    id: id,
    nik: nik,
    name: name,
    email: email,
    birthDate: birthDate,
    img: img,
  );

  Profile copyWithNewBirthDate(DateTime newBirthDate) => Profile(
    id: id,
    nik: nik,
    name: name,
    email: email,
    birthDate: newBirthDate,
    img: img,
  );

  @override
  List<Object?> get props => [id, nik, name, email, birthDate, img];
}


class AccountData {
  final String name;
  final String email;
  final String? pswd;
  final ImgData img;

  AccountData({
    required this.name,
    required this.email,
    required this.pswd,
    required this.img,
  });
}

/// This is just like [BatchProfileServer], but only their ids.
@freezed
class BatchProfileIds with _$BatchProfileIds {
  const factory BatchProfileIds({
    required int motherId,
    required int fatherId,
    required List<int> childrenId,
  }) = _BatchProfileIds;
  factory BatchProfileIds.fromJson(Map<String, dynamic> map) = _BatchProfileIds.fromJson;
  factory BatchProfileIds.fromResponse(BioMotherResponse response) {
    Iterable<BioChildResponse> childrenItr = response.kia_anak;
    //if(filterUnbornChild) { childrenItr = childrenItr.where((e) => e.anak_ke != null); }
    return BatchProfileIds(
      motherId: response.id,
      fatherId: response.kia_ayah.id,
      childrenId: childrenItr.where((e) => !e.is_janin)
          .map<int>((e) => e.id).toList(growable: false),
    );
  }
}

@freezed
class BatchProfileServer with _$BatchProfileServer {
  const factory BatchProfileServer({
    required ProfileEntity mother,
    required ProfileEntity father,
    required List<ProfileEntity> children,
    required List<PregnancyEntity> pregnancies,
    required DateTime? motherHpl,
  }) = _BatchProfileServer;
  //factory BatchProfileServer.fromJson(Map<String, dynamic> map) = _BatchProfileServer.fromJson;
  factory BatchProfileServer.fromBioResponse(BioMotherResponse response) {
    final userId = response.user_id;
    final mother = ProfileEntity(
      userId: userId,
      type: DbConst.TYPE_MOTHER,
      serverId: response.id,
      name: response.nama,
      nik: response.nik,
  birthDate: tryParseDate(response.tanggal_lahir) ?? DateTime.fromMillisecondsSinceEpoch(0),
  birthPlace: response.tempat_lahir, // biarkan apa adanya; jika null akan tertangani di layer penggunaan berikutnya
    );
    final rawFather = response.kia_ayah;
    final father = ProfileEntity(
      userId: userId,
      type: DbConst.TYPE_FATHER,
      serverId: rawFather.id,
      name: rawFather.nama,
      nik: rawFather.nik,
  birthDate: tryParseDate(rawFather.tanggal_lahir) ?? DateTime.fromMillisecondsSinceEpoch(0),
  birthPlace: rawFather.tempat_lahir,
    );
    Iterable<BioChildResponse> childrenItr = response.kia_anak;
    //if(filterUnbornChild) { childrenItr = childrenItr.where((e) => e.anak_ke != null); }
    final children = childrenItr.where((e) => !e.is_janin)
        .map<ProfileEntity>((e) {
          // Fallback: backend bisa mengirim null untuk nik/tempat_lahir anak (terutama saat register cepat / janin transition)
          final nik = e.nik ?? '-';
          final birthPlace = e.tempat_lahir ?? 0; // 0 sebagai sentinel unknown
          final birthDate = tryParseDate(e.tanggal_lahir) ?? DateTime.fromMillisecondsSinceEpoch(0);
          return ProfileEntity(
            userId: userId,
            type: DbConst.TYPE_CHILD,
            serverId: e.id,
            name: e.nama,
            nik: nik,
            birthDate: birthDate,
            birthPlace: birthPlace,
          );
        }).toList(growable: false);

    final pregnancies = response.kia_anak.where((e) => e.hpl != null)
        .map<PregnancyEntity>((e) => PregnancyEntity(
      id: e.id,
      credentialId: userId,
      hpl: parseDate(e.hpl)
    )).toList(growable: false);

    final unbornChild = childrenItr.firstWhereOrNull((e) => e.is_janin);
    final hpl = tryParseDate(unbornChild?.hpl);

    return BatchProfileServer(
      mother: mother,
      father: father,
      children: children,
      pregnancies: pregnancies,
      motherHpl: hpl,
    );
  }
}