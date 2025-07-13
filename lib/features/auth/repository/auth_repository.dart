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

  Future<void> sendFriendRequest(String receiverId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null && receiverId.isNotEmpty) {
      // Add receiver to sender's sent requests
      await _firestore.collection('users').doc(currentUser.uid).set({
        'friend_requests_sent': FieldValue.arrayUnion([receiverId])
      }, SetOptions(merge: true));

      // Add sender to receiver's received requests
      await _firestore.collection('users').doc(receiverId).set({
        'friend_requests_received': FieldValue.arrayUnion([currentUser.uid])
      }, SetOptions(merge: true));
    }
  }

  Future<void> acceptFriendRequest(String requesterId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null && requesterId.isNotEmpty) {
      // Add each other to friends list
      await _firestore.collection('users').doc(currentUser.uid).set({
        'friends': FieldValue.arrayUnion([requesterId])
      }, SetOptions(merge: true));
      await _firestore.collection('users').doc(requesterId).set({
        'friends': FieldValue.arrayUnion([currentUser.uid])
      }, SetOptions(merge: true));

      // Remove from requests lists
      await _firestore.collection('users').doc(currentUser.uid).update({
        'friend_requests_received': FieldValue.arrayRemove([requesterId])
      });
      await _firestore.collection('users').doc(requesterId).update({
        'friend_requests_sent': FieldValue.arrayRemove([currentUser.uid])
      });
    }
  }

  Future<void> declineFriendRequest(String requesterId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null && requesterId.isNotEmpty) {
      await _firestore.collection('users').doc(currentUser.uid).update({
        'friend_requests_received': FieldValue.arrayRemove([requesterId])
      });
    }
  }

  Future<List<model.User>> getFriendRequests() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      final userData = userDoc.data();
      if (userData != null && userData['friend_requests_received'] is List) {
        final requesterUids =
            List<String>.from(userData['friend_requests_received']);
        if (requesterUids.isEmpty) {
          return [];
        }
        final requesterDocs = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: requesterUids)
            .get();
        return requesterDocs.docs
            .map((doc) => model.User.fromSnap(doc))
            .toList();
      }
    }
    return [];
  }

  Future<List<model.User>> getFriends() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      final userData = userDoc.data();
      if (userData != null && userData['friends'] is List) {
        final friendUids = List<String>.from(userData['friends']);
        if (friendUids.isEmpty) {
          return [];
        }
        final friendDocs = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: friendUids)
            .get();
        return friendDocs.docs
            .map((doc) => model.User.fromSnap(doc))
            .toList();
      }
    }
    return [];
  }
}
