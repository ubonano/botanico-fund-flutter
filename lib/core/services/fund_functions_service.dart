import 'package:cloud_functions/cloud_functions.dart';

class FundFunctionsService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<String> processCapitalMovement({
    required String investorId,
    required String type,
    required double amountUsd,
  }) async {
    final callable = _functions.httpsCallable('processMovement');

    final result = await callable.call({'investorId': investorId, 'type': type, 'amountUsd': amountUsd});

    return result.data.toString();
  }

  Future<String> updateWallet({required String walletAddress}) async {
    final callable = _functions.httpsCallable('updateWallet');

    final result = await callable.call({'walletAddress': walletAddress});

    return result.data.toString();
  }

  Future<String> createInvestor({required String name, required String lastName}) async {
    final callable = _functions.httpsCallable('createInvestor');

    final result = await callable.call({'name': name, 'lastName': lastName});

    return result.data.toString();
  }

  Future<String> processCommissions({required double amountUsd}) async {
    final callable = _functions.httpsCallable('processCommissions');

    final result = await callable.call({'amountUsd': amountUsd});

    return result.data.toString();
  }

  Future<String> cleanupSnapshots() async {
    final callable = _functions.httpsCallable('cleanupSnapshots');

    final result = await callable.call();

    return result.data.toString();
  }
}
