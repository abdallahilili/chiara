import 'package:chira/models/prodect_request.dart';

class RequestModel {
  final String id;
  final String vendeurId;
  final List<ProductRequest> produits;
  final DateTime createdAt;

  final String? createdBy; // facultatif : utilisateur qui a créé la demande
  final String? purchaseBy; // facultatif : utilisateur qui a acheté

  final String
      file; // ✅ URL du fichier qui sera envoyé à Supabase et contient list de produits

  RequestModel({
    required this.id,
    required this.vendeurId,
    required this.produits,
    required this.createdAt,
    this.createdBy,
    this.purchaseBy,
    required this.file, // ✅ Nouveau champ requis
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendeurId': vendeurId,
      'produits': produits.map((p) => p.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'purchaseBy': purchaseBy,
      'file': file, // ✅ Inclure le champ file dans la conversion en Map
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
      createdBy: map['createdBy'],
      purchaseBy: map['purchaseBy'],
      file: map['file'] ??
          '', // ✅ Inclure le champ file dans la conversion depuis Map
    );
  }
}
