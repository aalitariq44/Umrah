import 'package:flutter/material.dart';
import 'package:myplace/data/models/user_model.dart' as model;
import 'package:myplace/features/auth/repository/auth_repository.dart';

class AuthController with ChangeNotifier {
  final AuthRepository _authRepository;
  model.User? _user;

  AuthController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  model.User? get user => _user;
  List<model.User> _friends = [];
  List<model.User> get friends => _friends;

  Future<void> loadCurrentUser() async {
    try {
      _user = await _authRepository.getUserDetails();
      await getFriends();
      notifyListeners();
    } catch (e) {
      // Handle exceptions, e.g., user not found or network error
      print('Error loading current user: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
      _user = await _authRepository.getUserDetails();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _authRepository.signUpWithEmailAndPassword(email, password);
      _user = await _authRepository.getUserDetails();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    await _authRepository.updateUserName(name);
    _user = await _authRepository.getUserDetails();
    notifyListeners();
  }

  Future<void> updateUserPhone(String phone) async {
    await _authRepository.updateUserPhone(phone);
    _user = await _authRepository.getUserDetails();
    notifyListeners();
  }

  Future<model.User?> searchUserByPhone(String phone) async {
    return await _authRepository.searchUserByPhone(phone);
  }

  Future<void> addFriend(String friendUid) async {
    await _authRepository.addFriend(friendUid);
    await getFriends(); // Refresh the friends list
  }

  Future<void> getFriends() async {
    _friends = await _authRepository.getFriends();
    notifyListeners();
  }
}
