import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/block_model.dart';
import '../../providers/data_provider.dart';

class FloorDetailScreen extends StatelessWidget {
  final BlockModel block;
  final int floorNumber;

  const FloorDetailScreen({required this.block, required this.floorNumber, super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final rooms = data.roomsForFloor(block.id, floorNumber);

    return Scaffold(
      appBar: AppBar(
        title: Text('${block.name} • Floor $floorNumber'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: rooms.isEmpty
            ? const Center(child: Text('No rooms found on this floor', style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return Card(
                    child: ListTile(
                      title: Text('Room ${room.roomNumber}'),
                      subtitle: Text('${room.capacity}-sharing • ${room.occupied}/${room.capacity} occupied'),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Room ${room.roomNumber}'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Capacity: ${room.capacity}'),
                                Text('Occupied: ${room.occupied}'),
                                Text('Availability: ${room.isAvailable ? 'Available' : 'Full'}'),
                                const SizedBox(height: 12),
                                const Text('Occupants:', style: TextStyle(fontWeight: FontWeight.bold)),
                                if (room.occupantNames.isEmpty)
                                  const Text('No students assigned yet'),
                                for (final occupant in room.occupantNames)
                                  Text(occupant),
                              ],
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
