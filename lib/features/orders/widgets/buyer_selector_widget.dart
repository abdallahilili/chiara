import 'package:flutter/material.dart';

class BuyerSelectorWidget extends StatelessWidget {
  final Map<String, String> buyersMap;
  final String? selectedBuyer;
  final Function(String?) onBuyerChanged;

  const BuyerSelectorWidget({
    Key? key,
    required this.buyersMap,
    required this.selectedBuyer,
    required this.onBuyerChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 42, 100, 45), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      value: selectedBuyer,
      items: buyersMap.keys
          .map((buyer) => DropdownMenuItem(value: buyer, child: Text(buyer)))
          .toList(),
      onChanged: onBuyerChanged,
    );
  }
}
