import 'package:trixo_frontend/features/shop/domain/entity/customer.dart';

class CustomerMapper {
  String id;
  String? email;
  String? name;
  String? phone;
  Map<String, dynamic>? address;

  CustomerMapper({
    required this.id,
    this.email,
    this.name,
    this.phone,
    this.address,
  });

  factory CustomerMapper.fromJson(Map<String, dynamic> json) {
    return CustomerMapper(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  Customer toEntity() {
    return Customer(
      id: id,
      email: email,
      name: name,
      phone: phone,
      address: address,
    );
  }
}
