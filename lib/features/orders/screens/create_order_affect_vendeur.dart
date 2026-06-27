import 'dart:io';
import 'package:chira/features/orders/controllers/orders_controller.dart';
import 'package:chira/features/orders/widgets/action_buttons_widget.dart';
import 'package:chira/features/orders/widgets/amount_input_widget.dart';
import 'package:chira/features/orders/widgets/buyer_selector_widget.dart';
import 'package:chira/features/orders/widgets/description_input_widget.dart';
import 'package:chira/features/orders/widgets/image_picker_widget.dart';
import 'package:chira/features/orders/widgets/loading_overlay_widget.dart';
import 'package:flutter/material.dart';
import 'package:chira/features/orders/repositories/orders_repository.dart';
import 'package:chira/common/repositories/supabase_storage_repository.dart';
import 'package:chira/features/orders/widgets/success_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

class CreateOrderAffectVendeurPage extends StatelessWidget {
  final List<Map<String, dynamic>> addedProducts;
  final String shopId;

  CreateOrderAffectVendeurPage({
    Key? key,
    required this.addedProducts,
    required this.shopId,
  }) : super(key: key);

  // Injection du controller GetX
  final OrdersController controller = Get.put(OrdersController());
  
  // Controllers pour les champs de texte
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Buyers map
  final Map<String, String> _buyersMap = {
    'المشتري 1': 'buyer_id_1',
    'المشتري 2': 'buyer_id_2',
    'المشتري 3': 'buyer_id_3',
  };

  Future<void> selectImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      controller.setSelectedImage(File(pickedImage.path));
    }
  }

  Future<String?> generateAndUploadExcelFile(
    List<Map<String, dynamic>> addedProducts,
    BuildContext context,
  ) async {
    // Créer un classeur Excel
    final excel = Excel.createExcel();
    final Sheet sheetObject = excel['Produits'];
    sheetObject.appendRow(['Produit', 'Quantité', 'Unité']);

    for (var product in addedProducts) {
      sheetObject.appendRow([
        product['product'] ?? '',
        product['quantity'] ?? '',
        product['unit'] ?? ''
      ]);
    }

    final fileBytes = excel.encode();

    if (fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de la génération du fichier Excel')),
      );
      return null;
    }

    try {
      // Créer un fichier temporaire en mémoire
      final directory = await getTemporaryDirectory();
      final excelFilePath = '${directory.path}/produits.xlsx';
      final excelFile = File(excelFilePath);
      await excelFile.writeAsBytes(fileBytes);

      // Uploader le fichier vers Supabase
      final supabaseRepository = SupabaseStorageRepository();
      final fileReference =
          'produits/${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final publicUrl = await supabaseRepository.storeFileToSupabase(
        'chira-app', // Votre nom de bucket
        fileReference,
        excelFile,
      );

      return publicUrl;
    } catch (e) {
      print('Erreur lors du téléchargement du fichier vers Supabase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors du téléchargement du fichier')),
      );
      return null;
    }
  }

  Future<String?> uploadPdfToSupabase(File pdfFile) async {
    try {
      final supabaseRepository = SupabaseStorageRepository();
      final fileReference =
          'commandes/${DateTime.now().millisecondsSinceEpoch}.pdf';
      final publicUrl = await supabaseRepository.storeFileToSupabase(
        'chira-app', // Votre nom de bucket
        fileReference,
        pdfFile,
      );
      return publicUrl;
    } catch (e) {
      print('Erreur lors du téléchargement du PDF vers Supabase: $e');
      return null;
    }
  }

  Future<void> saveOrder(BuildContext context) async {
    try {
      // 1. Générer et télécharger le fichier Excel
      final excelUrl = await generateAndUploadExcelFile(addedProducts, context);
      if (excelUrl == null) {
        throw Exception("Échec du téléchargement du fichier Excel");
      }

      // 2. Générer le PDF via le controller
      final File? pdfFile = await controller.generatePdf(
        amount: _amountController.text,
        buyer: controller.selectedBuyer.value,
        description: _descriptionController.text,
        products: addedProducts,
        imageFile: controller.selectedImage.value,
      );

      if (pdfFile == null) {
        throw Exception("Échec de la génération du PDF");
      }

      // 3. Télécharger le PDF sur Supabase
      final pdfUrl = await uploadPdfToSupabase(pdfFile);
      if (pdfUrl == null) {
        throw Exception("Échec du téléchargement du PDF");
      }

      // 4. Créer la demande via le controller
      final String? buyerId =
          controller.selectedBuyer.value != null 
              ? _buyersMap[controller.selectedBuyer.value] 
              : null;

      final success = await controller.createRequest(
        products: addedProducts,
        fileUrl: pdfUrl,
        excelFileUrl: excelUrl,
        montant: _amountController.text,
        description: _descriptionController.text,
        purchaseById: buyerId,
        shopId: shopId,
      );

      if (!success) {
        throw Exception(controller.errorMessage.value);
      }

      // Afficher un dialogue de succès
      if (!context.mounted) return;

      // Utiliser le nouveau widget à travers l'extension
      context.showOrderSuccessDialog(
        pdfFile: controller.generatedPdfFile.value,
        onDismiss: () {
          controller.resetForm();
          Navigator.of(context).pop(); // Retourner à l'écran précédent
        },
      );
    } catch (e) {
      // Afficher un message d'erreur
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Erreur lors de la création de la commande: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إسناد الطلبية'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              controller.resetForm();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Obx(() => Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'من سيقوم بعملية الشراء',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Widget sélecteur d'acheteur
                    BuyerSelectorWidget(
                      buyersMap: _buyersMap,
                      selectedBuyer: controller.selectedBuyer.value,
                      onBuyerChanged: (value) {
                        controller.setSelectedBuyer(value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Widget de saisie du montant
                    AmountInputWidget(controller: _amountController),
                    const SizedBox(height: 16),

                    // Widget de sélection d'image
                    ImagePickerWidget(
                      selectedImage: controller.selectedImage.value,
                      onImageSelected: (file) {
                        controller.setSelectedImage(file);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Widget de saisie de description
                    DescriptionInputWidget(controller: _descriptionController),
                    const SizedBox(height: 20),

                    // Widget des boutons d'action
                    ActionButtonsWidget(
                      onSave: () => saveOrder(context),
                      onCancel: () {
                        controller.resetForm();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Widget d'overlay de chargement
            LoadingOverlayWidget(
              isLoading: controller.isLoading.value,
              color: Theme.of(context).primaryColor,
            ),
          ],
        )),
      ),
    );
  }
}
