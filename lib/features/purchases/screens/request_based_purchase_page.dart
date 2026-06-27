// request_based_purchase_page.dart
import 'package:chira/common/utils/colors.dart';
import 'package:chira/common/widgets/custom_button.dart';
import 'package:chira/common/widgets/custom_input_number.dart';
import 'package:chira/models/request_model.dart';
import 'package:chira/features/purchases/controller/purchases_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestBasedPurchasePage extends StatelessWidget {
  final RequestModel request;
  final String shopId;

  RequestBasedPurchasePage({
    super.key,
    required this.request,
    required this.shopId,
  });

  // Injection du controller GetX
  final PurchasesController controller = Get.put(PurchasesController());
  
  // Lists pour les controllers de texte
  final RxList<TextEditingController> quantityControllers = <TextEditingController>[].obs;
  final RxList<TextEditingController> unitPriceControllers = <TextEditingController>[].obs;
  final RxList<TextEditingController> totalPriceControllers = <TextEditingController>[].obs;
  
  // Liste des produits avec prix
  final RxList<Map<String, dynamic>> productsWithPrices = <Map<String, dynamic>>[].obs;
  final RxDouble totalAmount = 0.0.obs;

  void _initializeProducts() {
    // تحويل منتجات الطلب إلى تنسيق الشراء
    productsWithPrices.value = request.produits.map((product) {
      return {
        'product': product.nom,
        'quantity': product.quantite.toDouble(),
        'unit': product.unite,
        'unitPrice': 0.0,
        'totalPrice': 0.0,
      };
    }).toList();

    // إنشاء TextEditingController لكل منتج
    for (int i = 0; i < productsWithPrices.length; i++) {
      quantityControllers.add(TextEditingController(
        text: productsWithPrices[i]['quantity'].toInt().toString()
      ));
      unitPriceControllers.add(TextEditingController());
      totalPriceControllers.add(TextEditingController());
    }
  }

  void _updateQuantity(int index, String quantityStr) {
    if (quantityStr.isEmpty) return;
    final quantity = double.tryParse(quantityStr) ?? 0.0;
    productsWithPrices[index]['quantity'] = quantity;
    // إعادة حساب السعر الإجمالي بناءً على الكمية الجديدة والسعر الوحدة
    final unitPrice = productsWithPrices[index]['unitPrice'];
    if (unitPrice > 0) {
      final newTotalPrice = quantity * unitPrice;
      productsWithPrices[index]['totalPrice'] = newTotalPrice;
      totalPriceControllers[index].text = newTotalPrice.toStringAsFixed(2);
      _calculateTotalAmount();
    }
  }

  void _updateUnitPrice(int index, String priceStr) {
    if (priceStr.isEmpty) return;
    final unitPrice = double.tryParse(priceStr) ?? 0.0;
    final quantity = productsWithPrices[index]['quantity'];
    productsWithPrices[index]['unitPrice'] = unitPrice;
    if (quantity > 0) {
      final totalPrice = unitPrice * quantity;
      productsWithPrices[index]['totalPrice'] = totalPrice;
      totalPriceControllers[index].text = totalPrice.toStringAsFixed(2);
      _calculateTotalAmount();
    }
  }

  void _updateTotalPrice(int index, String totalPriceStr) {
    if (totalPriceStr.isEmpty) return;
    final totalPrice = double.tryParse(totalPriceStr) ?? 0.0;
    final quantity = productsWithPrices[index]['quantity'];
    productsWithPrices[index]['totalPrice'] = totalPrice;
    if (quantity > 0) {
      final unitPrice = totalPrice / quantity;
      productsWithPrices[index]['unitPrice'] = unitPrice;
      unitPriceControllers[index].text = unitPrice.toStringAsFixed(2);
      _calculateTotalAmount();
    }
  }

  void _calculateTotalAmount() {
    totalAmount.value = productsWithPrices.fold(0.0, (sum, product) {
      return sum + (product['totalPrice'] as double);
    });
  }

  Future<void> _savePurchase(BuildContext context) async {
    // التحقق من إدخال جميع البيانات المطلوبة
    for (int i = 0; i < productsWithPrices.length; i++) {
      final product = productsWithPrices[i];
      if (product['quantity'] == 0.0 || product['unitPrice'] == 0.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('الرجاء إدخال الكمية والسعر للمنتج: ${product['product']}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final success = await controller.createFreePurchase(
      shopId: shopId,
      description: 'شراء مبني على الطلب ${request.id}',
      notes: 'تم إنشاء الطلب في ${request.createdAt}',
    );

    if (success) {
      // عرض نافذة النجاح
      if (!context.mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'تم حفظ عملية الشراء',
              style: TextStyle(fontFamily: 'Droid'),
            ),
            content: Text(
              'تم حفظ الشراء المبني على الطلب بنجاح\nالمبلغ الإجمالي: ${totalAmount.value.toStringAsFixed(2)} أوقية',
              style: const TextStyle(fontFamily: 'Droid'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // إغلاق النافذة
                  Navigator.of(context).pop(); // العودة إلى الشاشة السابقة
                },
                child: const Text(
                  'موافق',
                  style: TextStyle(fontFamily: 'Droid'),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حفظ عملية الشراء: ${controller.errorMessage.value}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize products on first build
    if (productsWithPrices.isEmpty) {
      _initializeProducts();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'شراء مبني على طلب',
            style: TextStyle(fontFamily: 'Droid'),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // معلومات الطلب والمالية
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Colonne 1 : Informations de la commande
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'رقم الطلب: #${request.id.substring(0, 8)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Droid',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'تاريخ الطلب: ${request.createdAt.toString().split(' ')[0]}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: 'Droid',
                            ),
                          ),
                        ],
                      ),
                      
                      // Ligne de séparation verticale
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey[300],
                      ),

                      // Colonne 2 : Informations financières
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                           Text(
                            'المبلغ المرسل: ${request.montant ?? "0"}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Droid',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                             final double initialAmount = double.tryParse(request.montant ?? "0") ?? 0.0;
                             final double remaining = initialAmount - totalAmount.value;
                             
                             return Text(
                              'الباقي: ${remaining.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: remaining >= 0 ? Colors.green : Colors.red,
                                fontFamily: 'Droid',
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // جدول المنتجات
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // رأس الجدول
                      Container(
                        decoration: BoxDecoration(
                          color: greenCustomColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'المنتج',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Droid',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'الكمية',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Droid',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'الوحدة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Droid',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'سعر الوحدة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Droid',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'السعر الإجمالي',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Droid',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // صفوف المنتجات
                      Obx(() => Column(
                        children: List.generate(productsWithPrices.length, (index) {
                          final product = productsWithPrices[index];
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: index == productsWithPrices.length - 1 
                                      ? Colors.transparent 
                                      : Colors.grey[300]!,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            child: Row(
                              children: [
                                // اسم المنتج
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      product['product'],
                                      style: const TextStyle(
                                        fontFamily: 'Droid',
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                
                                // الكمية (قابلة للتعديل)
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: TextField(
                                      controller: quantityControllers[index],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      textInputAction: TextInputAction.next,
                                      onChanged: (value) => _updateQuantity(index, value),
                                      style: const TextStyle(
                                        fontFamily: 'Droid',
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: 'Droid',
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          borderSide: const BorderSide(color: Colors.blue),
                                        ),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // الوحدة
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      product['unit'],
                                      style: const TextStyle(
                                        fontFamily: 'Droid',
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                
                                // سعر الوحدة
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: TextField(
                                      controller: unitPriceControllers[index],
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      textAlign: TextAlign.center,
                                      textInputAction: TextInputAction.next,
                                      onChanged: (value) => _updateUnitPrice(index, value),
                                      style: const TextStyle(
                                        fontFamily: 'Droid',
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '0.00',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: 'Droid',
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          borderSide: const BorderSide(color: Colors.blue),
                                        ),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // السعر الإجمالي
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: TextField(
                                      controller: totalPriceControllers[index],
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      textAlign: TextAlign.center,
                                      textInputAction: TextInputAction.done,
                                      onChanged: (value) => _updateTotalPrice(index, value),
                                      style: const TextStyle(
                                        fontFamily: 'Droid',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '0.00',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontFamily: 'Droid',
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                          borderSide: const BorderSide(color: Colors.green),
                                        ),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      )),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // المبلغ الإجمالي
                Obx(() => Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: greenCustomColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: greenCustomColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      
                      const Text(
                        'المبلغ الإجمالي:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Droid',
                        ),
                      ),Text(
                        '${totalAmount.value.toStringAsFixed(2)} أوقية',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Droid',
                        ),
                      ),
                    ],
                  ),
                )),
                
                const SizedBox(height: 30),
                
                // أزرار الإجراء
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'إلغاء',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value 
                            ? null 
                            : () => _savePurchase(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenCustomColor,
                          minimumSize: const Size(150, 50),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'حفظ الشراء',
                                style: TextStyle(
                                  fontFamily: 'Droid',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                      )),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}