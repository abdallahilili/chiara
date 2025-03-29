import 'package:chira/common/widgets/custom_button.dart';
import 'package:chira/common/widgets/custom_input.dart';
import 'package:chira/common/widgets/custom_input_number.dart';
import 'package:flutter/material.dart';

class CreateOrderPage extends StatefulWidget {
  @override
  _CreateOrderPageState createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  // Controllers for text input fields
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // List to store added products
  List<Map<String, dynamic>> _addedProducts = [];

  void _addProduct() {
    String product = _productController.text.trim();
    String quantity = _quantityController.text.trim();

    if (product.isNotEmpty && quantity.isNotEmpty) {
      setState(() {
        _addedProducts.add({
          'product': product,
          'quantity': quantity,
        });

        // Clear input fields after adding
        _productController.clear();
        _quantityController.clear();
      });
    }
  }

  void _naviagate_pop() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('إنشاء طبلية'),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product input row
              Row(
                children: [
                  Expanded(
                    child: CustomInput(
                      controller: _productController,
                      hintText: 'المنتج',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CustomInputNumber(
                      controller: _quantityController,
                      hintText: 'الكمية',
                      width: 320,
                      height: 50,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.green, size: 40),
                    onPressed: _addProduct,
                  ),
                ],
              ),

              SizedBox(height: 20),

              // List of added products
              Text(
                ' المنتجات المضافة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _addedProducts.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_addedProducts[index]['product']),
                      trailing: Text(_addedProducts[index]['quantity']),
                      leading: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _addedProducts.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement save logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('تم الحفظ')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text('حفظ'),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child:
                        CustomButton(text: 'إلغاء', onPressed: _naviagate_pop),

                    // ElevatedButton(
                    //   onPressed: () => Navigator.of(context).pop(),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.red,
                    //   ),
                    //   child: Text('إلغاء'),
                    // ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    _productController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
