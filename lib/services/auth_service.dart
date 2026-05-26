import 'package:utbktracker/db/db.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  static int? currentUserId;

  Future<bool> login(String email, String password) async {
    try {
      final db = await DB.database;

      final cleanEmail = email.toLowerCase().trim();
      final hashedPassword = _hashPassword(password);

      final result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [cleanEmail, hashedPassword],
      );

      if (result.isNotEmpty) {
        currentUserId = result.first['id'] as int;
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserData(String email) async {
    try {
      final db = await DB.database;
      final result = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.toLowerCase().trim()],
      );

      if (result.isNotEmpty) {
        return result.first;
      }
      return null;
    } catch (e) {
      print('Get user data error: $e');
      return null;
    }
  }

  static int? getCurrentUserId() {
    return currentUserId;
  }

  static void logout() {
    currentUserId = null;
  }

  Future<bool> register(String email, String password) async {
    try {
      final db = await DB.database;

      final cleanEmail = email.toLowerCase().trim();

      final existing = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [cleanEmail],
      );

      if (existing.isNotEmpty) {
        return false;
      }

      final result = await db.insert('users', {
        'email': cleanEmail,
        'password': _hashPassword(password),
      });

      currentUserId = result;
      return true;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }
}
