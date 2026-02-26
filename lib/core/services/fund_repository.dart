import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fund_state.dart';
import '../models/fund_config.dart';
import '../models/investor.dart';
import '../models/operation.dart';

class FundRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream for Fund Config
  Stream<FundConfig?> streamFundConfig() {
    return _firestore.collection('config').doc('fund').snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return FundConfig.fromMap(snapshot.data()!);
      }
      return null;
    });
  }

  // Stream for Current Fund State
  Stream<FundState?> streamCurrentFundState() {
    return _firestore.collection('fund_state').doc('current').snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return FundState.fromMap(snapshot.data()!);
      }
      return null;
    });
  }

  // Stream for Investors List
  Stream<List<Investor>> streamInvestors() {
    return _firestore.collection('investors').orderBy('current_shares', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Investor.fromMap(doc.id, doc.data())).toList();
    });
  }

  // Stream for Investor Operations
  Stream<List<Operation>> streamInvestorOperations(String investorId) {
    return _firestore
        .collection('investors')
        .doc(investorId)
        .collection('operations')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Operation.fromMap(doc.id, doc.data())).toList();
        });
  }
}
