import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fund_state.dart';
import '../models/fund_snapshot.dart';
import '../models/fund_config.dart';
import '../models/investor.dart';
import '../models/investor_snapshot.dart';
import '../models/operation.dart';
import '../models/bot_state.dart';
import '../models/bot_snapshot.dart';

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

  // Stream for a single Investor by ID
  Stream<Investor?> streamInvestor(String investorId) {
    return _firestore.collection('investors').doc(investorId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return Investor.fromMap(snapshot.id, snapshot.data()!);
      }
      return null;
    });
  }

  // Stream for Investor Snapshots (last 30 days, ascending by timestamp)
  Stream<List<InvestorSnapshot>> streamInvestorSnapshots(String investorId) {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _firestore
        .collection('investors')
        .doc(investorId)
        .collection('snapshots')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => InvestorSnapshot.fromMap(doc.id, doc.data())).toList();
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

  // Stream for Latest Fund Snapshot
  Stream<FundSnapshot?> streamLatestSnapshot() {
    return _firestore.collection('snapshots').orderBy('timestamp', descending: true).limit(1).snapshots().map((
      snapshot,
    ) {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return FundSnapshot.fromMap(doc.id, doc.data());
      }
      return null;
    });
  }

  // Update Investor fields (name, last_name, commission_rate)
  Future<void> updateInvestor(String investorId, Map<String, dynamic> data) async {
    await _firestore.collection('investors').doc(investorId).update(data);
  }

  // Update Fund Config field
  Future<void> updateFundConfig(Map<String, dynamic> data) async {
    await _firestore.collection('config').doc('fund').update(data);
  }

  // Stream for Bot State (current)
  Stream<BotState?> streamBotState() {
    return _firestore.collection('bot_state').doc('current').snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return BotState.fromMap(snapshot.data()!);
      }
      return null;
    });
  }

  // Stream for Bot Enabled status
  Stream<bool> streamBotEnabled() {
    return _firestore.collection('botanico_state').doc('bot_config').snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['enabled'] == true;
      }
      return false;
    });
  }

  // Stream for full Bot Config
  Stream<Map<String, dynamic>> streamBotConfig() {
    return _firestore.collection('botanico_state').doc('bot_config').snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!;
      }
      return <String, dynamic>{};
    });
  }

  // Update Bot Config fields
  Future<void> updateBotConfig(Map<String, dynamic> data) async {
    await _firestore.collection('botanico_state').doc('bot_config').set(data, SetOptions(merge: true));
  }

  // Stream for Bot Snapshots (last 30 days, ascending by timestamp)
  Stream<List<BotSnapshot>> streamBotSnapshots() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _firestore
        .collection('bot_snapshots')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => BotSnapshot.fromMap(doc.id, doc.data())).toList();
        });
  }
}
