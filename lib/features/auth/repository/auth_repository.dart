import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myplace/data/models/user_model.dart' as model;

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // After creating the user, create a new document for the user in the 'users' collection
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': '',
        'phone': '',
      });
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<model.User> getUserDetails() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (snap.exists) {
        return model.User.fromSnap(snap);
      } else {
        return model.User(
          uid: currentUser.uid,
          email: currentUser.email ?? '',
          name: '',
          phone: '',
        );
      }
    }
    throw Exception("User not logged in");
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateUserName(String name) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .set({'name': name}, SetOptions(merge: true));
    }
  }

  Future<void> updateUserPhone(String phone) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .set({'phone': phone}, SetOptions(merge: true));
    }
  }

  Future<model.User?> searchUserByPhone(String phone) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return model.User.fromSnap(querySnapshot.docs.first);
    }
    return null;
  }

  Future<void> addFriend(String friendUid) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null && friendUid.isNotEmpty) {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('friends')
          .doc(friendUid)
          .set({});
    }
  }

  Future<List<model.User>> getFriends() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final friendsSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('friends')
          .get();

      final friendUids = friendsSnapshot.docs.map((doc) => doc.id).toList();
      final friendFutures = friendUids.map((uid) async {
        final userDoc = await _firestore.collection('users').doc(uid).get();
        return model.User.fromSnap(userDoc);
      }).toList();

      return await Future.wait(friendFutures);
    }
    return [];
  }
}
