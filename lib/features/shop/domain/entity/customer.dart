class Customer {
  final String id;
  final String? email;
  final String? name;
  final String? phone;
  final bool? gdprConsent;
  final Map<String, dynamic>? address;

  Customer({
    required this.id,
    this.email,
    this.name,
    this.phone,
    this.gdprConsent,
    this.address,
  });
}
