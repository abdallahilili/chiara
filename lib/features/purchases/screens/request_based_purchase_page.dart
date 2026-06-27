// request_based_purchase_page.dart
import 'package:chira/common/utils/colors.dart';
import 'package:chira/common/widgets/custom_button.dart';
import 'package:chira/common/widgets/custom_input_number.dart';
import 'package:chira/models/request_model.dart';
import 'package:chira/features/purchases/repository/free_purchase_repository.dart';
import 'package:flutter/material.dart';

class RequestBasedPurchasePage extends StatefulWidget {
  final RequestModel request;
  final String shopId;

  const RequestBasedPurchasePage({
    super.key,
    required this.request,
    required this.shopId,
  });

  @override
  _RequestBasedPurchasePageState createState() => _RequestBasedPurchasePageState();
}

class _RequestBasedPurchasePageState extends State<RequestBasedPurchasePage> {
  List<Map<String, dynamic>> _productsWithPrices = [];
  List<TextEditingController> _quantityControllers = [];
  List<TextEditingController> _unitPriceControllers = [];
  List<TextEditingController> _totalPriceControllers = [];
  double _totalAmount = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // تحويل منتجات الطلب إلى تنسيق الشراء
    _productsWithPrices = widget.request.produits.map((product) {
      return {
        'product': product.nom,
        'quantity': product.quantite.toDouble(),
        'unit': product.unite,
        'unitPrice': 0.0,
        'totalPrice': 0.0,
      };
    }).toList();

    // إنشاء TextEditingController لكل منتج
    for (int i = 0; i < _productsWithPrices.length; i++) {
      _quantityControllers.add(TextEditingController(
        text: _productsWithPrices[i]['quantity'].toInt().toString()
      ));
      _unitPriceControllers.add(TextEditingController());
      _totalPriceControllers.add(TextEditingController());
    }

    _setupListeners();
  }

  void _setupListeners() {
    for (int i = 0; i < _productsWithPrices.length; i++) {
      // Listener للكمية
      _quantityControllers[i].addListener(() {
        _updateQuantity(i, _quantityControllers[i].text);
      });

      // Listener لسعر الوحدة
      _unitPriceControllers[i].addListener(() {
        if (_unitPriceControllers[i].text.isNotEmpty) {
          _updateUnitPrice(i, _unitPriceControllers[i].text);
        }
      });

      // Listener للسعر الإجمالي
      _totalPriceControllers[i].addListener(() {
        if (_totalPriceControllers[i].text.isNotEmpty) {
          _updateTotalPrice(i, _totalPriceControllers[i].text);
        }
      });
    }
  }

  void _updateQuantity(int index, String quantityStr) {
    final quantity = double.tryParse(quantityStr) ?? 0.0;
    setState(() {
      _productsWithPrices[index]['quantity'] = quantity;
      // إعادة حساب السعر الإجمالي بناءً على الكمية الجديدة والسعر الوحدة
      final unitPrice = _productsWithPrices[index]['unitPrice'];
      final newTotalPrice = quantity * unitPrice;
      _productsWithPrices[index]['totalPrice'] = newTotalPrice;
      _totalPriceControllers[index].text = newTotalPrice == 0.0 ? '' : newTotalPrice.toStringAsFixed(2);
      _calculateTotalAmount();
    });
  }

  void _updateUnitPrice(int index, String priceStr) {
    final unitPrice = double.tryParse(priceStr) ?? 0.0;
    final quantity = _productsWithPrices[index]['quantity'];
    setState(() {
      _productsWithPrices[index]['unitPrice'] = unitPrice;
      final totalPrice = unitPrice * quantity;
      _productsWithPrices[index]['totalPrice'] = totalPrice;
      _totalPriceControllers[index].text = totalPrice == 0.0 ? '' : totalPrice.toStringAsFixed(2);
      _calculateTotalAmount();
    });
  }

  void _updateTotalPrice(int index, String totalPriceStr) {
    final totalPrice = double.tryParse(totalPriceStr) ?? 0.0;
    final quantity = _productsWithPrices[index]['quantity'];
    setState(() {
      _productsWithPrices[index]['totalPrice'] = totalPrice;
      final unitPrice = quantity > 0 ? totalPrice / quantity : 0.0;
      _productsWithPrices[index]['unitPrice'] = unitPrice;
      _unitPriceControllers[index].text = unitPrice == 0.0 ? '' : unitPrice.toStringAsFixed(2);
      _calculateTotalAmount();
    });
  }

  void _calculateTotalAmount() {
    _totalAmount = _productsWithPrices.fold(0.0, (sum, product) {
      return sum + (product['totalPrice'] as double);
    });
  }

  @override
  void dispose() {
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    for (var controller in _unitPriceControllers) {
      controller.dispose();
    }
    for (var controller in _totalPriceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _savePurchase() async {
    try {
      // التحقق من إدخال جميع البيانات المطلوبة
      for (int i = 0; i < _productsWithPrices.length; i++) {
        final product = _productsWithPrices[i];
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

      setState(() {
        _isLoading = true;
      });

      // حفظ عملية الشراء في Firebase
      await FreePurchaseRepository.createFreePurchase(
        shopId: widget.shopId,
        products: _productsWithPrices,
        description: 'شراء مبني على الطلب ${widget.request.id}',
        notes: 'تم إنشاء الطلب في ${widget.request.createdAt}',
      );

      setState(() {
        _isLoading = false;
      });

      // عرض نافذة النجاح
      if (!mounted) return;
      
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
              'تم حفظ الشراء المبني على الطلب بنجاح\nالمبلغ الإجمالي: ${_totalAmount.toStringAsFixed(2)} أوقية',
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
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حفظ عملية الشراء: ${e.toString()}'),
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
                // معلومات الطلب
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رقم الطلب: #${widget.request.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Droid',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'تاريخ الطلب: ${widget.request.createdAt.toString().split(' ')[0]}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'Droid',
                        ),
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
                      ...List.generate(_productsWithPrices.length, (index) {
                        final product = _productsWithPrices[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: index == _productsWithPrices.length - 1 
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
                                  child: CustomInputNumber(
                                    controller: _quantityControllers[index],
                                    hintText: '0',
                                    height: 40,
                                    fontSize: 14,
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
                                  child: CustomInputNumber(
                                    controller: _unitPriceControllers[index],
                                    hintText: '0.00',
                                    height: 40,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              
                              // السعر الإجمالي
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: CustomInputNumber(
                                    controller: _totalPriceControllers[index],
                                    hintText: '0.00',
                                    height: 40,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // المبلغ الإجمالي
                Container(
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
                      Text(
                        '${_totalAmount.toStringAsFixed(2)} أوقية',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Droid',
                        ),
                      ),
                      const Text(
                        'المبلغ الإجمالي:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Droid',
                        ),
                      ),
                    ],
                  ),
                ),
                
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
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _savePurchase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenCustomColor,
                          minimumSize: const Size(150, 50),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: _isLoading
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
                      ),
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