import 'package:flutter/material.dart';
import 'package:myplace/data/models/user_model.dart' as model;
import 'package:myplace/features/auth/repository/auth_repository.dart';

class AuthController with ChangeNotifier {
  final AuthRepository _authRepository;
  model.User? _user;

  AuthController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  model.User? get user => _user;

  Future<void> signIn(String email, String password) async {
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
      _user = await _authRepository.getUserDetails();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
