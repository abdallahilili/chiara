class ProductPurchase {
  final String nom;
  final int quantite;
  final double prixUnitaire;
  final double prixTotal;

  ProductPurchase({
    required this.nom,
    required this.quantite,
    required this.prixUnitaire,
  }) : prixTotal = quantite * prixUnitaire;

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'quantite': quantite,
      'prixUnitaire': prixUnitaire,
      'prixTotal': prixTotal,
    };
  }

  factory ProductPurchase.fromMap(Map<String, dynamic> map) {
    return ProductPurchase(
      nom: map['nom'] ?? '',
      quantite: map['quantite'] ?? 0,
      prixUnitaire: (map['prixUnitaire'] ?? 0).toDouble(),
    );
  }
}
