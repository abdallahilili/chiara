class ShopModel {
  final String id;
  final String name;
  final String ownerId; // 🔹 L'UID du directeur de la boutique
  final List<String>
      userIds; // 🔹 Liste des UID des utilisateurs associés à cette boutique
  final String address;
  final String phoneNumber;
  final DateTime createdAt;

  ShopModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.userIds,
    required this.address,
    required this.phoneNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'userIds': userIds, // 🔹 Liste des utilisateurs liés
      'address': address,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ShopModel.fromMap(Map<String, dynamic> map) {
    return ShopModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      ownerId: map['ownerId'] ?? '',
      userIds: List<String>.from(map['userIds'] ?? []), // 🔹 Désérialisation
      address: map['address'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
