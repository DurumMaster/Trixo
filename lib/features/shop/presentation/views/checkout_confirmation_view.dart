import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:go_router/go_router.dart';
import 'package:trixo_frontend/features/shared/widgets/custom_text_field_form.dart';
import 'package:trixo_frontend/features/shared/widgets/checkout_summary.dart';
import 'package:trixo_frontend/features/shop/domain/entity/customer.dart';
import 'package:trixo_frontend/features/shop/presentation/providers/shop_providers.dart';
import 'package:trixo_frontend/features/shop/presentation/views/address_bottom_sheet.dart';

final billingDetailsProvider =
    StateProvider<stripe.BillingDetails?>((ref) => null);
final cardDetailsProvider =
    StateProvider<stripe.CardFieldInputDetails?>((ref) => null);
final saveCardConsentProvider = StateProvider<bool>((ref) => false);

class CheckoutConfirmationView extends ConsumerStatefulWidget {
  final double subtotal;
  final double delivery;
  final double total;

  const CheckoutConfirmationView({
    super.key,
    required this.subtotal,
    required this.delivery,
    required this.total,
  });

  @override
  ConsumerState<CheckoutConfirmationView> createState() =>
      _CheckoutConfirmationViewState();
}

class _CheckoutConfirmationViewState
    extends ConsumerState<CheckoutConfirmationView> {
  final bool _isLoading = false;
  final GlobalKey<_BillingFormState> _billingFormKey =
      GlobalKey<_BillingFormState>();

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
        name: (customer.name!.isNotEmpty) ? customer.name : user?.displayName,
        email: (customer.email!.isNotEmpty) ? customer.email : user?.email,
        phone:
            (customer.phone!.isNotEmpty) ? customer.phone : user?.phoneNumber,
        address: stripe.Address(
          city: customer.address?['city'] ?? '',
          country: customer.address?['country'],
          line1: customer.address?['line1'] ?? '',
          line2: customer.address?['line2'] ?? '',
          postalCode: customer.address?['postalCode'] ?? '',
          state: customer.address?['state'] ?? '',
        ),
      );

      // Opcional: mostrar que tiene tarjeta guardada
      final hasSavedCard =
          await ref.read(shopProvider).hasSavedPaymentMethod(customer.id);
      if (hasSavedCard) {
        ref.read(saveCardConsentProvider.notifier).state = true;
      }
    } else {
      ref.read(billingDetailsProvider.notifier).state = stripe.BillingDetails(
        name: user?.displayName,
        email: user?.email,
        phone: user?.phoneNumber,
        address: null,
      );
    }
  }

  Future<void> _showAddressBottomSheet(
      BuildContext context, WidgetRef ref) async {
    final stripe.Address? result = await showModalBottomSheet<stripe.Address>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AddressForm(
        initialAddress: stripe.Address(
          line1: ref.read(billingDetailsProvider)?.address?.line1,
          line2: ref.read(billingDetailsProvider)?.address?.line2,
          city: ref.read(billingDetailsProvider)?.address?.city,
          state: ref.read(billingDetailsProvider)?.address?.state,
          postalCode: ref.read(billingDetailsProvider)?.address?.postalCode,
          country: ref.read(billingDetailsProvider)?.address?.country,
        ),
      ),
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
    final int amount = (widget.total * 100).round();

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: isDark
                    ? Colors.white
                    : Colors.black), // o Colors.white si es dark
            onPressed: () {
              context.pop();
            }),
        title: Text(
          'Datos de Pedido',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BillingForm(
                        key: _billingFormKey,
                        billingDetails: billingDetails,
                        onBillingDetailsChanged: (newDetails) {
                          ref.read(billingDetailsProvider.notifier).state =
                              newDetails;
                        },
                        onShowAddressSheet: () =>
                            _showAddressBottomSheet(context, ref),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Detalles de la Tarjeta',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
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
                              ref.read(saveCardConsentProvider.notifier).state =
                                  val ?? false;
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
            const SizedBox(height: 6),
            _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                : CheckoutSummary(
                    subtotal: widget.subtotal,
                    delivery: widget.delivery,
                    total: widget.total,
                    onCheckout: () async {
                      try {
                        final billingFormState = _billingFormKey.currentState;
                        if (billingFormState == null ||
                            !billingFormState.validateForm()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Por favor completa correctamente el formulario')),
                          );
                          return;
                        }

                        if (billingDetails == null || cardDetails == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Por favor completa todos los campos')),
                          );
                          return;
                        }

                        String id;
                        Customer? customer = await ref
                            .read(shopProvider)
                            .getCustomer(billingDetails.email ?? '');
                        id = customer?.id ?? '';

                        if (customer == null) {
                          id = await ref.read(shopProvider).registerCustomer(
                                Customer(
                                  id: '',
                                  email: billingDetails.email,
                                  name: billingDetails.name,
                                  phone: billingDetails.phone,
                                  gdprConsent:
                                      ref.read(saveCardConsentProvider),
                                  address: {
                                    'line1': billingDetails.address?.line1,
                                    'line2': billingDetails.address?.line2,
                                    'city': billingDetails.address?.city,
                                    'country': billingDetails.address?.country,
                                    'postalCode':
                                        billingDetails.address?.postalCode,
                                    'state': billingDetails.address?.state,
                                  },
                                ),
                              );
                        } else {
                          await ref.read(shopProvider).updateCustomer(
                                Customer(
                                  id: id,
                                  email: billingDetails.email ?? '',
                                  name: billingDetails.name ?? '',
                                  phone: billingDetails.phone ?? '',
                                  gdprConsent:
                                      ref.read(saveCardConsentProvider),
                                  address: {
                                    'line1':
                                        billingDetails.address?.line1 ?? '',
                                    'line2':
                                        billingDetails.address?.line2 ?? '',
                                    'city': billingDetails.address?.city ?? '',
                                    'country': billingDetails.address?.country,
                                    'postalCode':
                                        billingDetails.address?.postalCode ??
                                            '',
                                    'state':
                                        billingDetails.address?.state ?? '',
                                  },
                                ),
                              );
                        }

                        if (cardDetails.complete) {
                          final paymentMethod =
                              await stripe.Stripe.instance.createPaymentMethod(
                            params: stripe.PaymentMethodParams.card(
                              paymentMethodData: stripe.PaymentMethodData(
                                billingDetails: billingDetails,
                              ),
                            ),
                          );

                          await ref.read(shopProvider).addCardToCustomer(
                                Customer(
                                  id: id,
                                  email: billingDetails.email ?? '',
                                  name: billingDetails.name ?? '',
                                  phone: billingDetails.phone ?? '',
                                  gdprConsent:
                                      ref.read(saveCardConsentProvider),
                                  address: {
                                    'line1':
                                        billingDetails.address?.line1 ?? '',
                                    'line2':
                                        billingDetails.address?.line2 ?? '',
                                    'city': billingDetails.address?.city ?? '',
                                    'country': billingDetails.address?.country,
                                    'postalCode':
                                        billingDetails.address?.postalCode ??
                                            '',
                                    'state':
                                        billingDetails.address?.state ?? '',
                                  },
                                ),
                                amount,
                                paymentMethod,
                              );

                          Map<int, int> productos = ref
                              .read(cartProvider.notifier)
                              .getProductQuantities();

                          await ref.read(shopProvider).reduceStock(productos);

                          ref.read(cartProvider.notifier).clearCart();
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const SuccessDialog(),
                            );
                          }
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Por favor completa los detalles de la tarjeta')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Ha ocurrido un error al realizar el pago')),
                          );
                        }
                      }
                    },
                  )
          ],
        ),
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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController =
        TextEditingController(text: widget.billingDetails?.email ?? '');
    _phoneController =
        TextEditingController(text: widget.billingDetails?.phone ?? '');
    _nameController =
        TextEditingController(text: widget.billingDetails?.name ?? '');
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
      (widget.billingDetails ?? const stripe.BillingDetails())
          .copyWith(email: val.trim()),
    );
  }

  void _onPhoneChanged(String val) {
    widget.onBillingDetailsChanged(
      (widget.billingDetails ?? const stripe.BillingDetails())
          .copyWith(phone: val.trim()),
    );
  }

  void _onNameChanged(String val) {
    widget.onBillingDetailsChanged(
      (widget.billingDetails ?? const stripe.BillingDetails())
          .copyWith(name: val.trim()),
    );
  }

  bool validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  bool _isAddressComplete(stripe.Address? address) {
    if (address == null) return false;

    return (address.line1?.isNotEmpty ?? false) &&
        (address.city?.isNotEmpty ?? false) &&
        (address.country?.isNotEmpty ?? false) &&
        (address.postalCode?.isNotEmpty ?? false) &&
        (address.state?.isNotEmpty ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: [
          CustomTextFormField(
            controller: _nameController,
            label: 'Nombre',
            hint: 'Introduce tu nombre',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
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
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingresa un email';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Email inválido';
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
              final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
              if (!phoneRegex.hasMatch(value.trim())) {
                return 'Teléfono inválido';
              }
              return null;
            },
            onChanged: _onPhoneChanged,
          ),
          const Divider(height: 32),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: widget.onShowAddressSheet,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Dirección'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.billingDetails?.address?.line1 ??
                            'Agregar dirección',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _isAddressComplete(widget.billingDetails?.address)
                      ? const Icon(Icons.check_circle,
                          color: Colors.green, size: 20)
                      : const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ]));
  }
}

// Widget personalizado para el popup de éxito
class SuccessDialog extends StatelessWidget {
  const SuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color:
              isDark ? colorScheme.outline : colorScheme.primary.withAlpha(77),
          width: 1,
        ),
      ),
      elevation: 8,
      backgroundColor: isDark ? colorScheme.surface : colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.greenAccent[400],
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              '¡Compra exitosa!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? colorScheme.onSurface : colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tu pedido ha sido procesado correctamente',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface.withAlpha(204),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/shop');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? colorScheme.primaryContainer : colorScheme.primary,
                foregroundColor: isDark
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onPrimary,
                minimumSize: const Size(180, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                elevation: 2,
                shadowColor: isDark
                    ? Colors.transparent
                    : colorScheme.primary.withAlpha(77),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
