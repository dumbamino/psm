// lib/service/firestore.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:psm/service/records.dart'; // Ensure this path is correct

const String kCollectionRecords = 'records'; // Use a constant for the collection name

class RecordFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// --- FIXED ---
  /// Adds a new record to Firestore. This method now accepts a Map, which resolves the type error.
  Future<void> addRecord(Map<String, dynamic> recordData) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("User not authenticated. Cannot add record.");
    }

    // The data map should already contain all necessary fields from NewRecordScreen,
    // including the generated searchKeywords. We just add the server timestamps.
    recordData[kCreatedAtField] = FieldValue.serverTimestamp();
    recordData[kUpdatedAtField] = FieldValue.serverTimestamp();

    // Ensure userId is present, which is added in NewRecordScreen
    if (recordData[kUserIdField] != currentUser.uid) {
      throw Exception("Data integrity error: userId in record does not match current user.");
    }

    try {
      await _firestore.collection(kCollectionRecords).add(recordData);
      print("[Service.addRecord] Record successfully ADDED to Firestore.");
    } catch (e, s) {
      print("[Service.addRecord] FIRESTORE ERROR while adding record: $e\n$s");
      throw Exception("Service Error: Failed to save record to database: $e");
    }
  }

  /// Updates an existing record in Firestore.
  /// This method correctly handles the 'searchKeywords' field because it's passed in the 'dataToUpdate' map.
  Future<void> updateRecord(String recordId, Map<String, dynamic> dataToUpdate) async {
    if (recordId.isEmpty) {
      throw ArgumentError("Record ID cannot be empty for update.");
    }

    // Prepare the final map for update.
    final Map<String, dynamic> finalDataToUpdate = {
      ...dataToUpdate,
      kUpdatedAtField: FieldValue.serverTimestamp(),
    };

    // Protect critical fields from being accidentally changed during an update.
    finalDataToUpdate.remove(kUserIdField);
    finalDataToUpdate.remove(kCreatedAtField);
    finalDataToUpdate.remove(kIdField); // Not a field in Firestore doc anyway

    try {
      await _firestore.collection(kCollectionRecords).doc(recordId).update(finalDataToUpdate);
      print("[Service.updateRecord] Record successfully UPDATED in Firestore.");
    } catch (e, s) {
      print("[Service.updateRecord] ERROR updating record $recordId: $e\n$s");
      throw Exception("Failed to update record. Please try again. ($e)");
    }
  }

  /// Deletes a record from Firestore.
  Future<void> deleteRecord(String recordId) async {
    if (recordId.isEmpty) {
      throw ArgumentError("Record ID cannot be empty for deletion.");
    }
    try {
      await _firestore.collection(kCollectionRecords).doc(recordId).delete();
      print("[Service.deleteRecord] Record $recordId successfully DELETED.");
    } catch (e,s) {
      print("[Service.deleteRecord] ERROR deleting record $recordId: $e\n$s");
      throw Exception("Failed to delete record. Please try again. ($e)");
    }
  }

  /// --- FIXED ---
  /// Gets a real-time stream of records for a specific user.
  /// Now correctly calls `Record.fromSnapshot`.
  Stream<List<Record>> getRecordsForUser(String userId) {
    if (userId.isEmpty) {
      print("[Service.getRecordsForUser] Warning: Called with empty userId. Returning empty stream.");
      return Stream.value([]);
    }

    // This query is allowed by the recommended security rules.
    return _firestore
        .collection(kCollectionRecords)
        .where(kUserIdField, isEqualTo: userId)
        .orderBy(kCreatedAtField, descending: true)
        .snapshots()
        .map((querySnapshot) {
      try {
        final records = querySnapshot.docs.map((doc) {
          try {
            // Correctly call the fromSnapshot factory constructor
            return Record.fromSnapshot(doc);
          } catch (e, s) {
            print("[Service.getRecordsForUser] Error parsing ONE document (${doc.id}) to Record: $e\n$s");
            return null; // Skip this problematic document
          }
        }).whereType<Record>().toList(); // Filter out any nulls from parsing errors

        print("[Service.getRecordsForUser] Stream updated with ${records.length} records for user $userId.");
        return records;
      } catch (e, s) {
        print("[Service.getRecordsForUser] Error mapping query snapshot to List<Record>: $e\n$s");
        return []; // Return empty list on major parsing error
      }
    });
  }

  /// Searches records for a specific user by exact Date of Death.
  Future<List<Record>> searchRecordsByDateForUser(String userId, DateTime date) async {
    if (userId.isEmpty) return [];

    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    try {
      final snapshot = await _firestore
          .collection(kCollectionRecords)
          .where(kUserIdField, isEqualTo: userId)
          .where(kDeceasedDodField, isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where(kDeceasedDodField, isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy(kDeceasedDodField)
          .limit(20)
          .get();

      return snapshot.docs.map<Record?>((doc) {
        try {
          return Record.fromSnapshot(doc);
        } catch (e) {
          print("[Service.searchRecordsByDateForUser] Skipping doc ${doc.id} due to parse error: $e");
          return null;
        }
      }).whereType<Record>().toList();
    } catch (e, s) {
      print("[Service.searchRecordsByDateForUser] Error querying records: $e\n$s");
      return [];
    }
  }
}