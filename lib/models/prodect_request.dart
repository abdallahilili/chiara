class ProductRequest {
  final String nom;
  final int quantite;
  final String unite;
  final String etat; // "en attente", "acheté", "indisponible"

  ProductRequest({
    required this.nom,
    required this.quantite,
    required this.unite,
    required this.etat,
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'quantite': quantite,
      'unite': unite,
      'etat': etat,
    };
  }

  factory ProductRequest.fromMap(Map<String, dynamic> map) {
    return ProductRequest(
      nom: map['nom'] ?? '',
      quantite: map['quantite'] ?? 0,
      unite: map['unite'] ?? '',
      etat: map['etat'] ?? 'en attente',
    );
  }
}
