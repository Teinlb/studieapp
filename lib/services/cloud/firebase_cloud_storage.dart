import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/services/cloud/cloud_file.dart';
import 'package:studieapp/services/cloud/cloud_storage_constants.dart';
import 'package:studieapp/services/cloud/cloud_storage_exceptions.dart';
import 'package:studieapp/services/local/local_service.dart';

class FirebaseCloudStorage {
  final files = FirebaseFirestore.instance.collection('files');

  // Haal gefilterde bestanden op
  Future<List<CloudFile>> fetchFilteredFiles({
    String? title,
    String? subject,
    String? fileType,
  }) async {
    try {
      print('Filters: title=$title, subject=$subject, fileType=$fileType');
      Query<Map<String, dynamic>> query = files;

      if (title != null && title.isNotEmpty) {
        query = query
            .where(titleFieldName, isGreaterThanOrEqualTo: title)
            .where(titleFieldName, isLessThanOrEqualTo: "$title\uf8ff");
      }
      if (subject != null && subject.isNotEmpty) {
        query = query.where(subjectFieldName, isEqualTo: subject);
      }
      if (fileType != null && fileType.isNotEmpty) {
        query = query.where(typeFieldName, isEqualTo: fileType);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => CloudFile.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error in fetchFilteredFiles: $e');
      throw CouldNotFetchFilteredFilesException();
    }
  }

  // Download een bestand
  Future<CloudFile> downloadFile({required String cloudId}) async {
    try {
      if (cloudId.isEmpty) throw ArgumentError('cloudId must not be empty');

      final file = await files.doc(cloudId).get();

      return CloudFile.fromSnapshot(file);
    } catch (e) {
      throw CouldNotGetFileException();
    }
  }

  // Upload of update een bestand
  Future<void> uploadOrUpdateFile({required File file}) async {
    try {
      if (file.cloudId != null && file.cloudId!.isNotEmpty) {
        // Document bestaat al, update het
        final updatedData = {
          ownerUserIdFieldName: file.userId,
          titleFieldName: file.title,
          subjectFieldName: file.subject,
          descriptionFieldName: file.description,
          contentFieldName: file.content,
          typeFieldName: file.type,
        };

        await files.doc(file.cloudId).update(updatedData);
      } else {
        // Document bestaat nog niet, maak een nieuw aan
        final document = await files.add({
          ownerUserIdFieldName: file.userId,
          titleFieldName: file.title,
          subjectFieldName: file.subject,
          descriptionFieldName: file.description,
          contentFieldName: file.content,
          typeFieldName: file.type,
        });
        LocalService().updateCloudIdFile(id: file.id, cloudId: document.id);
      }
    } catch (e) {
      throw CouldNotUploadOrUpdateFileException();
    }
  }

  // Verwijder een bestand
  Future<void> deleteFile({required String cloudId}) async {
    try {
      await files.doc(cloudId).delete();
    } catch (e) {
      throw CouldNotDeleteFileException();
    }
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}



// createUser

// getUser

// updateUser

// deleteUser