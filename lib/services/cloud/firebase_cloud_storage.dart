import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studieapp/models/file.dart';
import 'package:studieapp/services/cloud/cloud_file.dart';
import 'package:studieapp/services/cloud/cloud_storage_constants.dart';
import 'package:studieapp/services/cloud/cloud_storage_exceptions.dart';
import 'package:studieapp/services/local/local_service.dart';

class FirebaseCloudStorage {
  final files = FirebaseFirestore.instance.collection('files');

  // Future<void> deleteNote({required String documentId}) async {
  //   try {
  //     await notes.doc(documentId).delete();
  //   } catch (e) {
  //     throw CouldNotDeleteNoteException();
  //   }
  // }

  // Future<void> updateNote({
  //   required String documentId,
  //   required String text,
  // }) async {
  //   try {
  //     notes.doc(documentId).update({textFieldName: text});
  //   } catch (e) {
  //     throw CouldNotUpdateNoteException();
  //   }
  // }

  // Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
  //     notes.snapshots().map((event) => event.docs
  //         .map((doc) => CloudNote.fromSnapshot(doc))
  //         .where((note) => note.ownerUserId == ownerUserId));

  // Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
  //   try {
  //     return await notes
  //         .where(
  //           ownerUserIdFieldName,
  //           isEqualTo: ownerUserId,
  //         )
  //         .get()
  //         .then(
  //           (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)),
  //         );
  //   } catch (e) {
  //     throw CouldNotGetAllNotesException();
  //   }
  // }

  // Future<CloudNote> createNewNote({required String ownerUserId}) async {
  //   final document = await notes.add({
  //     ownerUserIdFieldName: ownerUserId,
  //     textFieldName: '',
  //   });
  //   final fetchedNote = await document.get();
  //   return CloudNote(
  //     documentId: fetchedNote.id,
  //     ownerUserId: ownerUserId,
  //     text: '',
  //   );
  // }

  // createUser

  // getUser

  // updateUser

  // deleteUser

  // getFile
  Future<CloudFile> downloadFile({required String cloudId}) async {
    try {
      if (cloudId.isEmpty) throw ArgumentError('cloudId must not be empty');

      final file = await files.doc(cloudId).get();

      return CloudFile.fromSnapshot(file);
    } catch (e) {
      throw CouldNotGetFileException();
    }
  }

  // publishFile
  Future<void> uploadOrUpdateFile({required File file}) async {
    try {
      print(file.cloudId);
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
        return;
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
        return;
      }
    } catch (e) {
      throw CouldNotUploadOrUpdateFileException();
    }
  }

  // deleteFile
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
