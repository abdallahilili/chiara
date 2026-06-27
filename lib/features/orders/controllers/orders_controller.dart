import 'dart:io';
import 'package:chira/features/orders/repositories/orders_repository.dart';
import 'package:chira/models/request_model.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController {
  // Variables réactives pour la gestion de l'état
  var isLoading = false.obs;
  var addedProducts = <Map<String, dynamic>>[].obs;
  var shopRequests = <RequestModel>[].obs;
  var userRequests = <RequestModel>[].obs;
  var buyerAssignedRequests = <RequestModel>[].obs;
  var errorMessage = ''.obs;
  
  // Variables pour le formulaire de création de commande
  var selectedBuyer = Rx<String?>(null);
  var selectedImage = Rx<File?>(null);
  var generatedPdfFile = Rx<File?>(null);

  // Gestion des produits
  void addProduct(Map<String, dynamic> product) {
    addedProducts.add(product);
  }

  void updateProduct(int index, Map<String, dynamic> product) {
    if (index >= 0 && index < addedProducts.length) {
      addedProducts[index] = product;
    }
  }

  void removeProduct(int index) {
    if (index >= 0 && index < addedProducts.length) {
      addedProducts.removeAt(index);
    }
  }

  void clearProducts() {
    addedProducts.clear();
  }

  // Sélection d'acheteur
  void setSelectedBuyer(String? buyer) {
    selectedBuyer.value = buyer;
  }

  // Sélection d'image
  void setSelectedImage(File? image) {
    selectedImage.value = image;
  }

  // Génération de PDF
  Future<File?> generatePdf({
    required String amount,
    String? buyer,
    required String description,
    required List<Map<String, dynamic>> products,
    File? imageFile,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final pdfFile = await OrdersRepository.generatePdf(
        amount: amount,
        buyer: buyer,
        description: description,
        addedProducts: products,
        imageFile: imageFile,
      );

      generatedPdfFile.value = pdfFile;
      return pdfFile;
    } catch (e) {
      errorMessage.value = 'Erreur lors de la génération du PDF: ${e.toString()}';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Créer une requête
  Future<bool> createRequest({
    required List<Map<String, dynamic>> products,
    required String fileUrl,
    String? excelFileUrl,
    String? montant,
    String? description,
    String? purchaseById,
    required String shopId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await OrdersRepository.createRequest(
        products: products,
        fileUrl: fileUrl,
        excelFileUrl: excelFileUrl,
        montant: montant,
        description: description,
        purchaseById: purchaseById,
        shopId: shopId,
      );

      // Rafraîchir la liste des requêtes après création
      await fetchShopRequests(shopId);
      
      return true;
    } catch (e) {
      errorMessage.value = 'Erreur lors de la création de la requête: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour une requête
  Future<bool> updateRequest({
    required String requestId,
    required String shopId,
    String? purchaseById,
    String? newStatus,
    List<Map<String, dynamic>>? updatedProducts,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await OrdersRepository.updateRequest(
        requestId: requestId,
        shopId: shopId,
        purchaseById: purchaseById,
        newStatus: newStatus,
        updatedProducts: updatedProducts,
      );

      // Rafraîchir la liste des requêtes après mise à jour
      await fetchShopRequests(shopId);
      
      return true;
    } catch (e) {
      errorMessage.value = 'Erreur lors de la mise à jour de la requête: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Assigner un acheteur à une requête
  Future<bool> assignBuyerToRequest({
    required String requestId,
    required String shopId,
    required String buyerId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await OrdersRepository.assignBuyerToRequest(
        requestId: requestId,
        shopId: shopId,
        buyerId: buyerId,
      );

      // Rafraîchir la liste des requêtes après assignation
      await fetchShopRequests(shopId);
      
      return true;
    } catch (e) {
      errorMessage.value = 'Erreur lors de l\'assignation de l\'acheteur: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Récupérer les requêtes d'une boutique
  Future<void> fetchShopRequests(String shopId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      OrdersRepository.getShopRequests(shopId).listen(
        (requests) {
          shopRequests.value = requests;
        },
        onError: (error) {
          errorMessage.value = 'Erreur lors de la récupération des requêtes: ${error.toString()}';
        },
      );
    } catch (e) {
      errorMessage.value = 'Erreur lors de la récupération des requêtes: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Récupérer les requêtes d'un utilisateur
  Future<void> fetchUserRequests({
    required String shopId,
    required String userId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      OrdersRepository.getUserRequests(
        shopId: shopId,
        userId: userId,
      ).listen(
        (requests) {
          userRequests.value = requests;
        },
        onError: (error) {
          errorMessage.value = 'Erreur lors de la récupération des requêtes utilisateur: ${error.toString()}';
        },
      );
    } catch (e) {
      errorMessage.value = 'Erreur lors de la récupération des requêtes utilisateur: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Récupérer les requêtes assignées à un acheteur
  Future<void> fetchBuyerAssignedRequests({
    required String shopId,
    required String buyerId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      OrdersRepository.getBuyerAssignedRequests(
        shopId: shopId,
        buyerId: buyerId,
      ).listen(
        (requests) {
          buyerAssignedRequests.value = requests;
        },
        onError: (error) {
          errorMessage.value = 'Erreur lors de la récupération des requêtes assignées: ${error.toString()}';
        },
      );
    } catch (e) {
      errorMessage.value = 'Erreur lors de la récupération des requêtes assignées: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Supprimer une requête
  Future<bool> deleteRequest({
    required String requestId,
    required String shopId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await OrdersRepository.deleteRequest(
        requestId: requestId,
        shopId: shopId,
      );

      // Rafraîchir la liste des requêtes après suppression
      await fetchShopRequests(shopId);
      
      return true;
    } catch (e) {
      errorMessage.value = 'Erreur lors de la suppression de la requête: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Réinitialiser le formulaire
  void resetForm() {
    addedProducts.clear();
    selectedBuyer.value = null;
    selectedImage.value = null;
    generatedPdfFile.value = null;
    errorMessage.value = '';
  }
}
