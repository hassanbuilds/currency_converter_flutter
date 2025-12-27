import 'package:courency_converter/core/theme/app_theme.dart';
import 'package:courency_converter/core/utils/chart_helper.dart';
import 'package:courency_converter/data/datasources/local/currency_local_datasource.dart';
import 'package:courency_converter/data/datasources/local/preferences_datasource.dart';
import 'package:courency_converter/data/datasources/remote/currency_remote_datasource.dart';
import 'package:courency_converter/data/repositories/currency_repository_impl.dart';
import 'package:courency_converter/data/repositories/preferences_repository_impl.dart';
import 'package:courency_converter/domain/usecases/convert_currency_usecase.dart';
import 'package:courency_converter/domain/usecases/get_exchange_rates_usecase.dart';
import 'package:courency_converter/domain/usecases/get_history_usecase.dart';
import 'package:courency_converter/presentation/viewmodels/currency_converter_provider.dart';
import 'package:courency_converter/presentation/views/currency_converter_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _createProvider(),
      child: const AppWrapper(),
    );
  }

  CurrencyConverterProvider _createProvider() {
    final remoteDataSource = CurrencyRemoteDataSource();
    final localDataSource = CurrencyLocalDataSource();
    final preferencesDataSource = PreferencesDataSource();
    final chartHelper = ChartHelper();

    final currencyRepository = CurrencyRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      chartHelper: chartHelper,
    );

    final preferencesRepository = PreferencesRepositoryImpl(
      preferencesDataSource,
    );

    final convertUseCase = ConvertCurrencyUseCase(currencyRepository);
    final getRatesUseCase = GetExchangeRatesUseCase(currencyRepository);
    final getHistoryUseCase = GetHistoryUseCase(preferencesRepository);

    return CurrencyConverterProvider(
      convertUseCase: convertUseCase,
      getRatesUseCase: getRatesUseCase,
      getHistoryUseCase: getHistoryUseCase,
      preferencesRepository: preferencesRepository,
    );
  }
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyConverterProvider>(
      builder: (context, provider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme:
              provider.isDarkMode
                  ? AppTheme.darkTheme(context)
                  : AppTheme.lightTheme(context),
          home: const CurrencyConverterScreen(),
        );
      },
    );
  }
}
