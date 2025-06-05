import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class AddressBottomSheet extends StatefulWidget {
  const AddressBottomSheet({super.key});

  @override
  _AddressBottomSheetState createState() => _AddressBottomSheetState();
}

class _AddressBottomSheetState extends State<AddressBottomSheet> {
  final TextEditingController _line1Controller = TextEditingController();
  final TextEditingController _line2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

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
            'Address',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _line1Controller,
            decoration: const InputDecoration(labelText: 'Line 1'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _line2Controller,
            decoration: const InputDecoration(labelText: 'Line 2'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _cityController,
            decoration: const InputDecoration(labelText: 'City'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _stateController,
            decoration: const InputDecoration(labelText: 'State'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _postalCodeController,
            decoration: const InputDecoration(labelText: 'Postal Code'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _countryController,
            decoration: const InputDecoration(labelText: 'Country'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final address = Address(
                country: _countryController.text.trim(),
                city: _cityController.text.trim(),
                line1: _line1Controller.text.trim(),
                line2: _line2Controller.text.trim(),
                state: _stateController.text.trim(),
                postalCode: _postalCodeController.text.trim(),
              );
              Navigator.pop(context, address);
            },
            child: const Text('Guardar Dirección'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
