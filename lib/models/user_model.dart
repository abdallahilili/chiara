class UserModel {
  final String name;
  final String uid;
  final String matricule;
  final String email;
  final String profilePic;
  final bool isOnline;
  final String phoneNumber;
  final String role;
  final DateTime createdAt;
  final String? fcmToken; // 🔹 Ajout du champ fcmToken

  UserModel({
    required this.name,
    required this.uid,
    required this.matricule,
    required this.email,
    required this.profilePic,
    required this.isOnline,
    required this.phoneNumber,
    required this.role,
    required this.createdAt,
    this.fcmToken, // Peut être null si pas encore enregistré
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uid': uid,
      'matricule': matricule,
      'email': email,
      'profilePic': profilePic,
      'isOnline': isOnline,
      'phoneNumber': phoneNumber,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'fcmToken': fcmToken, // 🔹 Ajout dans la sérialisation
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      uid: map['uid'] ?? '',
      matricule: map['matricule'] ?? '',
      email: map['email'] ?? '',
      profilePic: map['profilePic'] ?? '',
      isOnline: map['isOnline'] ?? false,
      phoneNumber: map['phoneNumber'] ?? '',
      role: map['role'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      fcmToken: map['fcmToken'], // 🔹 Désérialisation
    );
  }
}
