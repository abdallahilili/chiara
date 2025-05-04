import 'package:chira/common/utils/colors.dart';
import 'package:chira/common/widgets/custom_button.dart';
import 'package:chira/common/widgets/custom_input.dart';
import 'package:chira/common/widgets/custom_input_number.dart';
import 'package:chira/features/orders/screens/create_order_affect_vendeur.dart';
import 'package:flutter/material.dart';

class CreateOrderPage extends StatefulWidget {
// liste des produits ajoutés

  @override
  _CreateOrderPageState createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  // Liste des produits ajoutés

  List<Map<String, dynamic>> _addedProducts = [];
  int? _editingIndex; // Index du produit en cours de modification

  void _addOrUpdateProduct() {
    String product = _productController.text.trim();
    String quantity = _quantityController.text.trim();
    String unit = _unitController.text.trim();

    if (product.isNotEmpty && quantity.isNotEmpty) {
      setState(() {
        if (_editingIndex == null) {
          // Ajout d'un nouveau produit
          _addedProducts.add({
            'product': product,
            'quantity': quantity,
            'unit': unit,
          });
        } else {
          // Mise à jour d'un produit existant
          _addedProducts[_editingIndex!] = {
            'product': product,
            'quantity': quantity,
            'unit': unit,
          };
          _editingIndex = null; // Réinitialiser après mise à jour
        }

        // Vider les champs après l'ajout ou la mise à jour
        _productController.clear();
        _quantityController.clear();
        _unitController.clear();
      });
    }
  }

  void _editProduct(int index) {
    setState(() {
      _productController.text = _addedProducts[index]['product'];
      _quantityController.text = _addedProducts[index]['quantity'];
      _unitController.text = _addedProducts[index]['unit'];
      _editingIndex =
          index; // Stocker l'index de l'élément en cours de modification
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إنشاء طبلية'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomInput(
                      controller: _productController,
                      hintText: 'المنتج',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: CustomInputNumber(
                      controller: _quantityController,
                      hintText: 'الكمية',
                      width: 50,
                      height: 50,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: CustomInput(
                      controller: _unitController,
                      hintText: 'الوحدة',
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Icon(
                      _editingIndex == null ? Icons.add_circle : Icons.edit,
                      color: Colors.green,
                      size: 40,
                    ),
                    onPressed: _addOrUpdateProduct,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
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
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 10),
                        leading: IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red, size: 30),
                          onPressed: () {
                            setState(() {
                              _addedProducts.removeAt(index);
                            });
                          },
                        ),
                        title: GestureDetector(
                          onTap: () => _editProduct(
                              index), // Remplir le formulaire au clic
                          child: Text(
                            _addedProducts[index]['product'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Droid',
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_addedProducts[index]['quantity']} ${_addedProducts[index]['unit'] ?? 'وحدة'}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Droid',
                              color: greenCustomColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateOrderAffectVendeurPage(
                            addedProducts: _addedProducts,
                            shopId: '008', // إرسال قائمة المنتجات
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenCustomColor,
                      minimumSize: const Size(150, 50),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'إنشاء الطلبية',
                      style: TextStyle(
                        fontFamily: 'Droid',
                        color: whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                        text: 'إلغاء',
                        onPressed: () => Navigator.of(context).pop()),
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
    _productController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }
}
