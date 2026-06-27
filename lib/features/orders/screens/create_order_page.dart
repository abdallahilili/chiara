import 'package:chira/common/utils/colors.dart';
import 'package:chira/common/widgets/custom_button.dart';
import 'package:chira/common/widgets/custom_input.dart';
import 'package:chira/common/widgets/custom_input_number.dart';
import 'package:chira/features/orders/controllers/orders_controller.dart';
import 'package:chira/features/orders/screens/create_order_affect_vendeur.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateOrderPage extends StatelessWidget {
  CreateOrderPage({Key? key}) : super(key: key);

  // Injection du controller GetX
  final OrdersController controller = Get.put(OrdersController());
  
  // Controllers pour les champs de texte
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  
  // Index du produit en cours de modification
  final RxInt editingIndex = (-1).obs;

  void _addOrUpdateProduct() {
    String product = _productController.text.trim();
    String quantity = _quantityController.text.trim();
    String unit = _unitController.text.trim();

    if (product.isNotEmpty && quantity.isNotEmpty) {
      if (editingIndex.value == -1) {
        // Ajout d'un nouveau produit
        controller.addProduct({
          'product': product,
          'quantity': quantity,
          'unit': unit,
        });
      } else {
        // Mise à jour d'un produit existant
        controller.updateProduct(editingIndex.value, {
          'product': product,
          'quantity': quantity,
          'unit': unit,
        });
        editingIndex.value = -1; // Réinitialiser après mise à jour
      }

      // Vider les champs après l'ajout ou la mise à jour
      _productController.clear();
      _quantityController.clear();
      _unitController.clear();
    }
  }

  void _editProduct(int index) {
    _productController.text = controller.addedProducts[index]['product'];
    _quantityController.text = controller.addedProducts[index]['quantity'];
    _unitController.text = controller.addedProducts[index]['unit'];
    editingIndex.value = index; // Stocker l'index de l'élément en cours de modification
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
            onPressed: () {
              controller.resetForm();
              Navigator.of(context).pop();
            },
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
                  Obx(() => IconButton(
                    icon: Icon(
                      editingIndex.value == -1 ? Icons.add_circle : Icons.edit,
                      color: Colors.green,
                      size: 40,
                    ),
                    onPressed: _addOrUpdateProduct,
                  )),
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
                child: Obx(() => ListView.builder(
                  itemCount: controller.addedProducts.length,
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
                            controller.removeProduct(index);
                          },
                        ),
                        title: GestureDetector(
                          onTap: () => _editProduct(index), // Remplir le formulaire au clic
                          child: Text(
                            controller.addedProducts[index]['product'],
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
                            '${controller.addedProducts[index]['quantity']} ${controller.addedProducts[index]['unit'] ?? 'وحدة'}',
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
                )),
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
                            addedProducts: controller.addedProducts,
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
                        onPressed: () {
                          controller.resetForm();
                          Navigator.of(context).pop();
                        }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
