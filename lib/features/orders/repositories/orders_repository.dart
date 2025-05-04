import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:chira/models/request_model.dart';
import 'package:chira/models/prodect_request.dart';

class OrdersRepository {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final _uuid = Uuid();

  static Future<File> generatePdf({
    required String amount,
    required String? buyer,
    required String description,
    required List<Map<String, dynamic>> addedProducts,
    File? imageFile,
  }) async {
    final pdf = pw.Document();

    final arabicFont =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Janat.ttf'));

    String reverseArabicText(String text) {
      return text.split(' ').reversed.join(' ');
    }

    String convertArabicNumbersToLatin(String text) {
      final arabicToLatin = {
        '٠': '0',
        '١': '1',
        '٢': '2',
        '٣': '3',
        '٤': '4',
        '٥': '5',
        '٦': '6',
        '٧': '7',
        '٨': '8',
        '٩': '9',
      };

      return text.split('').map((char) {
        return arabicToLatin[char] ?? char;
      }).join('');
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'تفاصيل الطلبية',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Table.fromTextArray(
                  context: context,
                  cellAlignment: pw.Alignment.centerRight,
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColors.green200,
                    border: pw.Border.all(color: PdfColors.green700, width: 0),
                  ),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    font: arabicFont,
                  ),
                  cellStyle: pw.TextStyle(font: arabicFont),
                  headers: ['المبلغ', 'المشتري'],
                  data: [
                    [
                      convertArabicNumbersToLatin(amount),
                      buyer != null ? reverseArabicText(buyer) : 'غير محدد',
                    ],
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'تاريخ الطلبية: ${DateTime.now().toString().split(' ')[0]}',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'وصف: \n ${reverseArabicText(description)}',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 12,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'المنتجات المضافة',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  context: context,
                  cellAlignment: pw.Alignment.centerRight,
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    font: arabicFont,
                  ),
                  cellStyle: pw.TextStyle(font: arabicFont),
                  headers: [
                    'الوحدة',
                    'الكمية',
                    '                                                المنتج   '
                  ],
                  data: addedProducts.map((product) {
                    return [
                      product['unit'] ?? 'غير محدد',
                      convertArabicNumbersToLatin(
                          product['quantity'].toString()),
                      reverseArabicText(product['product']),
                    ];
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (imageFile != null) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(
                pw.MemoryImage(imageFile.readAsBytesSync()),
                width: 700,
                height: 700,
              ),
            );
          },
        ),
      );
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/commande.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Ne pas ouvrir automatiquement le fichier
    // OpenFilex.open(filePath); - Cette ligne a été supprimée

    return file;
  }

  // Autres méthodes de la classe (inchangées)
  // ...

  // Méthode pour créer une nouvelle demande dans Firebase
  static Future<String> createRequest({
    required List<Map<String, dynamic>> products,
    required String fileUrl,
    String? excelFileUrl,
    String? montant,
    String? description,
    String? purchaseById,
    required String shopId,
  }) async {
    try {
      // Génération d'un ID unique pour cette demande
      final String requestId = _uuid.v4();
      final String? currentUserId = _auth.currentUser?.uid;

      if (currentUserId == null) {
        throw Exception("Utilisateur non authentifié");
      }

      // Convertir les produits en format ProductRequest
      List<ProductRequest> requestProducts = products.map((product) {
        return ProductRequest(
          nom: product['product'],
          quantite: int.tryParse(product['quantity']) ?? 0,
          unite: product['unit'] ?? '',
          etat: 'en attente',
        );
      }).toList();

      // Créer le modèle de demande
      final requestModel = RequestModel(
        id: requestId,
        vendeurId: currentUserId,
        produits: requestProducts,
        createdAt: DateTime.now(),
        createdBy: currentUserId,
        purchaseBy: purchaseById,
        file: fileUrl,
        excelFile: excelFileUrl,
        montant: montant,
        description: description,
      );

      // Enregistrer dans Firestore
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('requests')
          .doc(requestId)
          .set(requestModel.toMap());

      return requestId;
    } catch (e) {
      print('Erreur lors de la création de la demande: $e');
      throw Exception("Échec de l'enregistrement de la demande: $e");
    }
  }

  // Méthode pour mettre à jour une demande existante
  static Future<void> updateRequest({
    required String requestId,
    required String shopId,
    String? purchaseById,
    String? newStatus,
    List<Map<String, dynamic>>? updatedProducts,
  }) async {
    try {
      final docRef = _firestore
          .collection('shops')
          .doc(shopId)
          .collection('requests')
          .doc(requestId);

      // Récupérer la demande actuelle
      final requestSnapshot = await docRef.get();
      if (!requestSnapshot.exists) {
        throw Exception("La demande n'existe pas");
      }

      // Créer un map avec les champs à mettre à jour
      Map<String, dynamic> updateData = {};

      // Ajouter l'acheteur s'il est fourni
      if (purchaseById != null) {
        updateData['purchaseBy'] = purchaseById;
      }

      // Mettre à jour les produits si fournis
      if (updatedProducts != null) {
        List<Map<String, dynamic>> formattedProducts =
            updatedProducts.map((product) {
          return {
            'nom': product['product'],
            'quantite': int.tryParse(product['quantity']) ?? 0,
            'unite': product['unit'] ?? '',
            'etat': product['status'] ?? 'en attente',
          };
        }).toList();

        updateData['produits'] = formattedProducts;
      }

      // Mettre à jour le document dans Firestore
      await docRef.update(updateData);
    } catch (e) {
      print('Erreur lors de la mise à jour de la demande: $e');
      throw Exception("Échec de la mise à jour de la demande: $e");
    }
  }

  // Méthode pour affecter un acheteur à une demande
  static Future<void> assignBuyerToRequest({
    required String requestId,
    required String shopId,
    required String buyerId,
  }) async {
    try {
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('requests')
          .doc(requestId)
          .update({
        'purchaseBy': buyerId,
      });
    } catch (e) {
      print('Erreur lors de l\'affectation de l\'acheteur: $e');
      throw Exception("Échec de l'affectation de l'acheteur: $e");
    }
  }

  // Méthode pour obtenir toutes les demandes d'une boutique
  static Stream<List<RequestModel>> getShopRequests(String shopId) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RequestModel.fromMap(doc.data());
      }).toList();
    });
  }

  // Méthode pour obtenir les demandes créées par un utilisateur spécifique
  static Stream<List<RequestModel>> getUserRequests({
    required String shopId,
    required String userId,
  }) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('requests')
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RequestModel.fromMap(doc.data());
      }).toList();
    });
  }

  // Méthode pour obtenir les demandes assignées à un acheteur spécifique
  static Stream<List<RequestModel>> getBuyerAssignedRequests({
    required String shopId,
    required String buyerId,
  }) {
    return _firestore
        .collection('shops')
        .doc(shopId)
        .collection('requests')
        .where('purchaseBy', isEqualTo: buyerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RequestModel.fromMap(doc.data());
      }).toList();
    });
  }

  // Méthode pour supprimer une demande
  static Future<void> deleteRequest({
    required String requestId,
    required String shopId,
  }) async {
    try {
      await _firestore
          .collection('shops')
          .doc(shopId)
          .collection('requests')
          .doc(requestId)
          .delete();
    } catch (e) {
      print('Erreur lors de la suppression de la demande: $e');
      throw Exception("Échec de la suppression de la demande: $e");
    }
  }
}
