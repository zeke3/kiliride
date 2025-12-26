import 'package:kiliride/shared/funcs.main.ctrl.dart';

class Currency {
  final int id;
  final String code;
  final String symbol;

  Currency({
    required this.id,
    required this.code,
    required this.symbol,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      symbol: json['symbol'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'symbol': symbol,
    };
  }

  String formatAmount(double amount) {
    return '$symbol ${Funcs().formatNumberWithThousandSeparator(number: amount)}';
  }
}
