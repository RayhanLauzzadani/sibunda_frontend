import 'package:common/arch/domain/model/auth.dart';
import 'package:common/arch/domain/model/child.dart';
import 'package:common/arch/domain/model/father.dart';
import 'package:common/arch/domain/model/mother.dart';
import 'package:common/util/map_util.dart';
import 'package:common/value/const_values.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_api_model.g.dart';


// ============ Body =============
class RegisterBody {
  final SignUpData signup;
  final Mother? mother;
  final Father? father;
  final List<Child> children;
  final DateTime? motherHpl;

  RegisterBody({
    required this.motherHpl,
    required this.signup,
    required this.mother,
    required this.father,
    required this.children,
  });

  /// This method is a signature that be used by retrofit library to convert it to JSON body.
  Map<String, dynamic> toJson() {
    var signupMap = signup.toJson;
    var motherMap = mother?.toJson;
    var fatherMap = father?.toJson;
    var childMaps = children.map((e) => e.toJson).toList(growable: false);
/*
    motherMap[Const.KEY_SALARY] = motherMap[Const.KEY_SALARY].toString();
    fatherMap[Const.KEY_SALARY] = fatherMap[Const.KEY_SALARY].toString();
    //T ODO: Hilangi dummy
    motherMap[Const.KEY_BIRTH_PLACE] = 1104;
    fatherMap[Const.KEY_BIRTH_PLACE] = 1104;
    childMap[Const.KEY_BIRTH_PLACE] = 1104;
 */

    if(motherMap != null) {
      motherMap = addPrefixToMapKeys(motherMap, "bunda_");
    }
    if(fatherMap != null) {
      fatherMap = addPrefixToMapKeys(fatherMap, "ayah_");
    }

    String _trimDate(val) { if(val is String && val.length >= 10) return val.substring(0,10); return val; }
    void _trimDateInMap(Map<String,dynamic>? m, String key) { if(m != null && m[key] != null) m[key] = _trimDate(m[key]); }
    _trimDateInMap(motherMap, 'tanggal_lahir');
    _trimDateInMap(fatherMap, 'tanggal_lahir');
    for(final c in childMaps) { if(c['tanggal_lahir'] != null) c['tanggal_lahir'] = _trimDate(c['tanggal_lahir']); }
    // Trim possible other date fields (child JKN valid date, pregnancy HPL/HPHT keys if present)
    for(final c in childMaps) {
      final keys = ['tanggal_berlaku_jkn','hpl','hpht'];
      for(final k in keys) { if(c[k] != null) c[k] = _trimDate(c[k]); }
    }

    return <String, dynamic>{
      ...signupMap,
      Const.KEY_RE_PSWD: signup.password,
      if(motherMap != null) ...motherMap,
      if(fatherMap != null) ...fatherMap,
      Const.KEY_CHILD: childMaps,
      if(motherHpl != null) "janin_hpl": _trimDate(motherHpl.toString()),
/*
      Const.KEY_CHILD : [
        childMap,
      ],
 */
    };
  }
}

// ============ Responses =============

@JsonSerializable()
class RegisterResponse extends Equatable {
  final String message;
  final String? status; // nullable for new backend
  final int code;
  final UserResponse? user; // null in new backend minimal response
  final int? userId; // extracted from data.user_id in new backend

  RegisterResponse({
    required this.message,
    required this.code,
    this.status,
    this.user,
    this.userId,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> map) {
    if(map.containsKey('user')) {
      try {
        final legacy = _$RegisterResponseFromJson(map);
        return RegisterResponse(
          message: legacy.message,
          code: legacy.code,
          status: legacy.status,
          user: legacy.user,
          userId: legacy.user?.id,
        );
      } catch(_) {}
    }
    final code = map['code'] is int ? map['code'] as int : int.tryParse('${map['code']}') ?? -1;
    final message = map['message']?.toString() ?? '';
    int? userId;
    final data = map['data'];
    if(data is Map && data['user_id'] != null) {
      userId = data['user_id'] is int ? data['user_id'] as int : int.tryParse('${data['user_id']}');
    }
    return RegisterResponse(
      message: message,
      code: code,
      status: map['status']?.toString(),
      user: null,
      userId: userId,
    );
  }

  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);

  @override
  List<Object?> get props => [code, message, status, user, userId];
}

@JsonSerializable()
class UserResponse extends Equatable {
  final int id;
  final String name;
  final String email;
  @JsonKey(name: Const.KEY_USER_GROUP_ID)
  final int groupId;

  UserResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.groupId,
  });

  factory UserResponse.fromJson(Map<String, dynamic> map) => _$UserResponseFromJson(map);

  @override
  List<Object?> get props => [id, name, email, groupId];
}