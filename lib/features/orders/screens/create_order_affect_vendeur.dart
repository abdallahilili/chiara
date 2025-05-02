import 'dart:io';
import 'package:chira/common/repositories/supabase_storage_repository.dart';
import 'package:chira/features/orders/repositories/orders_repository.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:chira/common/widgets/custom_button.dart';
import 'package:chira/common/widgets/custom_input.dart';
import 'package:chira/common/widgets/custom_input_number.dart';
import 'package:permission_handler/permission_handler.dart';

class CreateOrderAffectVendeurPage extends StatefulWidget {
  final List<Map<String, dynamic>> addedProducts;

  const CreateOrderAffectVendeurPage({super.key, required this.addedProducts});

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

  Future<void> selectImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> generateAndUploadExcelFile(
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
      return;
    }

    try {
      // Créer un fichier temporaire en mémoire
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/produits.xlsx');
      await file.writeAsBytes(fileBytes);

      // Uploader le fichier vers Supabase
      final supabaseRepository = SupabaseStorageRepository();
      final publicUrl = await supabaseRepository.storeFileToSupabase(
        'chira-app', // Remplacez par votre nom de bucket
        'produits/${DateTime.now().millisecondsSinceEpoch}.xlsx', // Référence unique pour le fichier
        file,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fichier téléchargé avec succès: $publicUrl')),
      );
    } catch (e) {
      print('Erreur lors du téléchargement du fichier vers Supabase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors du téléchargement du fichier')),
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'من سيقوم بعملية الشراء',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                /// ✅ **Dropdown pour sélectionner l’acheteur**
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
                          color: Color.fromARGB(255, 42, 100, 45), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: _selectedBuyer,
                  items: ['المشتري 1', 'المشتري 2', 'المشتري 3']
                      .map((buyer) =>
                          DropdownMenuItem(value: buyer, child: Text(buyer)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBuyer = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                /// ✅ **Champ pour le montant**
                CustomInputNumber(
                  controller: _amountController,
                  hintText: 'المبلغ المرسل',
                ),
                const SizedBox(height: 16),

                /// ✅ **Sélection et affichage d'une image**
                GestureDetector(
                  onTap: selectImage,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                      // border: Border.all(color: Colors.grey, width: 1),
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

                /// ✅ **Champ de description**
                CustomInput(
                  controller: _descriptionController,
                  hintText: 'وصف',
                  maxLines: 4,
                ),
                const SizedBox(height: 20),

                /// ✅ **Boutons avec gestion correcte de la largeur**
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'حفظ',
                        onPressed: () async {
                          // Générer le fichier Excel
                          await generateAndUploadExcelFile(
                              widget.addedProducts);

                          // Appel de la génération du PDF
                          // OrdersRepository.generatePdf(
                          //   amount: _amountController.text,
                          //   buyer: _selectedBuyer,
                          //   description: _descriptionController.text,
                          //   addedProducts: widget.addedProducts,
                          //   imageFile: _selectedImage,
                          // );

                          // Afficher un message
                        },

                        // 📝 Générer le PDF
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
