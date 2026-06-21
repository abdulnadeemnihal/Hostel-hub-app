import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/block_model.dart';
import '../models/room_model.dart';
import '../utils/constants.dart';

class BlockService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<BlockModel>> getAllBlocks() {
    return _db.collection(AppConstants.blocksCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => BlockModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<DocumentReference> addBlock(BlockModel block) async {
    return await _db.collection(AppConstants.blocksCollection).add(block.toMap());
  }

  Future<void> updateBlock(String id, Map<String, dynamic> data) async {
    await _db.collection(AppConstants.blocksCollection).doc(id).update(data);
  }

  Future<void> deleteBlock(String id) async {
    await _db.collection(AppConstants.blocksCollection).doc(id).delete();
  }

  Future<void> deleteRoomsForBlock(String blockId) async {
    final roomsSnapshot = await _db
        .collection(AppConstants.roomsCollection)
        .where('blockId', isEqualTo: blockId)
        .get();
    final batch = _db.batch();
    for (final doc in roomsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> addRoom(RoomModel room) async {
    await _db.collection(AppConstants.roomsCollection).add(room.toMap());
  }

  Future<void> deleteRoom(String id) async {
    await _db.collection(AppConstants.roomsCollection).doc(id).delete();
  }
}
