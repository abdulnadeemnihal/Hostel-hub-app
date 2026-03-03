import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../models/room_model.dart';
import '../../utils/constants.dart';

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Room Management',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              // Room stats
              _MiniStat('Total', '${data.totalRooms}', Colors.blue),
              const SizedBox(width: 8),
              _MiniStat('Occupied', '${data.occupiedRooms}', Colors.orange),
              const SizedBox(width: 8),
              _MiniStat('Available', '${data.availableRooms}', Colors.green),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddRoomDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Room'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: data.rooms.isEmpty
                ? const Center(child: Text('No rooms added yet', style: TextStyle(color: Colors.grey)))
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3,
                    ),
                    itemCount: data.rooms.length,
                    itemBuilder: (context, index) {
                      final room = data.rooms[index];
                      return _RoomCard(room: room);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddRoomDialog(BuildContext context) {
    final roomNumCtrl = TextEditingController();
    String block = AppConstants.hostelBlocks.first;
    int capacity = 2;
    int floor = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add New Room'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roomNumCtrl,
                decoration: const InputDecoration(labelText: 'Room Number'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: block,
                decoration: const InputDecoration(labelText: 'Block'),
                items: AppConstants.hostelBlocks
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (v) => setDialogState(() => block = v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: floor,
                      decoration: const InputDecoration(labelText: 'Floor'),
                      items: List.generate(5, (i) => i + 1)
                          .map((f) => DropdownMenuItem(value: f, child: Text('$f')))
                          .toList(),
                      onChanged: (v) => setDialogState(() => floor = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: capacity,
                      decoration: const InputDecoration(labelText: 'Capacity'),
                      items: [1, 2, 3, 4]
                          .map((c) => DropdownMenuItem(value: c, child: Text('$c')))
                          .toList(),
                      onChanged: (v) => setDialogState(() => capacity = v!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (roomNumCtrl.text.isEmpty) return;
                final room = RoomModel(
                  id: '',
                  roomNumber: roomNumCtrl.text,
                  block: block,
                  floor: floor,
                  capacity: capacity,
                  occupied: 0,
                  roomType: capacity == 1 ? 'Single' : capacity == 2 ? 'Double' : 'Triple',
                  occupantIds: [],
                  occupantNames: [],
                  isAvailable: true,
                  amenities: ['Wi-Fi', 'Fan', 'Desk', 'Cupboard', 'Bed'],
                );
                await context.read<DataProvider>().addRoom(room);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Add Room'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomModel room;
  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    final occupancyRatio = room.capacity > 0 ? room.occupied / room.capacity : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Room ${room.roomNumber}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: room.isFull ? Colors.red.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    room.isFull ? 'Full' : 'Available',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: room.isFull ? Colors.red : Colors.green),
                  ),
                ),
              ],
            ),
            Text('${room.block} • Floor ${room.floor}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const Spacer(),
            LinearProgressIndicator(
              value: occupancyRatio,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(occupancyRatio >= 1 ? Colors.red : Colors.green),
            ),
            const SizedBox(height: 4),
            Text('${room.occupied}/${room.capacity} Occupied',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            if (room.occupantNames.isNotEmpty)
              Text(room.occupantNames.join(', '),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
