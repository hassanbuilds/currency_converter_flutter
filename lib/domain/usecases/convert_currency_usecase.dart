import 'package:courency_converter/data/repositories/currency_repository.dart';
import '../models/currecny_conversion.dart';

class ConvertCurrencyUseCase {
  final CurrencyRepository _repository; //  store repository

  ConvertCurrencyUseCase(this._repository); //  proper constructor

  double execute(String fromCurrency, String toCurrency, double amount) {
    // Use repository to convert (better than using constants directly)
    return _repository.convert(
      amount: amount,
      from: fromCurrency,
      to: toCurrency,
    );
  }

  CurrencyConversion createConversion(
    String fromCurrency,
    String toCurrency,
    double amount,
  ) {
    final result = execute(fromCurrency, toCurrency, amount);
    return CurrencyConversion(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      amount: amount,
      result: result,
    );
  }
}
