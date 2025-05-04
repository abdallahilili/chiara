import 'package:chira/models/prodect_request.dart';

class RequestModel {
  final String id;
  final String vendeurId;
  final List<ProductRequest> produits;
  final DateTime createdAt;

  final String? createdBy; // facultatif : utilisateur qui a créé la demande
  final String? purchaseBy; // facultatif : utilisateur qui va faire l'achat

  final String file; // URL du fichier PDF qui sera envoyé à Supabase
  final String? excelFile; // URL du fichier Excel qui sera envoyé à Supabase

  final String? montant; // montant envoyé pour l'achat
  final String? description; // description de la commande

  RequestModel({
    required this.id,
    required this.vendeurId,
    required this.produits,
    required this.createdAt,
    this.createdBy,
    this.purchaseBy,
    required this.file,
    this.excelFile, // Nouveau champ pour le fichier Excel
    this.montant, // Nouveau champ pour le montant
    this.description, // Nouveau champ pour la description
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendeurId': vendeurId,
      'produits': produits.map((p) => p.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'purchaseBy': purchaseBy,
      'file': file,
      'excelFile': excelFile, // Inclure le champ excelFile
      'montant': montant, // Inclure le champ montant
      'description': description, // Inclure le champ description
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
      file: map['file'] ?? '',
      excelFile: map['excelFile'], // Récupérer le champ excelFile
      montant: map['montant'], // Récupérer le champ montant
      description: map['description'], // Récupérer le champ description
    );
  }
}
