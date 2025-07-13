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
  List<model.User> _friendRequests = [];
  List<model.User> get friendRequests => _friendRequests;

  Future<void> loadCurrentUser() async {
    try {
      _user = await _authRepository.getUserDetails();
      await getFriends();
      await getFriendRequests();
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

  Future<void> sendFriendRequest(String receiverId) async {
    await _authRepository.sendFriendRequest(receiverId);
  }

  Future<void> acceptFriendRequest(String requesterId) async {
    await _authRepository.acceptFriendRequest(requesterId);
    await getFriends();
    await getFriendRequests();
  }

  Future<void> declineFriendRequest(String requesterId) async {
    await _authRepository.declineFriendRequest(requesterId);
    await getFriendRequests();
  }

  Future<void> getFriendRequests() async {
    _friendRequests = await _authRepository.getFriendRequests();
    notifyListeners();
  }

  Future<void> getFriends() async {
    _friends = await _authRepository.getFriends();
    notifyListeners();
  }
}
