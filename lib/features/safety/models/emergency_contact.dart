class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String? photoPath;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.photoPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'photoPath': photoPath,
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      photoPath: json['photoPath'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmergencyContact && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
