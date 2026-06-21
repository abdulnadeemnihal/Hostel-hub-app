import 'package:cloud_firestore/cloud_firestore.dart';
import 'floor_config_model.dart';

class BlockModel {
  final String id;
  final String name;
  final int floorCount;
  final bool sameRoomsPerFloor;
  final int roomsPerFloor;
  final List<FloorConfig> floors;
  final Timestamp createdAt;

  BlockModel({
    required this.id,
    required this.name,
    required this.floorCount,
    required this.sameRoomsPerFloor,
    required this.roomsPerFloor,
    required this.floors,
    required this.createdAt,
  });

  factory BlockModel.fromMap(Map<String, dynamic> map, String id) {
    return BlockModel(
      id: id,
      name: map['name'] ?? '',
      floorCount: map['floorCount'] ?? 0,
      sameRoomsPerFloor: map['sameRoomsPerFloor'] ?? true,
      roomsPerFloor: map['roomsPerFloor'] ?? 0,
      floors: (map['floors'] as List<dynamic>? ?? [])
          .map((item) => FloorConfig.fromMap(item as Map<String, dynamic>))
          .toList(),
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'floorCount': floorCount,
      'sameRoomsPerFloor': sameRoomsPerFloor,
      'roomsPerFloor': roomsPerFloor,
      'floors': floors.map((floor) => floor.toMap()).toList(),
      'createdAt': createdAt,
    };
  }
}
