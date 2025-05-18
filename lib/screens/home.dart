import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notif_app/services/firestore.dart';
import 'package:notif_app/services/notification_service.dart';
  
  class Home extends StatefulWidget {
    const Home({ super.key });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController noteController = TextEditingController();     
  final FirestoreService firestoreService = FirestoreService();

  void openNoteDialog({String? docId}) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
      content: TextField(
        controller: noteController,
      ),

      actions: [
        ElevatedButton(
          onPressed: ()  async{
            // firestoreService.addNote(noteController.text);
            
            if(docId == null) {
              firestoreService.addNote(noteController.text);
              await NotificationService.createNotification(
                id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
                title: 'Note Added',
                body: 'A new note was successfully added.',
                summary: 'Firestore',
              );

            } else {
              firestoreService.updateNote(docId, noteController.text);
              await NotificationService.createNotification(
                id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
                title: 'Note Updated',
                body: 'Your note was successfully updated.',
                summary: 'Firestore',
              );           
            }

            noteController.clear();

            Navigator.pop(context);
          }, 
          child: Text("Add"),

        )
      ],
      )
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
            if (snapshot.hasData){
              List noteList = snapshot.data!.docs;
              return ListView.builder(
                itemCount: noteList.length,
                itemBuilder: (context, index){
                  DocumentSnapshot document = noteList[index];
                  String docId = document.id;

                  Map<String, dynamic> note = document.data() as Map<String, dynamic>;
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
                          onPressed: () async{
                            firestoreService.deleteNote(docId);
                            await NotificationService.createNotification(
                              id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
                              title: 'Note Deleted',
                              body: 'A note was successfully deleted.',
                              summary: 'Firestore',
                            );
                          },
                        ),
                      ],
                    ),
                  );

                },
              );
            }

            else {
              return const Text("data not found");
            }

          }
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: openNoteDialog,
          child: Icon(Icons.add),
        ),
      );
    }
}