import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:trixo_frontend/features/shared/widgets/custom_text_field_form.dart';
import 'package:trixo_frontend/features/shared/widgets/checkout_summary.dart';
import 'package:trixo_frontend/features/shop/domain/entity/customer.dart';
import 'package:trixo_frontend/features/shop/presentation/providers/shop_provider.dart';
import 'package:trixo_frontend/features/shop/presentation/views/address_bottom_sheet.dart';

final billingDetailsProvider = StateProvider<stripe.BillingDetails?>((ref) => null);
final cardDetailsProvider = StateProvider<stripe.CardFieldInputDetails?>((ref) => null);
final saveCardConsentProvider = StateProvider<bool>((ref) => false);

class CheckoutConfirmationView extends ConsumerStatefulWidget {
  final int amount;
  const CheckoutConfirmationView({super.key, this.amount = 100});

  @override
  ConsumerState<CheckoutConfirmationView> createState() => _CheckoutConfirmationViewState();
}

class _CheckoutConfirmationViewState extends ConsumerState<CheckoutConfirmationView> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCustomerAndCardDetails();   
  }

  Future<void> _loadCustomerAndCardDetails() async {
    final user = FirebaseAuth.instance.currentUser;

    final email = user?.email;

    if (email == null || email.isEmpty) return;

    final customer = await ref.read(shopProvider).getCustomer(email);
    if (customer != null) {
      // Actualiza billingDetailsProvider
      ref.read(billingDetailsProvider.notifier).state = stripe.BillingDetails(
        name: customer.name,
        email: customer.email,
        phone: customer.phone,
        address: stripe.Address(
          city: customer.address?['city'] ?? '',
          country: customer.address?['country'] ?? '',
          line1: customer.address?['line1'] ?? '',
          line2: customer.address?['line2'] ?? '',
          postalCode: customer.address?['postalCode'] ?? '',
          state: customer.address?['state'] ?? '',
        ),
      );

      // Opcional: mostrar que tiene tarjeta guardada
      final hasSavedCard = await ref.read(shopProvider).hasSavedPaymentMethod(customer.id);
      if (hasSavedCard) {
        ref.read(saveCardConsentProvider.notifier).state = true;
      }
    }
  }

  Future<void> _showAddressBottomSheet(BuildContext context, WidgetRef ref) async {
    final stripe.Address? result = await showModalBottomSheet<stripe.Address>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const AddressBottomSheet(),
    );

    if (result != null) {
      final currentBilling = ref.read(billingDetailsProvider);
      ref.read(billingDetailsProvider.notifier).state = stripe.BillingDetails(
        address: result,
        name: currentBilling?.name,
        email: currentBilling?.email,
        phone: currentBilling?.phone,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final billingDetails = ref.watch(billingDetailsProvider);
    final cardDetails = ref.watch(cardDetailsProvider);

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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BillingForm(
                      billingDetails: billingDetails,
                      onBillingDetailsChanged: (newDetails) {
                        ref.read(billingDetailsProvider.notifier).state = newDetails;
                      },
                      onShowAddressSheet: () => _showAddressBottomSheet(context, ref),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Detalles de la Tarjeta',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    if (ref.watch(saveCardConsentProvider)) ...[
                      const Text(
                        'Ya tienes una tarjeta guardada. Puedes usarla o ingresar otra.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                    ],
                    stripe.CardField(
                      onCardChanged: (card) {
                        ref.read(cardDetailsProvider.notifier).state = card;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Número de tarjeta',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: ref.watch(saveCardConsentProvider),
                          onChanged: (val) {
                            ref.read(saveCardConsentProvider.notifier).state = val ?? false;
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'Guardar tarjeta para futuras compras',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          _isLoading? const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ): CheckoutSummary(
              subtotal: widget.amount.toDouble(),
              delivery: widget.amount != 0 ? 20.0 : 0.0,
              total: widget.amount.toDouble() + (widget.amount != 0 ? 20.0 : 0.0),
              onCheckout: () async {
              if (_isLoading) return;

              setState(() {
                _isLoading = true;
              });

              try {
                if (billingDetails == null || cardDetails == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor completa todos los campos')),
                  );
                  return;
                }

                String id;
                Customer? customer = await ref.read(shopProvider).getCustomer(billingDetails.email ?? '');
                id = customer?.id ?? '';

                if (customer == null) {
                  id = await ref.read(shopProvider).registerCustomer(
                    Customer(
                      id: '',
                      email: billingDetails.email,
                      name: billingDetails.name,
                      phone: billingDetails.phone,
                      gdprConsent: ref.read(saveCardConsentProvider),
                      address: {
                        'line1': billingDetails.address?.line1,
                        'line2': billingDetails.address?.line2,
                        'city': billingDetails.address?.city,
                        'country': billingDetails.address?.country,
                        'postalCode': billingDetails.address?.postalCode,
                        'state': billingDetails.address?.state,
                      },
                    ),
                  );
                }

                if (cardDetails.complete) {
                  final paymentMethod = await stripe.Stripe.instance.createPaymentMethod(
                    params: stripe.PaymentMethodParams.card(
                      paymentMethodData: stripe.PaymentMethodData(
                        billingDetails: billingDetails,
                      ),
                    ),
                  );

                  await ref.read(shopProvider).addCardToCustomer(
                    Customer(
                      id: id,
                      email: billingDetails.email,
                      name: billingDetails.name,
                      phone: billingDetails.phone,
                      address: {
                        'line1': billingDetails.address?.line1,
                        'line2': billingDetails.address?.line2,
                        'city': billingDetails.address?.city,
                        'country': billingDetails.address?.country,
                        'postalCode': billingDetails.address?.postalCode,
                        'state': billingDetails.address?.state,
                      },
                    ),
                    widget.amount,
                    paymentMethod,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pago realizado exitosamente')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor completa los detalles de la tarjeta')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
          )
        ],
      ),
    );
  }
}

class BillingForm extends StatefulWidget {
  final stripe.BillingDetails? billingDetails;
  final ValueChanged<stripe.BillingDetails> onBillingDetailsChanged;
  final VoidCallback onShowAddressSheet;

  const BillingForm({
    required this.billingDetails,
    required this.onBillingDetailsChanged,
    required this.onShowAddressSheet,
    super.key,
  });

  @override
  State<BillingForm> createState() => _BillingFormState();
}

class _BillingFormState extends State<BillingForm> {
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.billingDetails?.email ?? '');
    _phoneController = TextEditingController(text: widget.billingDetails?.phone ?? '');
    _nameController = TextEditingController(text: widget.billingDetails?.name ?? '');
  }

  @override
  void didUpdateWidget(covariant BillingForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.billingDetails?.email != _emailController.text) {
      _emailController.text = widget.billingDetails?.email ?? '';
    }
    if (widget.billingDetails?.phone != _phoneController.text) {
      _phoneController.text = widget.billingDetails?.phone ?? '';
    }
    if (widget.billingDetails?.name != _nameController.text) {
      _nameController.text = widget.billingDetails?.name ?? '';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onEmailChanged(String val) {
    widget.onBillingDetailsChanged(
      (widget.billingDetails ?? const stripe.BillingDetails()).copyWith(email: val.trim()),
    );
  }

  void _onPhoneChanged(String val) {
    widget.onBillingDetailsChanged(
      (widget.billingDetails ?? const stripe.BillingDetails()).copyWith(phone: val.trim()),
    );
  }

  void _onNameChanged(String val) {
    widget.onBillingDetailsChanged(
      (widget.billingDetails ?? const stripe.BillingDetails()).copyWith(name: val.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextFormField(
          controller: _nameController,
          label: 'Nombre',
          hint: 'Introduce tu nombre',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa un nombre';
            }
            return null;
          },
          onChanged: _onNameChanged,
        ),
        const SizedBox(height: 20),
        CustomTextFormField(
          controller: _emailController,
          label: 'Email',
          hint: 'Introduce tu email',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa un email';
            }
            return null;
          },
          onChanged: _onEmailChanged,
        ),
        const SizedBox(height: 20),
        CustomTextFormField(
          controller: _phoneController,
          label: 'Teléfono',
          hint: 'Introduce tu número de teléfono',
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa un teléfono';
            }
            return null;
          },
          onChanged: _onPhoneChanged,
        ),
        const Divider(height: 32),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: widget.onShowAddressSheet,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Dirección'),
              Text(widget.billingDetails?.address?.line1 ?? 'Agregar dirección'),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
