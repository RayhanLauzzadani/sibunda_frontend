import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final DateTime? birthDate;
  final String? gender; // 'perempuan' or 'laki-laki'
  final bool isPregnant;
  final DateTime? pregnancyStartDate;
  final int? pregnancyWeek;
  final List<String>? childrenIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.birthDate,
    this.gender,
    this.isPregnant = false,
    this.pregnancyStartDate,
    this.pregnancyWeek,
    this.childrenIds,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create UserModel from Firebase User (initial creation)
  factory UserModel.fromFirebaseUser({
    required String uid,
    required String email,
    String? displayName,
    String? photoURL,
  }) {
    final now = DateTime.now();
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      phoneNumber: data['phoneNumber'],
      birthDate: data['birthDate'] != null
          ? (data['birthDate'] as Timestamp).toDate()
          : null,
      gender: data['gender'],
      isPregnant: data['isPregnant'] ?? false,
      pregnancyStartDate: data['pregnancyStartDate'] != null
          ? (data['pregnancyStartDate'] as Timestamp).toDate()
          : null,
      pregnancyWeek: data['pregnancyWeek'],
      childrenIds: data['childrenIds'] != null
          ? List<String>.from(data['childrenIds'])
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Create UserModel from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      phoneNumber: json['phoneNumber'],
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : null,
      gender: json['gender'],
      isPregnant: json['isPregnant'] ?? false,
      pregnancyStartDate: json['pregnancyStartDate'] != null
          ? DateTime.parse(json['pregnancyStartDate'])
          : null,
      pregnancyWeek: json['pregnancyWeek'],
      childrenIds: json['childrenIds'] != null
          ? List<String>.from(json['childrenIds'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  /// Convert to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'gender': gender,
      'isPregnant': isPregnant,
      'pregnancyStartDate': pregnancyStartDate != null
          ? Timestamp.fromDate(pregnancyStartDate!)
          : null,
      'pregnancyWeek': pregnancyWeek,
      'childrenIds': childrenIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'isPregnant': isPregnant,
      'pregnancyStartDate': pregnancyStartDate?.toIso8601String(),
      'pregnancyWeek': pregnancyWeek,
      'childrenIds': childrenIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Copy with method for updating fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    DateTime? birthDate,
    String? gender,
    bool? isPregnant,
    DateTime? pregnancyStartDate,
    int? pregnancyWeek,
    List<String>? childrenIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      isPregnant: isPregnant ?? this.isPregnant,
      pregnancyStartDate: pregnancyStartDate ?? this.pregnancyStartDate,
      pregnancyWeek: pregnancyWeek ?? this.pregnancyWeek,
      childrenIds: childrenIds ?? this.childrenIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get user's age
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// Check if user profile is complete
  bool get isProfileComplete {
    return displayName != null &&
        phoneNumber != null &&
        birthDate != null &&
        gender != null;
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, isPregnant: $isPregnant)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.uid == uid && other.email == email;
  }

  @override
  int get hashCode => uid.hashCode ^ email.hashCode;
}
