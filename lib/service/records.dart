// lib/service/records.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For @immutable

// --- Constants for Firestore field names ---
const String kIdField = 'id';
const String kUserIdField = 'userId';
const String kUserEmailField = 'userEmail';
const String kDeceasedNameField = 'deceasedName';
const String kDeceasedDodField = 'deceasedDod';
const String kDeceasedDobField = 'deceasedDob';
const String kPositionField = 'position';
const String kStateField = 'state';
const String kAreaField = 'area';
const String kCategoryField = 'category';
const String kGraveLotField = 'graveLot';
const String kGraveAddressField = 'graveAddress';
const String kCemeteryNameField = 'cemeteryName';
const String kRelationshipToDeceasedField = 'relationshipToDeceased';
const String kCreatedAtField = 'createdAt';
const String kUpdatedAtField = 'updatedAt';
// --- End Constants ---

@immutable
class Record {
  final String? id;
  final String userId;
  final String? userEmail;
  final String deceasedName;
  final Timestamp? deceasedDod;
  final Timestamp? deceasedDob;
  final GeoPoint? position;
  final String? state;
  final String area;
  final String category;
  final String? graveLot;
  final String? graveAddress;
  final String? cemeteryName;
  final String? relationshipToDeceased;
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  const Record({
    this.id,
    required this.userId,
    this.userEmail,
    required this.deceasedName,
    this.deceasedDod,
    this.deceasedDob,
    this.position,
    this.state,
    required this.area,
    required this.category,
    this.graveLot,
    this.graveAddress,
    this.cemeteryName,
    this.relationshipToDeceased,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      kUserIdField: userId,
      if (userEmail != null && userEmail!.isNotEmpty) kUserEmailField: userEmail,
      kDeceasedNameField: deceasedName,
      if (deceasedDod != null) kDeceasedDodField: deceasedDod,
      if (deceasedDob != null) kDeceasedDobField: deceasedDob,
      if (position != null) kPositionField: position,
      if (state != null && state!.isNotEmpty) kStateField: state,
      kAreaField: area,
      kCategoryField: category,
      if (graveLot != null && graveLot!.isNotEmpty) kGraveLotField: graveLot,
      if (graveAddress != null && graveAddress!.isNotEmpty) kGraveAddressField: graveAddress,
      if (cemeteryName != null && cemeteryName!.isNotEmpty) kCemeteryNameField: cemeteryName,
      if (relationshipToDeceased != null && relationshipToDeceased!.isNotEmpty) kRelationshipToDeceasedField: relationshipToDeceased,
      kCreatedAtField: createdAt,
      if (updatedAt != null) kUpdatedAtField: updatedAt,
    };
  }

  String? get lotNumber => graveLot;

  // This constructor is for reading data from Firestore
  factory Record.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};
    return Record(
      id: snapshot.id,
      userId: data[kUserIdField] as String? ?? '',
      userEmail: data[kUserEmailField] as String?,
      deceasedName: data[kDeceasedNameField] as String? ?? 'Unnamed Record',
      deceasedDod: data[kDeceasedDodField] as Timestamp?,
      deceasedDob: data[kDeceasedDobField] as Timestamp?,
      position: data[kPositionField] as GeoPoint?,
      state: data[kStateField] as String?,
      area: data[kAreaField] as String? ?? 'N/A',
      category: data[kCategoryField] as String? ?? 'Other',
      graveLot: data[kGraveLotField] as String?,
      graveAddress: data[kGraveAddressField] as String?,
      cemeteryName: data[kCemeteryNameField] as String?,
      relationshipToDeceased: data[kRelationshipToDeceasedField] as String?,
      createdAt: data[kCreatedAtField] as Timestamp? ?? Timestamp.now(),
      updatedAt: data[kUpdatedAtField] as Timestamp?,
    );
  }

  // --- NEW CONSTRUCTOR: For creating a Record object from a Map ---
  // This is what we will use in NewRecord.dart before submitting.
  factory Record.fromMap(Map<String, dynamic> data) {
    return Record(
      // id is usually null when creating from a map before it's saved to Firestore
      id: data[kIdField] as String?,
      userId: data[kUserIdField] as String? ?? '',
      userEmail: data[kUserEmailField] as String?,
      deceasedName: data[kDeceasedNameField] as String? ?? 'Unnamed Record',
      deceasedDod: data[kDeceasedDodField] as Timestamp?,
      deceasedDob: data[kDeceasedDobField] as Timestamp?,
      position: data[kPositionField] as GeoPoint?,
      state: data[kStateField] as String?,
      area: data[kAreaField] as String? ?? 'N/A',
      category: data[kCategoryField] as String? ?? 'Other',
      graveLot: data[kGraveLotField] as String?,
      graveAddress: data[kGraveAddressField] as String?,
      cemeteryName: data[kCemeteryNameField] as String?,
      relationshipToDeceased: data[kRelationshipToDeceasedField] as String?,
      // createdAt can be tricky. Assume it's passed in or default.
      createdAt: data[kCreatedAtField] as Timestamp? ?? Timestamp.now(),
      updatedAt: data[kUpdatedAtField] as Timestamp?,
    );
  }

  // Other methods remain the same
  Record copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? deceasedName,
    Timestamp? deceasedDod,
    Timestamp? deceasedDob,
    GeoPoint? position,
    String? state,
    String? area,
    String? category,
    String? graveLot,
    String? graveAddress,
    String? cemeteryName,
    String? relationshipToDeceased,
    Timestamp? createdAt,
    Timestamp? updatedAt, String? email,
  }) {
    return Record(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      deceasedName: deceasedName ?? this.deceasedName,
      deceasedDod: deceasedDod ?? this.deceasedDod,
      deceasedDob: deceasedDob ?? this.deceasedDob,
      position: position ?? this.position,
      state: state ?? this.state,
      area: area ?? this.area,
      category: category ?? this.category,
      graveLot: graveLot ?? this.graveLot,
      graveAddress: graveAddress ?? this.graveAddress,
      cemeteryName: cemeteryName ?? this.cemeteryName,
      relationshipToDeceased: relationshipToDeceased ?? this.relationshipToDeceased,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
@override String toString() { return 'Record(id: $id, deceasedName: $deceasedName)'; }
@override bool operator ==(Object other) { return other is Record && other.id == id; }
@override int get hashCode => id.hashCode;

  static fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {}
}