import 'dart:io';
import 'dart:math';
import 'package:animated_icon/animated_icon.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

class SuccessDialog extends StatelessWidget {
  final File? pdfFile;
  final VoidCallback onDismiss;

  const SuccessDialog({
    Key? key,
    required this.pdfFile,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Image.asset(
            'assets/imgs/check.gif',
            height: 100,
          ),
          SizedBox(width: 10),
          Text(
            'تم الحفظ ',
            style: TextStyle(fontFamily: 'Droid'),
          ),
        ],
      ),
      content: SizedBox(width: 30),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDismiss(); // Appel de la fonction de retour en arrière
          },
          child: const Column(
            children: [
              Icon(
                Icons.keyboard_return,
                size: 35,
              ),
              const Text(
                'عودة',
                style: TextStyle(fontFamily: 'Droid'),
              )
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            if (pdfFile != null) {
              await OpenFilex.open(pdfFile!.path);
            }
            Navigator.of(context).pop();
          },
          child: const Column(
            children: [
              Icon(
                Icons.file_open,
                size: 35,
              ),
              const Text(
                'فتح الملف',
                style: TextStyle(fontFamily: 'Droid'),
              )
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            if (pdfFile != null) {
              try {
                await Share.shareXFiles(
                  [XFile(pdfFile!.path)],
                  text: 'تفاصيل الطلبية',
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('فشل في المشاركة الملف')),
                );
              }
            }
            Navigator.of(context).pop();
            onDismiss(); // Appel de la fonction de retour en arrière après partage
          },
          child: const Column(
            children: [
              Icon(
                Icons.share,
                size: 35,
              ),
              const Text(
                'مشاركة',
                style: TextStyle(fontFamily: 'Droid'),
              )
            ],
          ),
        ),
      ],
    );
  }
}

/// Extension pour simplifier l'affichage de la boîte de dialogue
extension SuccessDialogExtension on BuildContext {
  Future<void> showOrderSuccessDialog({
    required File? pdfFile,
    required VoidCallback onDismiss,
  }) async {
    return showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        pdfFile: pdfFile,
        onDismiss: onDismiss,
      ),
    );
  }
}
