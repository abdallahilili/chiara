import 'package:chira/common/utils/colors.dart';
import 'package:chira/common/widgets/custom_button.dart';
import 'package:chira/common/widgets/custom_input.dart';
import 'package:chira/common/widgets/custom_input_number.dart';
import 'package:chira/features/purchases/repository/free_purchase_repository.dart';
import 'package:flutter/material.dart';

class FreePurchasePage extends StatefulWidget {
  const FreePurchasePage({super.key});

  @override
  _FreePurchasePageState createState() => _FreePurchasePageState();
}

class _FreePurchasePageState extends State<FreePurchasePage> {
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _totalPriceController = TextEditingController();

  List<Map<String, dynamic>> _addedProducts = [];
  int? _editingIndex;
  double _totalAmount = 0.0;
  bool _showTotalPriceField = false;

  void _addOrUpdateProduct() {
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
      totalPrice = quantity * unitPrice;
    } else {
      // Si l'utilisateur a entré le prix total
      totalPrice = double.tryParse(totalPriceStr) ?? 0;
      unitPrice = quantity != 0 ? totalPrice / quantity : 0;
    }

    setState(() {
      if (_editingIndex == null) {
        // Ajout d'un nouveau produit
        _addedProducts.add({
          'product': product,
          'quantity': quantity,
          'unitPrice': unitPrice,
          'totalPrice': totalPrice,
        });
      } else {
        // Mise à jour d'un produit existant
        _addedProducts[_editingIndex!] = {
          'product': product,
          'quantity': quantity,
          'unitPrice': unitPrice,
          'totalPrice': totalPrice,
        };
        _editingIndex = null;
      }

      // Calculer le montant total
      _calculateTotalAmount();

      // Vider les champs
      _productController.clear();
      _quantityController.clear();
      _unitPriceController.clear();
      _totalPriceController.clear();
    });
  }

  void _editProduct(int index) {
    setState(() {
      _productController.text = _addedProducts[index]['product'];
      _quantityController.text = _addedProducts[index]['quantity'].toString();
      _unitPriceController.text =
          _addedProducts[index]['unitPrice'].toStringAsFixed(2);
      _totalPriceController.text =
          _addedProducts[index]['totalPrice'].toStringAsFixed(2);
      _editingIndex = index;
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _addedProducts.removeAt(index);
      _calculateTotalAmount();
    });
  }

  void _calculateTotalAmount() {
    _totalAmount = _addedProducts.fold(0.0, (sum, product) {
      return sum + (product['totalPrice'] as double);
    });
  }

  Future<void> _savePurchase() async {
    if (_addedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إضافة منتج واحد على الأقل')),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Save purchase to Firebase
      await FreePurchaseRepository.createFreePurchase(
        shopId: '008', // TODO: Get actual shop ID from user context
        products: _addedProducts,
        description: 'شراء حر',
        notes: 'تم إنشاء هذا الشراء من تطبيق شيرا',
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تم الحفظ'),
          content: Text(
              'تمت عملية الشراء بنجاح\nالمبلغ الإجمالي: ${_totalAmount.toStringAsFixed(2)} أوقية'),
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
    } catch (e) {
      // Close loading dialog if open
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء حفظ عملية الشراء: ${e.toString()}'),
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
            onPressed: () => Navigator.of(context).pop(),
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
                                   const SizedBox(width: 20,),
                                  SizedBox(
                                    width: 250, // أو أي قيمة تناسب التصميم
                                    child: _showTotalPriceField
                                        ? CustomInputNumber(
                                            controller: _totalPriceController,
                                            hintText: 'السعر الإجمالي',
                                          )
                                        : CustomInputNumber(
                                            controller: _unitPriceController,
                                            hintText: 'سعر الفرد',
                                          ),
                                  ),
                                  IconButton(
                                    icon: Icon(_showTotalPriceField
                                        ? Icons.swap_horiz
                                        : Icons.swap_vert),
                                    onPressed: () {
                                      setState(() {
                                        _showTotalPriceField =
                                            !_showTotalPriceField;
                                        if (_showTotalPriceField) {
                                          _unitPriceController.clear();
                                        } else {
                                          _totalPriceController.clear();
                                        }
                                      });
                                    },
                                    tooltip: _showTotalPriceField
                                        ? 'إدخال سعر الفرد'
                                        : 'إدخال السعر الإجمالي',
                                  ),
                                 
                                ],
                              ),

                              // Add/Update button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _addOrUpdateProduct,
                                  icon: Icon(_editingIndex == null
                                      ? Icons.add
                                      : Icons.edit),
                                  label: Text(
                                    _editingIndex == null
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
                                ),
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
                        child: _addedProducts.isEmpty
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
                                itemCount: _addedProducts.length,
                                itemBuilder: (context, index) {
                                  final product = _addedProducts[index];
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
                                                _removeProduct(index);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),

                      // Total amount
                      if (_addedProducts.isNotEmpty)
                        Container(
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
                                '${_totalAmount.toStringAsFixed(2)} أوقية',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: greenCustomColor,
                                  fontFamily: 'Droid',
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _savePurchase,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: greenCustomColor,
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text(
                                    'حفظ عملية الشراء',
                                    style: TextStyle(
                                      fontFamily: 'Droid',
                                      color: whiteColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: CustomButton(
                                  text: 'إلغاء',
                                  onPressed: () => Navigator.of(context).pop(),
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

  @override
  void dispose() {
    _productController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _totalPriceController.dispose();
    super.dispose();
  }
}
