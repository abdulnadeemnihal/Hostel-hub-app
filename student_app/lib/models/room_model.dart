class RoomModel {
  final String id;
  final String roomNumber;
  final String block;
  final int floor;
  final int capacity;
  final int occupied;
  final String roomType;
  final List<String> occupantIds;
  final List<String> occupantNames;
  final bool isAvailable;
  final List<String> amenities;

  RoomModel({
    required this.id,
    required this.roomNumber,
    required this.block,
    required this.floor,
    required this.capacity,
    required this.occupied,
    required this.roomType,
    required this.occupantIds,
    required this.occupantNames,
    required this.isAvailable,
    required this.amenities,
  });

  factory RoomModel.fromMap(Map<String, dynamic> map, String id) {
    return RoomModel(
      id: id,
      roomNumber: map['roomNumber'] ?? '',
      block: map['block'] ?? '',
      floor: map['floor'] ?? 0,
      capacity: map['capacity'] ?? 2,
      occupied: map['occupied'] ?? 0,
      roomType: map['roomType'] ?? 'double',
      occupantIds: List<String>.from(map['occupantIds'] ?? []),
      occupantNames: List<String>.from(map['occupantNames'] ?? []),
      isAvailable: map['isAvailable'] ?? true,
      amenities: List<String>.from(map['amenities'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomNumber': roomNumber,
      'block': block,
      'floor': floor,
      'capacity': capacity,
      'occupied': occupied,
      'roomType': roomType,
      'occupantIds': occupantIds,
      'occupantNames': occupantNames,
      'isAvailable': isAvailable,
      'amenities': amenities,
    };
  }

  bool get isFull => occupied >= capacity;
  int get vacancies => capacity - occupied;
}
