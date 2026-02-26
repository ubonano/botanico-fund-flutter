import 'package:get_it/get_it.dart';
import 'package:botanico_fund_flutter/core/services/fund_repository.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<FundRepository>(() => FundRepository());
}
