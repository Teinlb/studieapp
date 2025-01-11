import 'dart:async';
import 'package:flutter/material.dart';

import 'package:studieapp/services/auth/auth_service.dart';
import 'package:studieapp/services/local/database_service.dart';
import 'package:studieapp/services/local/local_constants.dart';
import 'package:studieapp/services/local/local_exceptions.dart';

class UserService {
  final DatabaseService _databaseService = DatabaseService();

  static final UserService _shared = UserService._sharedInstance();
  UserService._sharedInstance();
  factory UserService() => _shared;

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);

      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = await _databaseService.database;

    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = await _databaseService.database;

    // Haal de huidige gebruiker op vanuit Firebase Auth
    final firebaseUser = AuthService.firebase().currentUser;
    if (firebaseUser == null) {
      throw UserNotLoggedIn(); // Definieer deze fout indien nodig
    }

    final firebaseUserId = firebaseUser.id;

    // Controleer of de gebruiker al in de SQLite-tabel bestaat
    final results = await db.query(
      userTable,
      limit: 1,
      where: '$idColumn = ?',
      whereArgs: [firebaseUserId],
    );

    if (results.isNotEmpty) {
      throw UserAlreadyExists(); // Definieer deze fout indien nodig
    }

    await db.insert(userTable, {
      idColumn: firebaseUserId,
      emailColumn: email.toLowerCase(),
      usernameColumn: 'anonymous',
      experienceColumn: 0,
      openTimeColumn: DateTime.now().toIso8601String(),
      streakColumn: 0,
      sessionsColumn: 0,
    });

    return DatabaseUser(
      id: firebaseUserId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    final db = await _databaseService.database;

    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }
}

@immutable
class DatabaseUser {
  final String id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as String,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
