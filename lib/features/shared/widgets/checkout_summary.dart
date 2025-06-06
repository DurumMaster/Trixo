import 'package:flutter/material.dart';
import 'package:trixo_frontend/features/shared/widgets/custom_loading_button.dart';

class CheckoutSummary extends StatelessWidget {
  final double? subtotal;
  final double? delivery;
  final double? total;
  final Future<void> Function()? onCheckout;

  const CheckoutSummary({
    super.key,
    this.subtotal,
    this.delivery,
    this.total,
    this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _priceRow('Subtotal', '${subtotal ?? 0}€'),
              const SizedBox(height: 6),
              _priceRow('Envío', '${delivery ?? 0}€'),
              const Divider(height: 20, thickness: 0.7, color: Colors.black26),
              _priceRow('Total', '${total ?? 0}€', isBold: true),
              const SizedBox(height: 16),
             SizedBox(
              width: double.infinity,
              child: MUILoadingButton(
                text: 'Confirmar',
                loadingStateText: 'Procesando...',
                onPressed: onCheckout,
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            )),
        Text(value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            )),
      ],
    );
  }
}
