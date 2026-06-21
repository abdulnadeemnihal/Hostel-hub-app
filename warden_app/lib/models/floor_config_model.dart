class FloorConfig {
  final int floorNumber;
  final int roomsCount;
  final List<int> roomSharings;

  FloorConfig({
    required this.floorNumber,
    required this.roomsCount,
    required this.roomSharings,
  });

  factory FloorConfig.fromMap(Map<String, dynamic> map) {
    return FloorConfig(
      floorNumber: map['floorNumber'] ?? 0,
      roomsCount: map['roomsCount'] ?? 0,
      roomSharings: List<int>.from(map['roomSharings'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'floorNumber': floorNumber,
      'roomsCount': roomsCount,
      'roomSharings': roomSharings,
    };
  }
}
