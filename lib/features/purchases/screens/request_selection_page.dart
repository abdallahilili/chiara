import 'package:chira/common/utils/colors.dart';
import 'package:chira/features/orders/repositories/orders_repository.dart';
import 'package:chira/features/purchases/screens/request_based_purchase_page.dart';
import 'package:chira/models/request_model.dart';
import 'package:flutter/material.dart';

class RequestSelectionPage extends StatefulWidget {
  final String shopId;

  const RequestSelectionPage({super.key, required this.shopId});

  @override
  _RequestSelectionPageState createState() => _RequestSelectionPageState();
}

class _RequestSelectionPageState extends State<RequestSelectionPage> {
  List<RequestModel> _requests = [];
  RequestModel? _selectedRequest;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final requests =
          await OrdersRepository.getShopRequests(widget.shopId).first;
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء تحميل الطلبات')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اختيار طلبية'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'الطلبيات المتاحة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Droid',
                      ),
                    ),
                  ),
                  Expanded(
                    child: _requests.isEmpty
                        ? const Center(
                            child: Text(
                              'لا توجد طلبيات متاحة',
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Droid',
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _requests.length,
                            itemBuilder: (context, index) {
                              final request = _requests[index];
                              return // Dans votre ListView.builder, remplacez le Card actuel par ceci:
                                  Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedRequest = request;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'طلب #${request.id.substring(0, 8)}',
                                              style: const TextStyle(
                                                fontFamily: 'Droid',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Radio<RequestModel>(
                                              value: request,
                                              groupValue: _selectedRequest,
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedRequest = value;
                                                });
                                              },
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 8),

                                        // Date et nombre de produits
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today,
                                                size: 16,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              request.createdAt
                                                  .toString()
                                                  .substring(0, 10),
                                              style: TextStyle(
                                                fontFamily: 'Droid',
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(Icons.shopping_basket,
                                                size: 16,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${request.produits.length} منتج',
                                              style: TextStyle(
                                                fontFamily: 'Droid',
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),

                                        if (request.description?.isNotEmpty ??
                                            false) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            'الوصف: ${request.description}',
                                            style: const TextStyle(
                                              fontFamily: 'Droid',
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],

                                        if (request.montant?.isNotEmpty ??
                                            false) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            'المبلغ المقترح: ${request.montant} أوقية',
                                            style: TextStyle(
                                              fontFamily: 'Droid',
                                              color: greenCustomColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _selectedRequest != null
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RequestBasedPurchasePage(
                                          request: _selectedRequest!,
                                          shopId: widget.shopId,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greenCustomColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'المتابعة إلى الشراء',
                              style: TextStyle(
                                fontFamily: 'Droid',
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
