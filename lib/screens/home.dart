import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notif_app/services/firestore.dart';
import 'package:notif_app/services/notification_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController noteController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();

  TimeOfDay? selectedTime;

  void openNoteDialog({String? docId}) {
    noteController.clear();
    selectedTime = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(docId == null ? 'Add Note' : 'Update Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    selectedTime == null
                        ? 'No deadline'
                        : 'Deadline: ${selectedTime!.format(context)}',
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedTime = picked;
                        });
                      }
                    },
                    child: const Text('Pick Deadline'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (docId == null) {
                  firestoreService.addNote(noteController.text);

                  if (selectedTime != null) {
                    final now = DateTime.now();
                    final deadline = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      selectedTime!.hour,
                      selectedTime!.minute,
                    );
                    Duration diff = deadline.difference(now);
                    if (diff.isNegative) {
                      diff = deadline.add(const Duration(days: 1)).difference(now);
                    }
                    await NotificationService.createNotification(
                      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
                      title: 'Deadline Reminder',
                      body: 'Your note "${noteController.text}" is due now!',
                      summary: 'Deadline',
                      scheduled: true,
                      interval: diff,
                    );
                  }

                  await NotificationService.createNotification(
                    id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
                    title: 'Note Added',
                    body: 'A new note was successfully added.',
                    summary: 'Firestore',
                    notificationLayout: NotificationLayout.Inbox,
                  );
                } else {
                  firestoreService.updateNote(docId, noteController.text);
                  await NotificationService.createNotification(
                    id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
                    title: 'Note Updated',
                    body: 'Your note was successfully updated.',
                    summary: 'Firestore',
                    notificationLayout: NotificationLayout.Inbox,
                  );
                }

                noteController.clear();
                Navigator.pop(context);
              },
              child: Text(docId == null ? "Add" : "Update"),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification App'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List noteList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = noteList[index];
                String docId = document.id;

                Map<String, dynamic> note =
                    document.data() as Map<String, dynamic>;
                String noteText = note['note'];

                return ListTile(
                  title: Text(noteText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () => openNoteDialog(docId: docId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          firestoreService.deleteNote(docId);
                          await NotificationService.createNotification(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .remainder(100000),
                            title: 'Note Deleted',
                            body: 'A note was successfully deleted.',
                            summary: 'Firestore',
                            notificationLayout: NotificationLayout.Inbox,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Text("data not found");
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}