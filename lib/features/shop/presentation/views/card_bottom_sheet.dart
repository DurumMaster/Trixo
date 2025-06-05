import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class CardBottomSheet extends StatefulWidget {
  const CardBottomSheet({super.key});

  @override
  _CardBottomSheetState createState() => _CardBottomSheetState();
}

class _CardBottomSheetState extends State<CardBottomSheet> {
  CardFieldInputDetails? _localCardDetails;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Card Details',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          CardField(
            onCardChanged: (card) {
              setState(() {
                _localCardDetails = card;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _localCardDetails?.complete == true ? Colors.black : Colors.grey.shade400,
              foregroundColor: _localCardDetails?.complete == true ? Colors.white : Colors.grey.shade700,
              side: _localCardDetails?.complete == true
                  ? const BorderSide(color: Colors.white)
                  : null,
            ),
            onPressed: _localCardDetails?.complete == true
                ? () {
                    Navigator.pop(context, _localCardDetails);
                  }
                : null,
            child: const Text('Guardar Tarjeta'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}