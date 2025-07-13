import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;
  final String name;
  final String phone;

  const User({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'name': name,
        'phone': phone,
      };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return User(
      uid: snapshot['uid'] ?? '',
      email: snapshot['email'] ?? '',
      name: snapshot['name'] ?? '',
      phone: snapshot['phone'] ?? '',
    );
  }
}
