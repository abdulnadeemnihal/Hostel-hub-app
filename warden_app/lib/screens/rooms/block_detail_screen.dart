import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/block_model.dart';
import '../../models/floor_config_model.dart';
import '../../models/room_model.dart';
import '../../providers/data_provider.dart';
import '../../utils/constants.dart';
import 'floor_detail_screen.dart';

class BlockDetailScreen extends StatefulWidget {
  final BlockModel block;
  const BlockDetailScreen({required this.block, super.key});

  @override
  State<BlockDetailScreen> createState() => _BlockDetailScreenState();
}

class _BlockDetailScreenState extends State<BlockDetailScreen> {
  String _filterSharing = 'All';
  String _filterAvailability = 'All';
  String _roomSearch = '';

  String _floorSharingSummary(FloorConfig floorConfig) {
    if (floorConfig.roomSharings.isEmpty) {
      return 'No sharing configured';
    }
    final firstSharing = floorConfig.roomSharings.first;
    final isUniform = floorConfig.roomSharings.every((value) => value == firstSharing);
    return isUniform ? 'Sharing: $firstSharing' : 'Sharing: mixed';
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final updatedBlock = data.blocks.firstWhere(
      (b) => b.id == widget.block.id,
      orElse: () => widget.block,
    );
    final allRooms = data.roomsForBlock(updatedBlock.id);
    final roomCount = allRooms.length;
    final occupiedCount = allRooms.where((room) => room.occupied > 0).length;

    final filteredRooms = allRooms.where((room) {
      return _passesFilters(room);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(updatedBlock.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditBlockDialog(context, updatedBlock),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDeleteBlock(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${updatedBlock.floorCount} floors • $roomCount rooms', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Occupied: $occupiedCount', style: const TextStyle(color: Colors.orange)),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Search rooms',
                hintText: 'Search by room number or sharing',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _roomSearch.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _roomSearch = '';
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _roomSearch = value.trim()),
            ),
            const SizedBox(height: 12),
            // Filter Chips
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildFilterChip('Sharing', _filterSharing, ['All', '2', '3', '4'], (value) {
                  setState(() => _filterSharing = value);
                }),
                _buildFilterChip('Available', _filterAvailability, ['All', 'Available', 'Full'], (value) {
                  setState(() => _filterAvailability = value);
                }),
                if (_filterSearchActive())
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _filterSharing = 'All';
                        _filterAvailability = 'All';
                        _roomSearch = '';
                      });
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear Filter'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Rooms organized by floor
            Expanded(
              child: filteredRooms.isEmpty
                  ? const Center(child: Text('No rooms match the filter', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: updatedBlock.floorCount,
                      itemBuilder: (context, floorIndex) {
                        final floorNumber = floorIndex + 1;
                        final floorRooms = filteredRooms
                            .where((room) => room.floor == floorNumber)
                            .toList();

                        if (floorRooms.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'Floor $floorNumber',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                                mainAxisSpacing: 6,
                                crossAxisSpacing: 6,
                                childAspectRatio: 0.9,
                              ),
                              itemCount: floorRooms.length,
                              itemBuilder: (context, index) {
                                return _RoomCard(room: floorRooms[index]);
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditBlockDialog(BuildContext context, BlockModel blockToEdit) async {
    final nameCtrl = TextEditingController(text: blockToEdit.name);
    int floorCount = blockToEdit.floorCount;
    bool sameRoomsPerFloor = blockToEdit.sameRoomsPerFloor;
    int roomsPerFloor = blockToEdit.roomsPerFloor > 0 ? blockToEdit.roomsPerFloor : 1;
    final floorConfigs = blockToEdit.floors
        .map((cfg) => FloorConfig(
              floorNumber: cfg.floorNumber,
              roomsCount: cfg.roomsCount,
              roomSharings: List<int>.from(cfg.roomSharings),
            ))
        .toList();

    void normalizeConfig() {
      if (floorConfigs.length < floorCount) {
        final baseConfig = floorConfigs.isNotEmpty
            ? floorConfigs.first
            : FloorConfig(floorNumber: 1, roomsCount: roomsPerFloor, roomSharings: List<int>.filled(roomsPerFloor, 2));
        for (var i = floorConfigs.length + 1; i <= floorCount; i++) {
          floorConfigs.add(FloorConfig(
            floorNumber: i,
            roomsCount: sameRoomsPerFloor ? baseConfig.roomsCount : roomsPerFloor,
            roomSharings: List<int>.filled(sameRoomsPerFloor ? baseConfig.roomsCount : roomsPerFloor, baseConfig.roomSharings.isNotEmpty ? baseConfig.roomSharings.first : 2),
          ));
        }
      }
      if (floorConfigs.length > floorCount) {
        floorConfigs.removeWhere((cfg) => cfg.floorNumber > floorCount);
      }
      if (sameRoomsPerFloor) {
        if (floorConfigs.isEmpty) {
          floorConfigs.add(FloorConfig(
            floorNumber: 1,
            roomsCount: roomsPerFloor,
            roomSharings: List<int>.filled(roomsPerFloor, 2),
          ));
        }

        final config = floorConfigs.first;
        for (var i = 1; i <= floorCount; i++) {
          final updatedSharings = config.roomSharings.length >= roomsPerFloor
              ? config.roomSharings.sublist(0, roomsPerFloor)
              : List<int>.filled(roomsPerFloor, config.roomSharings.isNotEmpty ? config.roomSharings.first : 2);
          if (i <= floorConfigs.length) {
            floorConfigs[i - 1] = FloorConfig(
              floorNumber: i,
              roomsCount: roomsPerFloor,
              roomSharings: updatedSharings,
            );
          } else {
            floorConfigs.add(FloorConfig(
              floorNumber: i,
              roomsCount: roomsPerFloor,
              roomSharings: updatedSharings,
            ));
          }
        }
      }
    }

    normalizeConfig();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Edit Block'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Block Name'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: floorCount,
                        decoration: const InputDecoration(labelText: 'Floors'),
                        items: List.generate(6, (index) => index + 1)
                            .map((floor) => DropdownMenuItem(value: floor, child: Text('$floor')))
                            .toList(),
                        onChanged: (value) {
                          floorCount = value ?? 1;
                          normalizeConfig();
                          setState(() {});
                        },
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
                  onChanged: (value) {
                    sameRoomsPerFloor = value;
                    normalizeConfig();
                    setState(() {});
                  },
                ),
                if (sameRoomsPerFloor) ...[
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(text: roomsPerFloor.toString()),
                    decoration: const InputDecoration(labelText: 'Rooms per floor'),
                    onChanged: (value) {
                      roomsPerFloor = int.tryParse(value) ?? roomsPerFloor;
                      normalizeConfig();
                      setState(() {});
                    },
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
                              controller: TextEditingController(
                                text: floorConfigs.firstWhere(
                                  (cfg) => cfg.floorNumber == i,
                                  orElse: () => FloorConfig(floorNumber: i, roomsCount: 0, roomSharings: []),
                                ).roomsCount.toString(),
                              ),
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
                final newName = nameCtrl.text.trim();
                if (newName.isEmpty) return;
                final updatedBlock = BlockModel(
                  id: blockToEdit.id,
                  name: newName,
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
                  createdAt: blockToEdit.createdAt,
                );
                final rebuildRooms = _requiresRoomRebuild(blockToEdit, updatedBlock);
                await context.read<DataProvider>().updateBlock(updatedBlock, rebuildRooms: rebuildRooms);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  bool _requiresRoomRebuild(BlockModel original, BlockModel updated) {
    if (original.floorCount != updated.floorCount ||
        original.sameRoomsPerFloor != updated.sameRoomsPerFloor ||
        original.roomsPerFloor != updated.roomsPerFloor) {
      return true;
    }

    if (original.floors.length != updated.floors.length) {
      return true;
    }

    for (var i = 0; i < original.floors.length; i++) {
      final origFloor = original.floors[i];
      final updatedFloor = updated.floors[i];
      if (origFloor.floorNumber != updatedFloor.floorNumber ||
          origFloor.roomsCount != updatedFloor.roomsCount ||
          origFloor.roomSharings.length != updatedFloor.roomSharings.length) {
        return true;
      }
      for (var j = 0; j < origFloor.roomSharings.length; j++) {
        if (origFloor.roomSharings[j] != updatedFloor.roomSharings[j]) {
          return true;
        }
      }
    }
    return false;
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
        final dialogFloorConfigs = floorConfigs
            .map((cfg) => FloorConfig(
                  floorNumber: cfg.floorNumber,
                  roomsCount: cfg.roomsCount,
                  roomSharings: List<int>.from(cfg.roomSharings),
                ))
            .toList();

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
                                }),
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

  void _confirmDeleteBlock(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Block'),
        content: const Text('Are you sure you want to delete this block and all its rooms?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<DataProvider>().deleteBlock(widget.block.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
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

  bool _passesFilters(RoomModel room) {
    if (_filterSharing != 'All') {
      final desiredSharing = int.tryParse(_filterSharing);
      if (desiredSharing != null && room.capacity != desiredSharing) return false;
    }

    if (_filterAvailability == 'Available' && !room.isAvailable) return false;
    if (_filterAvailability == 'Full' && room.isAvailable) return false;

    if (_roomSearch.isNotEmpty) {
      final searchLower = _roomSearch.toLowerCase();
      if (!room.roomNumber.toLowerCase().contains(searchLower) &&
          !room.capacity.toString().contains(searchLower)) {
        return false;
      }
    }

    return true;
  }

  bool _filterSearchActive() {
    return _filterSharing != 'All' || _filterAvailability != 'All' || _roomSearch.isNotEmpty;
  }
}

class _RoomCard extends StatelessWidget {
  final RoomModel room;
  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    final isAvailable = room.isAvailable;
    return GestureDetector(
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
                Text('Occupied: ${room.occupied}/${room.capacity}'),
                Text('Status: ${isAvailable ? "Available" : "Full"}', style: TextStyle(color: isAvailable ? Colors.green : Colors.red)),
                const SizedBox(height: 12),
                const Text('Occupants:', style: TextStyle(fontWeight: FontWeight.bold)),
                if (room.occupantNames.isEmpty)
                  const Text('No students assigned yet')
                else
                  for (final occupant in room.occupantNames)
                    Text('• $occupant'),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ],
          ),
        );
      },
      child: Card(
        color: isAvailable ? Colors.white : Colors.grey.shade300,
        elevation: isAvailable ? 2 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(
            color: isAvailable ? Colors.blue.shade200 : Colors.grey.shade400,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                room.roomNumber,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isAvailable ? Colors.black : Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${room.capacity}-share',
                style: TextStyle(
                  fontSize: 10,
                  color: isAvailable ? Colors.grey.shade600 : Colors.black54,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isAvailable ? Colors.green.shade500 : Colors.red.shade500,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '${room.occupied}/${room.capacity}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
