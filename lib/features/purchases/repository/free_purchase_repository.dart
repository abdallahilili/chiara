import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:chira/models/purchase_model.dart';
import 'package:chira/models/prodect_purchase.dart';

class FreePurchaseRepository {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final _uuid = Uuid();

  /// Créer un nouvel achat libre
  static Future<String> createFreePurchase({
    required String shopId,
    required List<Map<String, dynamic>> products,
    String? description,
    String? notes,
  }) async {
    try {
      final String purchaseId = _uuid.v4();
      final String? currentUserId = _auth.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception("Utilisateur non authentifié");
      }

      // Convertir les produits en format ProductPurchase
      List<ProductPurchase> purchaseProducts = products.map((product) {
        return ProductPurchase(
          nom: product['product'],
          quantite: (product['quantity'] as double).toInt(),
          prixUnitaire: product['unitPrice'] as double,
        );
      }).toList();

      // Calculer le montant total
      double totalAmount = FreePurchaseModel.calculateTotalAmount(purchaseProducts);

      // Créer le modèle d'achat libre
      final freePurchase = FreePurchaseModel(
        id: purchaseId,
        buyerId: currentUserId,
        shopId: shopId,
        products: purchaseProducts,
        totalAmount: totalAmount,
        createdAt: DateTime.now(),
        description: description,
        notes: notes,
        status: 'completed',
      );

      // Enregistrer dans Firestore
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('free_purchases')
          .doc(purchaseId)
          .set(freePurchase.toMap());

      return purchaseId;
    } catch (e) {
      print('Erreur lors de la création de l\'achat libre: $e');
      throw Exception("Échec de l'enregistrement de l'achat libre: $e");
    }
  }

  /// Obtenir tous les achats libres d'une boutique
  static Stream<List<FreePurchaseModel>> getShopFreePurchases(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('free_purchases')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FreePurchaseModel.fromMap(doc.data());
      }).toList();
    });
  }

  /// Obtenir les achats libres créés par un utilisateur spécifique
  static Stream<List<FreePurchaseModel>> getUserFreePurchases({
    required String shopId,
    required String userId,
  }) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('free_purchases')
        .where('buyerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FreePurchaseModel.fromMap(doc.data());
      }).toList();
    });
  }

  /// Obtenir un achat libre spécifique par son ID
  static Future<FreePurchaseModel?> getFreePurchaseById({
    required String shopId,
    required String purchaseId,
  }) async {
    try {
      final doc = await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('free_purchases')
          .doc(purchaseId)
          .get();

      if (doc.exists) {
        return FreePurchaseModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'achat libre: $e');
      return null;
    }
  }

  /// Mettre à jour un achat libre
  static Future<void> updateFreePurchase({
    required String shopId,
    required String purchaseId,
    String? description,
    String? notes,
    String? status,
    List<ProductPurchase>? products,
  }) async {
    try {
      Map<String, dynamic> updateData = {};

      if (description != null) updateData['description'] = description;
      if (notes != null) updateData['notes'] = notes;
      if (status != null) updateData['status'] = status;
      
      if (products != null) {
        updateData['products'] = products.map((p) => p.toMap()).toList();
        updateData['totalAmount'] = FreePurchaseModel.calculateTotalAmount(products);
      }

      if (updateData.isNotEmpty) {
        await _firestore
            .collection('shops')
            .doc(shopId)
            .collection('free_purchases')
            .doc(purchaseId)
            .update(updateData);
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'achat libre: $e');
      throw Exception("Échec de la mise à jour de l'achat libre: $e");
    }
  }

  /// Supprimer un achat libre
  static Future<void> deleteFreePurchase({
    required String shopId,
    required String purchaseId,
  }) async {
    try {
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('free_purchases')
          .doc(purchaseId)
          .delete();
    } catch (e) {
      print('Erreur lors de la suppression de l\'achat libre: $e');
      throw Exception("Échec de la suppression de l'achat libre: $e");
    }
  }

  /// Obtenir les statistiques d'achats libres pour une période donnée
  static Future<Map<String, dynamic>> getFreePurchaseStats({
    required String shopId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection('shops')
          .doc(shopId)
          .collection('free_purchases');

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: endDate.toIso8601String());
      }

      final snapshot = await query.get();
      
      double totalAmount = 0.0;
      int totalPurchases = snapshot.docs.length;
      Map<String, int> productCounts = {};

      for (var doc in snapshot.docs) {
        final purchase = FreePurchaseModel.fromMap(doc.data() as Map<String, dynamic>);
        totalAmount += purchase.totalAmount;
        
        for (var product in purchase.products) {
          productCounts[product.nom] = (productCounts[product.nom] ?? 0) + product.quantite;
        }
      }

      return {
        'totalAmount': totalAmount,
        'totalPurchases': totalPurchases,
        'averageAmount': totalPurchases > 0 ? totalAmount / totalPurchases : 0.0,
        'productCounts': productCounts,
      };
    } catch (e) {
      print('Erreur lors du calcul des statistiques: $e');
      return {
        'totalAmount': 0.0,
        'totalPurchases': 0,
        'averageAmount': 0.0,
        'productCounts': <String, int>{},
      };
    }
  }
}