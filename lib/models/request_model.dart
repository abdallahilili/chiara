import 'package:chira/models/prodect_request.dart';

class RequestModel {
  final String id;
  final String vendeurId;
  final List<ProductRequest> produits;
  final DateTime createdAt;

  RequestModel({
    required this.id,
    required this.vendeurId,
    required this.produits,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendeurId': vendeurId,
      'produits': produits.map((p) => p.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      id: map['id'] ?? '',
      vendeurId: map['vendeurId'] ?? '',
      produits: (map['produits'] as List<dynamic>)
          .map((p) => ProductRequest.fromMap(p))
          .toList(),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
