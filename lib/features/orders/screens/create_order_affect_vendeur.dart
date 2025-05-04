import 'dart:io';
import 'package:chira/common/repositories/supabase_storage_repository.dart';
import 'package:chira/features/orders/repositories/orders_repository.dart';
import 'package:chira/features/orders/widgets/success_dialog.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:chira/common/widgets/custom_button.dart';
import 'package:chira/common/widgets/custom_input.dart';
import 'package:chira/common/widgets/custom_input_number.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart'; // Ajout de l'import pour ouvrir le fichier

class CreateOrderAffectVendeurPage extends StatefulWidget {
  final List<Map<String, dynamic>> addedProducts;
  final String shopId;

  const CreateOrderAffectVendeurPage({
    Key? key,
    required this.addedProducts,
    required this.shopId,
  }) : super(key: key);

  @override
  _CreateOrderAffectVendeurPageState createState() =>
      _CreateOrderAffectVendeurPageState();
}

class _CreateOrderAffectVendeurPageState
    extends State<CreateOrderAffectVendeurPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedBuyer;
  File? _selectedImage;
  bool _isLoading = false;
  File? _generatedPdfFile; // Pour stocker le fichier PDF généré

  // Modifiez ces valeurs avec les IDs réels des acheteurs
  final Map<String, String> _buyersMap = {
    'المشتري 1': 'buyer_id_1',
    'المشتري 2': 'buyer_id_2',
    'المشتري 3': 'buyer_id_3',
  };

  Future<void> selectImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<String?> generateAndUploadExcelFile(
    List<Map<String, dynamic>> addedProducts,
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

  Future<void> saveOrder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Générer et télécharger le fichier Excel
      final excelUrl = await generateAndUploadExcelFile(widget.addedProducts);
      if (excelUrl == null) {
        throw Exception("Échec du téléchargement du fichier Excel");
      }

      // 2. Générer le PDF et récupérer le fichier
      final File pdfFile = await OrdersRepository.generatePdf(
        amount: _amountController.text,
        buyer: _selectedBuyer,
        description: _descriptionController.text,
        addedProducts: widget.addedProducts,
        imageFile: _selectedImage,
      );

      // Stocker le fichier PDF pour une utilisation ultérieure
      _generatedPdfFile = pdfFile;

      // 3. Télécharger le PDF sur Supabase
      final pdfUrl = await uploadPdfToSupabase(pdfFile);
      if (pdfUrl == null) {
        throw Exception("Échec du téléchargement du PDF");
      }

      // 4. Créer la demande dans Firebase avec tous les nouveaux champs
      final String? buyerId =
          _selectedBuyer != null ? _buyersMap[_selectedBuyer] : null;

      final requestId = await OrdersRepository.createRequest(
        products: widget.addedProducts,
        fileUrl: pdfUrl, // URL du PDF
        excelFileUrl: excelUrl, // URL du fichier Excel
        montant: _amountController.text, // Montant de la commande
        description: _descriptionController.text, // Description de la commande
        purchaseById: buyerId, // ID de l'acheteur sélectionné
        shopId: widget.shopId, // ID du magasin
      );

      setState(() {
        _isLoading = false;
      });

      // Afficher un dialogue de succès
      if (!mounted) return;

      // Utiliser le nouveau widget à travers l'extension
      context.showOrderSuccessDialog(
        pdfFile: _generatedPdfFile,
        onDismiss: () {
          Navigator.of(context).pop(); // Retourner à l'écran précédent
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Afficher un message d'erreur
      if (!mounted) return;

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
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
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

                    // Dropdown pour sélectionner l'acheteur
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 42, 100, 45),
                              width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: _selectedBuyer,
                      items: _buyersMap.keys
                          .map((buyer) => DropdownMenuItem(
                              value: buyer, child: Text(buyer)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBuyer = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Champ pour le montant
                    CustomInputNumber(
                      controller: _amountController,
                      hintText: 'المبلغ المرسل',
                    ),
                    const SizedBox(height: 16),

                    // Sélection et affichage d'une image
                    GestureDetector(
                      onTap: selectImage,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _selectedImage!,
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.black54,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Champ de description
                    CustomInput(
                      controller: _descriptionController,
                      hintText: 'وصف',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),

                    // Boutons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'حفظ',
                            onPressed: saveOrder,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            text: 'إلغاء',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Indicateur de chargement
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
