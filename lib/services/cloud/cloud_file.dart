import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studieapp/services/cloud/cloud_storage_constants.dart';

@immutable
class CloudFile {
  final int userId;
  final String title;
  final String subject;
  final String description;
  final String content;
  final String type;
  // final String cloudId;

  const CloudFile({
    required this.userId,
    required this.title,
    required this.subject,
    required this.description,
    required this.content,
    required this.type,
    // required this.cloudId,
  });

  CloudFile.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : assert(snapshot.data() != null, 'Document data is null'),
        userId = snapshot.data()![ownerUserIdFieldName],
        title = snapshot.data()![titleFieldName],
        subject = snapshot.data()![subjectFieldName],
        description = snapshot.data()![descriptionFieldName],
        content = snapshot.data()![contentFieldName],
        type = snapshot.data()![typeFieldName];
  // cloudId = snapshot.id,
}
