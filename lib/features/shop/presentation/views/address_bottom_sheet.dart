import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class AddressForm extends StatefulWidget {
  final Address? initialAddress;

  const AddressForm({super.key, this.initialAddress});

  @override
  AddressFormState createState() => AddressFormState();
}

class AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _line1Controller;
  late final TextEditingController _line2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;

  @override
  void initState() {
    super.initState();

    // Usamos los datos del Address inicial si se pasa
    final address = widget.initialAddress;

    _line1Controller = TextEditingController(text: address?.line1 ?? '');
    _line2Controller = TextEditingController(text: address?.line2 ?? '');
    _cityController = TextEditingController(text: address?.city ?? '');
    _stateController = TextEditingController(text: address?.state ?? '');
    _postalCodeController =
        TextEditingController(text: address?.postalCode ?? '');
    _countryController = TextEditingController(text: address?.country ?? '');
  }

  @override
  void dispose() {
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;

    return Container(
      color: backgroundColor,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Dirección',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _line1Controller,
                decoration: const InputDecoration(
                  hintText: 'Calle',
                  prefixIcon: Icon(Icons.home),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _line2Controller,
                decoration: const InputDecoration(
                  hintText: 'Portal y piso',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        hintText: 'Ciudad',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      maxLines: 2,
                      validator: (value) =>
                          value!.isEmpty ? 'Este campo es requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        hintText: 'Provincia/Estado',
                        prefixIcon: Icon(Icons.map),
                      ),
                      maxLines: 2,
                      validator: (value) =>
                          value!.isEmpty ? 'Este campo es requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _postalCodeController,
                      decoration: const InputDecoration(
                        hintText: 'Código Postal',
                        prefixIcon: Icon(Icons.local_post_office),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Este campo es requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        hintText: 'País',
                        prefixIcon: Icon(Icons.flag_circle_sharp),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Este campo es requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.save, color: Colors.white),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final address = Address(
                      country: _countryController.text.trim().toUpperCase() == 'ESPAÑA'
                          ? 'ES'
                          : _countryController.text.trim(),
                      city: _cityController.text.trim(),
                      line1: _line1Controller.text.trim(),
                      line2: _line2Controller.text.trim(),
                      state: _stateController.text.trim(),
                      postalCode: _postalCodeController.text.trim(),
                    );
                    Navigator.pop(context, address);
                  }
                },
                label: const Text(
                  'Guardar Dirección',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF1E1E1E)
                      : Theme.of(context).primaryColor,
                  foregroundColor: Colors.white, // color del ripple
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
