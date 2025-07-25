import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskScreen extends StatelessWidget {
  final String uid;

  const TaskScreen({super.key, required this.uid});

  void _addTask(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final desc = descController.text.trim();
              if (title.isNotEmpty) {
                FirebaseFirestore.instance.collection('tasks').add({
                  'uid': uid,
                  'title': title,
                  'description': desc,
                  'timestamp': FieldValue.serverTimestamp(),
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteTask(String taskId) {
    FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final tasksRef = FirebaseFirestore.instance
        .collection('tasks')
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Tasks'),
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: tasksRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!.docs;

          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks yet.'));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final data = task.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['title'] ?? ''),
                subtitle: Text(data['description'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTask(task.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
