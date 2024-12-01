import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:studieapp/services/cloud/cloud_storage_constants.dart';

@immutable
class DataUser {
  final String userId;
  final String displayName;
  final int experiencePoints;
  final int streak;
  final int studySessions;
  final DateTime lastAppOpened;

  const DataUser({
    required this.userId,
    required this.displayName,
    required this.experiencePoints,
    required this.streak,
    required this.studySessions,
    required this.lastAppOpened,
  });

  DataUser.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : userId = snapshot.id,
        displayName = snapshot.data()[displayNameFieldName],
        experiencePoints = snapshot.data()[experiencePointsFieldName],
        streak = snapshot.data()[streakFieldName],
        studySessions = snapshot.data()[studySessionsFieldName],
        lastAppOpened = snapshot.data()[lastAppOpenedFieldName];
}
