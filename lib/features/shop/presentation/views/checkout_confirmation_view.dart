import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:trixo_frontend/features/shared/widgets/custom_text_field_form.dart';
import 'package:trixo_frontend/features/shared/widgets/checkout_summary.dart';
import 'package:trixo_frontend/features/shop/presentation/views/address_bottom_sheet.dart';
import 'package:trixo_frontend/features/shop/presentation/views/card_bottom_sheet.dart';

//TODO: Cambiar a ComsumerWidget para acceder a los metodos del provider.
class CheckoutConfirmationView extends StatefulWidget {
  const CheckoutConfirmationView({super.key});

  @override
  _CheckoutConfirmationViewState createState() => _CheckoutConfirmationViewState();
}

class _CheckoutConfirmationViewState extends State<CheckoutConfirmationView> {
  stripe.BillingDetails? _billingDetails;
  stripe.CardFieldInputDetails? _cardDetails;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _showAddressBottomSheet() async {
    final stripe.Address? result = await showModalBottomSheet<stripe.Address>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const AddressBottomSheet(),
    );

    if (result != null) {
      setState(() {
        _billingDetails = stripe.BillingDetails(
          address: result,
          name: _billingDetails?.name,
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
        );
      });
    }
  }
  //TODO: Revisar porque no se abre y porque peta la app. | Mirar main y meter Stripe.settings?
  Future<void> _showCardBottomSheet() async {
    final stripe.CardFieldInputDetails? result = await showModalBottomSheet<stripe.CardFieldInputDetails>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const CardBottomSheet(),
    );

    if (result != null && result.complete) {
      setState(() {
        _cardDetails = result;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                      controller: _phoneController,
                      label: 'Phone',
                      hint: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un teléfono';
                        }
                        return null;
                      },
                    ),
                    const Divider(height: 32),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _showAddressBottomSheet,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Dirección'),
                          Text(_billingDetails?.address?.line1 ?? 'Agregar dirección'),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _showCardBottomSheet,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.credit_card),
                          Text(
                            _cardDetails != null
                                ? '**** **** ${_cardDetails!.last4 ?? '----'}'
                                : 'Agregar tarjeta',
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          CheckoutSummary(
            subtotal: 200,
            delivery: 200,
            total: 400,
            onCheckout: () {
              if (_billingDetails == null || _cardDetails == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor completa todos los campos')),
                );
                return;
              }

              //TODO: Primero buscar al Customer con getCustomer y 
              //TODO: utilizar los datos para pasar un PaymentDto a insertCardToCustomer
              //TODO: utilizar addCardToCustomer para meter dentro del usuario toda la informacion (si no existe?)

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pago procesado con éxito')),
              );
            },
          ),
        ],
      ),
    );
  }
}
