import 'package:chira/common/utils/colors.dart';
import 'package:chira/common/widgets/custom_button.dart';
import 'package:chira/common/widgets/custom_input.dart';
import 'package:chira/common/widgets/custom_input_number.dart';
import 'package:chira/features/purchases/controller/purchases_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FreePurchasePage extends StatelessWidget {
  FreePurchasePage({super.key});

  // Injection du controller GetX
  final PurchasesController controller = Get.put(PurchasesController());
  
  // Controllers pour les champs de texte
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _totalPriceController = TextEditingController();

  // Index du produit en cours de modification
  final RxInt editingIndex = (-1).obs;

  void _addOrUpdateProduct(BuildContext context) {
    String product = _productController.text.trim();
    String quantityStr = _quantityController.text.trim();
    String unitPriceStr = _unitPriceController.text.trim();
    String totalPriceStr = _totalPriceController.text.trim();

    if (product.isEmpty || quantityStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال اسم المنتج والكمية')),
      );
      return;
    }

    if (unitPriceStr.isEmpty && totalPriceStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال سعر الفرد أو السعر الإجمالي')),
      );
      return;
    }

    double quantity = double.tryParse(quantityStr) ?? 0;
    double unitPrice = 0;
    double totalPrice = 0;

    if (unitPriceStr.isNotEmpty) {
      // Si l'utilisateur a entré le prix unitaire
      unitPrice = double.tryParse(unitPriceStr) ?? 0;
      totalPrice = controller.calculateTotalPrice(unitPrice, quantity);
    } else {
      // Si l'utilisateur a entré le prix total
      totalPrice = double.tryParse(totalPriceStr) ?? 0;
      unitPrice = controller.calculateUnitPrice(totalPrice, quantity);
    }

    if (editingIndex.value == -1) {
      // Ajout d'un nouveau produit
      controller.addProduct(
        product: product,
        quantity: quantity,
        unitPrice: unitPrice,
        totalPrice: totalPrice,
      );
    } else {
      // Mise à jour d'un produit existant
      controller.updateProduct(
        editingIndex.value,
        product: product,
        quantity: quantity,
        unitPrice: unitPrice,
        totalPrice: totalPrice,
      );
      editingIndex.value = -1;
    }

    // Vider les champs
    _productController.clear();
    _quantityController.clear();
    _unitPriceController.clear();
    _totalPriceController.clear();
  }

  void _editProduct(int index) {
    _productController.text = controller.addedProducts[index]['product'];
    _quantityController.text = controller.addedProducts[index]['quantity'].toString();
    _unitPriceController.text =
        controller.addedProducts[index]['unitPrice'].toStringAsFixed(2);
    _totalPriceController.text =
        controller.addedProducts[index]['totalPrice'].toStringAsFixed(2);
    editingIndex.value = index;
  }

  Future<void> _savePurchase(BuildContext context) async {
    if (controller.addedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إضافة منتج واحد على الأقل')),
      );
      return;
    }

    final success = await controller.createFreePurchase(
      shopId: '008', // TODO: Get actual shop ID from user context
      description: 'شراء حر',
      notes: 'تم إنشاء هذا الشراء من تطبيق شيرا',
    );

    if (success) {
      // Show success dialog
      if (!context.mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تم الحفظ'),
          content: Text(
              'تمت عملية الشراء بنجاح\nالمبلغ الإجمالي: ${controller.totalAmount.value.toStringAsFixed(2)} أوقية'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Return to previous screen
              },
              child: const Text('موافق'),
            ),
          ],
        ),
      );
    } else {
      // Show error message
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء حفظ عملية الشراء: ${controller.errorMessage.value}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('شراء حر (بدون طلب)'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              controller.resetForm();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Form fields
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text(
                                'إضافة منتج جديد',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Droid',
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Product name
                              CustomInput(
                                controller: _productController,
                                hintText: 'اسم المنتج',
                              ),

                              // Quantity
                              CustomInputNumber(
                                controller: _quantityController,
                                hintText: 'الكمية',
                              ),

                              // Toggle between unit price and total price
                              Row(
                                children: [
                                  const SizedBox(width: 20),
                                  Obx(() => SizedBox(
                                    width: 250,
                                    child: controller.showTotalPriceField.value
                                        ? CustomInputNumber(
                                            controller: _totalPriceController,
                                            hintText: 'السعر الإجمالي',
                                          )
                                        : CustomInputNumber(
                                            controller: _unitPriceController,
                                            hintText: 'سعر الفرد',
                                          ),
                                  )),
                                  Obx(() => IconButton(
                                    icon: Icon(controller.showTotalPriceField.value
                                        ? Icons.swap_horiz
                                        : Icons.swap_vert),
                                    onPressed: () {
                                      controller.togglePriceField();
                                      if (controller.showTotalPriceField.value) {
                                        _unitPriceController.clear();
                                      } else {
                                        _totalPriceController.clear();
                                      }
                                    },
                                    tooltip: controller.showTotalPriceField.value
                                        ? 'إدخال سعر الفرد'
                                        : 'إدخال السعر الإجمالي',
                                  )),
                                ],
                              ),

                              // Add/Update button
                              SizedBox(
                                width: double.infinity,
                                child: Obx(() => ElevatedButton.icon(
                                  onPressed: () => _addOrUpdateProduct(context),
                                  icon: Icon(editingIndex.value == -1
                                      ? Icons.add
                                      : Icons.edit),
                                  label: Text(
                                    editingIndex.value == -1
                                        ? 'إضافة المنتج'
                                        : 'تحديث المنتج',
                                    style: const TextStyle(fontFamily: 'Droid'),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: greenCustomColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                )),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Products list header
                      const Text(
                        'المنتجات المضافة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Droid',
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Table header
                      Container(
                        decoration: BoxDecoration(
                          color: greenCustomColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        child: const Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: Text('المنتج',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Droid'))),
                            Expanded(
                                flex: 2,
                                child: Text('الكمية',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Droid'),
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text('سعر الفرد',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Droid'),
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text('سعر الجملة',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Droid'),
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 1,
                                child: Text('',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Droid'))),
                          ],
                        ),
                      ),

                      // Products list
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight * 0.4,
                        ),
                        child: Obx(() => controller.addedProducts.isEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'لم يتم إضافة أي منتج بعد',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: 'Droid',
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemCount: controller.addedProducts.length,
                                itemBuilder: (context, index) {
                                  final product = controller.addedProducts[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey[200]!),
                                      ),
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            product['product'],
                                            style: const TextStyle(
                                                fontFamily: 'Droid'),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            product['quantity'].toString(),
                                            style: const TextStyle(
                                                fontFamily: 'Droid'),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            product['unitPrice']
                                                .toStringAsFixed(2),
                                            style: const TextStyle(
                                                fontFamily: 'Droid'),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            product['totalPrice']
                                                .toStringAsFixed(2),
                                            style: const TextStyle(
                                              fontFamily: 'Droid',
                                              fontWeight: FontWeight.bold,
                                              color: greenCustomColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: PopupMenuButton(
                                            icon: const Icon(Icons.more_vert,
                                                size: 20),
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit, size: 16),
                                                    SizedBox(width: 8),
                                                    Text('تعديل',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Droid')),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete,
                                                        size: 16,
                                                        color: Colors.red),
                                                    SizedBox(width: 8),
                                                    Text('حذف',
                                                        style: TextStyle(
                                                            fontFamily: 'Droid',
                                                            color: Colors.red)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                _editProduct(index);
                                              } else if (value == 'delete') {
                                                controller.removeProduct(index);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )),
                      ),

                      // Total amount
                      Obx(() => controller.addedProducts.isNotEmpty
                          ? Container(
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: greenCustomColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: greenCustomColor),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'المبلغ الإجمالي:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Droid',
                                    ),
                                  ),
                                  Text(
                                    '${controller.totalAmount.value.toStringAsFixed(2)} أوقية',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: greenCustomColor,
                                      fontFamily: 'Droid',
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox()),

                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: Obx(() => ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : () => _savePurchase(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: greenCustomColor,
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: controller.isLoading.value
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : const Text(
                                          'حفظ عملية الشراء',
                                          style: TextStyle(
                                            fontFamily: 'Droid',
                                            color: whiteColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                )),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: CustomButton(
                                  text: 'إلغاء',
                                  onPressed: () {
                                    controller.resetForm();
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
