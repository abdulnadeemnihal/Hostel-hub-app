import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/block_model.dart';
import '../../models/floor_config_model.dart';
import '../../providers/data_provider.dart';
import '../../utils/constants.dart';
import 'block_detail_screen.dart';

class BlockListScreen extends StatefulWidget {
  const BlockListScreen({super.key});

  @override
  State<BlockListScreen> createState() => _BlockListScreenState();
}

class _BlockListScreenState extends State<BlockListScreen> {
  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final blocks = data.blocks;

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
              ElevatedButton.icon(
                onPressed: () => _showAddBlockDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Block'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: blocks.isEmpty
                ? const Center(child: Text('No blocks added yet', style: TextStyle(color: Colors.grey)))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 360,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: blocks.length,
                    itemBuilder: (context, index) {
                      final block = blocks[index];
                      return _BlockCard(block: block);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, String activeValue, List<String> values, ValueChanged<String> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        ...values.map((value) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(value),
                selected: activeValue == value,
                onSelected: (_) => onChanged(value),
              ),
            )),
      ],
    );
  }

  void _showAddBlockDialog(BuildContext context) {
    final nameCtr = TextEditingController();
    int floorCount = 1;
    bool sameRoomsPerFloor = true;
    int roomsPerFloor = 1;
    final floorConfigs = <FloorConfig>[];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Create New Block'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtr,
                  decoration: const InputDecoration(labelText: 'Block Name'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: floorCount,
                        decoration: const InputDecoration(labelText: 'Floors'),
                        items: List.generate(6, (index) => index + 1)
                            .map((floor) => DropdownMenuItem(value: floor, child: Text('$floor')))
                            .toList(),
                        onChanged: (value) => setState(() => floorCount = value ?? 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _showSharingAllocationDialog(
                            ctx,
                            floorCount,
                            roomsPerFloor,
                            sameRoomsPerFloor,
                            floorConfigs,
                            setState,
                          );
                        },
                        child: const Text('Sharing allocation for rooms'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: sameRoomsPerFloor,
                  title: const Text('Same rooms per floor'),
                  subtitle: const Text('If off, configure rooms per floor manually'),
                  onChanged: (value) => setState(() {
                    sameRoomsPerFloor = value;
                    floorConfigs.clear();
                  }),
                ),
                if (sameRoomsPerFloor) ...[
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Rooms per floor'),
                    onChanged: (value) => setState(() {
                      roomsPerFloor = int.tryParse(value) ?? roomsPerFloor;
                    }),
                  ),
                ] else ...[
                  for (var i = 1; i <= floorCount; i++)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text('Floor $i')),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 96,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Rooms'),
                              onChanged: (value) {
                                final count = int.tryParse(value) ?? 0;
                                final index = floorConfigs.indexWhere((cfg) => cfg.floorNumber == i);
                                if (index >= 0) {
                                  final existing = floorConfigs[index];
                                  floorConfigs[index] = FloorConfig(
                                    floorNumber: i,
                                    roomsCount: count,
                                    roomSharings: existing.roomSharings.length >= count
                                        ? existing.roomSharings.sublist(0, count)
                                        : List<int>.filled(count, existing.roomSharings.isNotEmpty ? existing.roomSharings.first : 2),
                                  );
                                } else {
                                  floorConfigs.add(FloorConfig(
                                    floorNumber: i,
                                    roomsCount: count,
                                    roomSharings: List<int>.filled(count, 2),
                                  ));
                                }
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtr.text.trim().isEmpty) return;
                final block = BlockModel(
                  id: '',
                  name: nameCtr.text.trim(),
                  floorCount: floorCount,
                  sameRoomsPerFloor: sameRoomsPerFloor,
                  roomsPerFloor: roomsPerFloor,
                  floors: sameRoomsPerFloor
                      ? floorConfigs.isNotEmpty
                          ? floorConfigs
                          : List.generate(
                              floorCount,
                              (index) => FloorConfig(
                                floorNumber: index + 1,
                                roomsCount: roomsPerFloor,
                                roomSharings: List<int>.filled(roomsPerFloor, 2),
                              ),
                            )
                      : floorConfigs,
                  createdAt: Timestamp.now(),
                );
                await context.read<DataProvider>().createBlock(block);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Create Block'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSharingAllocationDialog(
    BuildContext ctx,
    int floorCount,
    int roomsPerFloor,
    bool sameRoomsPerFloor,
    List<FloorConfig> floorConfigs,
    void Function(void Function()) setParentState,
  ) {
    showDialog(
      context: ctx,
      builder: (ctx) {
        final dialogFloorConfigs = floorConfigs.map((cfg) => FloorConfig(
              floorNumber: cfg.floorNumber,
              roomsCount: cfg.roomsCount,
              roomSharings: List<int>.from(cfg.roomSharings),
            )).toList();

        if (sameRoomsPerFloor) {
          for (var floor = 1; floor <= floorCount; floor++) {
            final index = dialogFloorConfigs.indexWhere((cfg) => cfg.floorNumber == floor);
            if (index >= 0) {
              final existing = dialogFloorConfigs[index];
              dialogFloorConfigs[index] = FloorConfig(
                floorNumber: floor,
                roomsCount: roomsPerFloor,
                roomSharings: existing.roomSharings.length >= roomsPerFloor
                    ? existing.roomSharings.sublist(0, roomsPerFloor)
                    : List<int>.filled(
                        roomsPerFloor,
                        existing.roomSharings.isNotEmpty ? existing.roomSharings.first : 2,
                      ),
              );
            } else {
              dialogFloorConfigs.add(FloorConfig(
                floorNumber: floor,
                roomsCount: roomsPerFloor,
                roomSharings: List<int>.filled(roomsPerFloor, 2),
              ));
            }
          }
        }

        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Sharing allocation for rooms'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (sameRoomsPerFloor)
                      ...List.generate(floorCount, (floorIndex) {
                        final floorNumber = floorIndex + 1;
                        final config = dialogFloorConfigs.firstWhere(
                          (cfg) => cfg.floorNumber == floorNumber,
                          orElse: () => FloorConfig(
                            floorNumber: floorNumber,
                            roomsCount: roomsPerFloor,
                            roomSharings: List<int>.filled(roomsPerFloor, 2),
                          ),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Floor $floorNumber - ${config.roomsCount} rooms', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Column(
                                children: List.generate(config.roomsCount, (roomIndex) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Expanded(child: Text('Room ${floorNumber}${(roomIndex + 1).toString().padLeft(2, '0')}')),
                                        const SizedBox(width: 12),
                                        DropdownButton<int>(
                                          value: config.roomSharings[roomIndex],
                                          items: AppConstants.roomSharingOptions
                                              .map((share) => DropdownMenuItem(value: share, child: Text('$share')))
                                              .toList(),
                                          onChanged: (value) {
                                            if (value == null) return;
                                            final updated = List<int>.from(config.roomSharings);
                                            updated[roomIndex] = value;
                                            dialogFloorConfigs[floorIndex] = FloorConfig(
                                              floorNumber: config.floorNumber,
                                              roomsCount: config.roomsCount,
                                              roomSharings: updated,
                                            );
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                })
                              ),
                            ],
                          ),
                        );
                      })
                    else
                      ...List.generate(floorCount, (floorIndex) {
                        final floorNumber = floorIndex + 1;
                        final config = dialogFloorConfigs.firstWhere(
                          (cfg) => cfg.floorNumber == floorNumber,
                          orElse: () => FloorConfig(floorNumber: floorNumber, roomsCount: 0, roomSharings: []),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Floor $floorNumber - ${config.roomsCount} rooms', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              if (config.roomsCount <= 0)
                                const Text('Set the number of rooms for this floor in the main form.')
                              else
                                Column(
                                  children: List.generate(config.roomsCount, (roomIndex) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Expanded(child: Text('Room ${floorNumber}${(roomIndex + 1).toString().padLeft(2, '0')}')),
                                          const SizedBox(width: 12),
                                          DropdownButton<int>(
                                            value: config.roomSharings[roomIndex],
                                            items: AppConstants.roomSharingOptions
                                                .map((share) => DropdownMenuItem(value: share, child: Text('$share')))
                                                .toList(),
                                            onChanged: (value) {
                                              if (value == null) return;
                                              final updated = List<int>.from(config.roomSharings);
                                              updated[roomIndex] = value;
                                              final configIndex = dialogFloorConfigs.indexWhere((cfg) => cfg.floorNumber == floorNumber);
                                              if (configIndex >= 0) {
                                                dialogFloorConfigs[configIndex] = FloorConfig(
                                                  floorNumber: config.floorNumber,
                                                  roomsCount: config.roomsCount,
                                                  roomSharings: updated,
                                                );
                                              }
                                              setState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    floorConfigs
                      ..clear()
                      ..addAll(dialogFloorConfigs);
                    setParentState(() {});
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save allocation'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _BlockCard extends StatelessWidget {
  final BlockModel block;
  const _BlockCard({required this.block});

  String _sharingSummary(BlockModel block) {
    final roomSharings = block.floors.expand((floor) => floor.roomSharings).toList();
    if (roomSharings.isEmpty) return 'No sharing configured';
    final firstSharing = roomSharings.first;
    final isUniform = roomSharings.every((value) => value == firstSharing);
    return isUniform ? 'Sharing: $firstSharing' : 'Sharing: mixed';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BlockDetailScreen(block: block)),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(block.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${block.floorCount} floors • ${block.floors.length} floor configs',
                  style: const TextStyle(color: Colors.grey)),
              const Spacer(),
              Text(_sharingSummary(block), style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
