import 'package:chira/features/purchases/repository/free_purchase_repository.dart';
import 'package:chira/models/purchase_model.dart';
import 'package:chira/models/prodect_purchase.dart';
import 'package:get/get.dart';

class PurchasesController extends GetxController {
  // Variables réactives pour la gestion de l'état
  var isLoading = false.obs;
  var addedProducts = <Map<String, dynamic>>[].obs;
  var freePurchases = <FreePurchaseModel>[].obs;
  var userFreePurchases = <FreePurchaseModel>[].obs;
  var totalAmount = 0.0.obs;
  var showTotalPriceField = false.obs;
  var errorMessage = ''.obs;
  var purchaseStats = <String, dynamic>{}.obs;

  // Gestion des produits
  void addProduct({
    required String product,
    required double quantity,
    required double unitPrice,
    required double totalPrice,
  }) {
    addedProducts.add({
      'product': product,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    });
    calculateTotalAmount();
  }

  void updateProduct(
    int index, {
    required String product,
    required double quantity,
    required double unitPrice,
    required double totalPrice,
  }) {
    if (index >= 0 && index < addedProducts.length) {
      addedProducts[index] = {
        'product': product,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
      };
      calculateTotalAmount();
    }
  }

  void removeProduct(int index) {
    if (index >= 0 && index < addedProducts.length) {
      addedProducts.removeAt(index);
      calculateTotalAmount();
    }
  }

  void clearProducts() {
    addedProducts.clear();
    totalAmount.value = 0.0;
  }

  // Calculer le montant total
  void calculateTotalAmount() {
    totalAmount.value = addedProducts.fold(0.0, (sum, product) {
      return sum + (product['totalPrice'] as double);
    });
  }

  // Basculer entre prix unitaire et prix total
  void togglePriceField() {
    showTotalPriceField.value = !showTotalPriceField.value;
  }

  // Calculer le prix unitaire à partir du prix total
  double calculateUnitPrice(double totalPrice, double quantity) {
    return quantity != 0 ? totalPrice / quantity : 0;
  }

  // Calculer le prix total à partir du prix unitaire
  double calculateTotalPrice(double unitPrice, double quantity) {
    return unitPrice * quantity;
  }

  // Créer un achat libre
  Future<bool> createFreePurchase({
    required String shopId,
    String? description,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (addedProducts.isEmpty) {
        errorMessage.value = 'يرجى إضافة منتج واحد على الأقل';
        return false;
      }

      await FreePurchaseRepository.createFreePurchase(
        shopId: shopId,
        products: addedProducts,
        description: description,
        notes: notes,
      );

      // Rafraîchir la liste des achats après création
      await fetchShopFreePurchases(shopId);

      // Réinitialiser le formulaire après succès
      resetForm();

      return true;
    } catch (e) {
      errorMessage.value =
          'Erreur lors de la création de l\'achat: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Récupérer tous les achats libres d'une boutique
  Future<void> fetchShopFreePurchases(String shopId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      FreePurchaseRepository.getShopFreePurchases(shopId).listen(
        (purchases) {
          freePurchases.value = purchases;
        },
        onError: (error) {
          errorMessage.value =
              'Erreur lors de la récupération des achats: ${error.toString()}';
        },
      );
    } catch (e) {
      errorMessage.value =
          'Erreur lors de la récupération des achats: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Récupérer les achats libres d'un utilisateur
  Future<void> fetchUserFreePurchases({
    required String shopId,
    required String userId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      FreePurchaseRepository.getUserFreePurchases(
        shopId: shopId,
        userId: userId,
      ).listen(
        (purchases) {
          userFreePurchases.value = purchases;
        },
        onError: (error) {
          errorMessage.value =
              'Erreur lors de la récupération des achats utilisateur: ${error.toString()}';
        },
      );
    } catch (e) {
      errorMessage.value =
          'Erreur lors de la récupération des achats utilisateur: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Récupérer un achat libre par son ID
  Future<FreePurchaseModel?> getFreePurchaseById({
    required String shopId,
    required String purchaseId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final purchase = await FreePurchaseRepository.getFreePurchaseById(
        shopId: shopId,
        purchaseId: purchaseId,
      );

      return purchase;
    } catch (e) {
      errorMessage.value =
          'Erreur lors de la récupération de l\'achat: ${e.toString()}';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour un achat libre
  Future<bool> updateFreePurchase({
    required String shopId,
    required String purchaseId,
    String? description,
    String? notes,
    String? status,
    List<ProductPurchase>? products,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await FreePurchaseRepository.updateFreePurchase(
        shopId: shopId,
        purchaseId: purchaseId,
        description: description,
        notes: notes,
        status: status,
        products: products,
      );

      // Rafraîchir la liste des achats après mise à jour
      await fetchShopFreePurchases(shopId);

      return true;
    } catch (e) {
      errorMessage.value =
          'Erreur lors de la mise à jour de l\'achat: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Supprimer un achat libre
  Future<bool> deleteFreePurchase({
    required String shopId,
    required String purchaseId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await FreePurchaseRepository.deleteFreePurchase(
        shopId: shopId,
        purchaseId: purchaseId,
      );

      // Rafraîchir la liste des achats après suppression
      await fetchShopFreePurchases(shopId);

      return true;
    } catch (e) {
      errorMessage.value =
          'Erreur lors de la suppression de l\'achat: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Récupérer les statistiques d'achats libres
  Future<void> fetchFreePurchaseStats({
    required String shopId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final stats = await FreePurchaseRepository.getFreePurchaseStats(
        shopId: shopId,
        startDate: startDate,
        endDate: endDate,
      );

      purchaseStats.value = stats;
    } catch (e) {
      errorMessage.value =
          'Erreur lors de la récupération des statistiques: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Réinitialiser le formulaire
  void resetForm() {
    addedProducts.clear();
    totalAmount.value = 0.0;
    showTotalPriceField.value = false;
    errorMessage.value = '';
  }
}
