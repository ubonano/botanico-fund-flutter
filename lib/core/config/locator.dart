import 'package:get_it/get_it.dart';
import 'package:botanico_fund_flutter/core/services/fund_repository.dart';
import 'package:botanico_fund_flutter/core/services/fund_functions_service.dart';
import 'package:botanico_fund_flutter/core/services/auth_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<AuthService>(() => AuthService());
  locator.registerLazySingleton<FundRepository>(() => FundRepository());
  locator.registerLazySingleton<FundFunctionsService>(() => FundFunctionsService());
}
