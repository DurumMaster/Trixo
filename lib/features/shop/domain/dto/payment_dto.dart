class PaymentDto {
  int? amount;
  String? currency;
  String? customerID;

  PaymentDto({this.amount, this.currency, this.customerID});

  factory PaymentDto.fromJson(Map<String, dynamic> json) {
    return PaymentDto(
      amount: json['amount'] as int?,
      currency: json['currency'] as String?,
      customerID: json['customerID'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      'customerID': customerID,
    };
  }
}