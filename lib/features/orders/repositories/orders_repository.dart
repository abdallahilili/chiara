import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';

import 'package:excel/excel.dart';
import 'package:permission_handler/permission_handler.dart';

class OrdersRepository {
  static Future<void> generatePdf({
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

    OpenFilex.open(filePath);
  }

  static Future<File?> generateExcelFile(
    List<Map<String, dynamic>> addedProducts,
  ) async {
    // Demander la permission d'écriture
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (!status.isGranted) return null;
    }

    // Créer un classeur
    final excel = Excel.createExcel();
    final Sheet sheetObject = excel['Produits'];
    sheetObject.appendRow(['Produit', 'Quantité', 'Unité']);

    for (var product in addedProducts) {
      sheetObject.appendRow([
        product['product'] ?? '',
        product['quantity'] ?? '',
        product['unit'] ?? ''
      ]);
      print('prodiot : $product[product]');
      print('quantite : $product[quantity]');
    }

    // Obtenir le répertoire
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/produits.xlsx';
    final fileBytes = excel.encode();

    print('File path: $filePath');

    if (fileBytes == null) return null;

    final file = File(filePath);
    await file.writeAsBytes(fileBytes);
    return file;
  }
}
