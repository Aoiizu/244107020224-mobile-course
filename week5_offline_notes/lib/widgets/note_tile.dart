import 'package:flutter/material.dart';
import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(note.title),
      subtitle: Text(
        note.body.isEmpty ? note.updatedAt.toLocal().toString() : note.body,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (note.dirty)
            const Chip(
              label: Text('unsynced'),
              avatar: Icon(Icons.cloud_off, size: 16),
              visualDensity: VisualDensity.compact,
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}