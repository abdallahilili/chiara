import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';

import 'package:chira/common/widgets/custom_button.dart';
import 'package:chira/common/widgets/custom_input.dart';
import 'package:chira/common/widgets/custom_input_number.dart';

class CreateOrderAffectVendeurPage extends StatefulWidget {
  final List<Map<String, dynamic>> addedProducts;

  CreateOrderAffectVendeurPage({required this.addedProducts});

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

  /// ✅ **Méthode pour générer un PDF avec un tableau**
  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    // Charger la police arabe
    final arabicFont =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Janat.ttf'));

    // Fonction pour inverser le texte arabe
    String reverseArabicText(String text) {
      return text.split(' ').reversed.join(' ');
    }

    // Fonction pour convertir les chiffres arabes en chiffres latins
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
            textDirection: pw.TextDirection.rtl, // Activer RTL
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

                /// ✅ **جدول بيانات المشتري**
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
                      convertArabicNumbersToLatin(
                          _amountController.text), // Convertir les chiffres
                      _selectedBuyer != null
                          ? reverseArabicText(_selectedBuyer!)
                          : 'غير محدد',
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
                  'وصف: \n ${reverseArabicText(_descriptionController.text)}',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 12,
                  ),
                ),
                pw.SizedBox(height: 20),

                /// ✅ **جدول المنتجات المضافة**
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
                  data: widget.addedProducts.map((product) {
                    return [
                      // Convertir les chiffres

                      product['unit'] ?? 'غير محدد',
                      convertArabicNumbersToLatin(
                          product['quantity'].toString()),
                      reverseArabicText(product['product'])
                    ];
                  }).toList(),
                ),

                pw.SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
    // Ajouter une page pour l'image, si l'image est sélectionnée
    if (_selectedImage != null) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.SizedBox(height: 20),
                  pw.Image(
                    pw.MemoryImage(_selectedImage!.readAsBytesSync()),
                    width: 700,
                    height: 700,
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    /// 📂 **حفظ ملف PDF وفتحه**
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/commande.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    print("PDF Generated: ${file.path}");

    OpenFilex.open(filePath);
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
                      borderSide: BorderSide(
                          color: const Color.fromARGB(255, 42, 100, 45),
                          width: 2),
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
                      border: Border.all(color: Colors.grey, width: 1),
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
                        onPressed: _generatePdf, // 📝 Générer le PDF
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
