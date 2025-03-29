class UserModel {
  final String name;
  final String uid;
  final String shopId; // 🔹 Identifiant de la boutique
  final String email;
  final String profilePic;
  final bool isActive;
  final String phoneNumber;
  final String role; // Peut être "directeur" ou "employé"
  final String jobType; // 🔹 Ajout : "vendeur" ou "acheteur"
  final DateTime createdAt;
  final String? fcmToken;

  UserModel({
    required this.name,
    required this.uid,
    required this.shopId,
    required this.email,
    required this.profilePic,
    required this.isActive,
    required this.phoneNumber,
    required this.role,
    required this.jobType, // 🔹 Nouvelle propriété
    required this.createdAt,
    this.fcmToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uid': uid,
      'shopId': shopId,
      'email': email,
      'profilePic': profilePic,
      'isActive': isActive,
      'phoneNumber': phoneNumber,
      'role': role,
      'jobType': jobType, // 🔹 Stocker "vendeur" ou "acheteur"
      'createdAt': createdAt.toIso8601String(),
      'fcmToken': fcmToken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      uid: map['uid'] ?? '',
      shopId: map['shopId'] ?? '',
      email: map['email'] ?? '',
      profilePic: map['profilePic'] ?? '',
      isActive: map['isActive'] ?? false,
      phoneNumber: map['phoneNumber'] ?? '',
      role: map['role'] ?? '',
      jobType: map['jobType'] ?? '', // 🔹 Désérialisation
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      fcmToken: map['fcmToken'],
    );
  }
}
