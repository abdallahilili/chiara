import 'package:chira/models/prodect_purchase.dart';

class FreePurchaseModel {
  final String id;
  final String buyerId; // ID de l'acheteur
  final String shopId; // ID de la boutique
  final List<ProductPurchase> products; // Liste des produits achetés
  final double totalAmount; // Montant total de l'achat
  final DateTime createdAt; // Date de création
  final String? description; // Description optionnelle
  final String? notes; // Notes additionnelles
  final String status; // Statut: "completed", "pending", "cancelled"

  FreePurchaseModel({
    required this.id,
    required this.buyerId,
    required this.shopId,
    required this.products,
    required this.totalAmount,
    required this.createdAt,
    this.description,
    this.notes,
    this.status = "completed",
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyerId': buyerId,
      'shopId': shopId,
      'products': products.map((p) => p.toMap()).toList(),
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'notes': notes,
      'status': status,
    };
  }

  factory FreePurchaseModel.fromMap(Map<String, dynamic> map) {
    return FreePurchaseModel(
      id: map['id'] ?? '',
      buyerId: map['buyerId'] ?? '',
      shopId: map['shopId'] ?? '',
      products: (map['products'] as List<dynamic>)
          .map((p) => ProductPurchase.fromMap(p))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      description: map['description'],
      notes: map['notes'],
      status: map['status'] ?? 'completed',
    );
  }

  // Méthode pour calculer le montant total à partir des produits
  static double calculateTotalAmount(List<ProductPurchase> products) {
    return products.fold(0.0, (sum, product) => sum + product.prixTotal);
  }

  // Créer une copie avec des modifications
  FreePurchaseModel copyWith({
    String? id,
    String? buyerId,
    String? shopId,
    List<ProductPurchase>? products,
    double? totalAmount,
    DateTime? createdAt,
    String? description,
    String? notes,
    String? status,
  }) {
    return FreePurchaseModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      shopId: shopId ?? this.shopId,
      products: products ?? this.products,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }
}