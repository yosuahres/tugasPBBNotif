# notif_app

add depend  
1.firebase  
```
flutter pub add firebase_core
flutter pub add cloud_firestore
```

2.awsome notification
```
flutter pub add awesome_notifications
```

source ideas:
firebase implementation  
https://youtu.be/iQOvD0y-xnw?si=v2GS3Jm23FIehe-V  

notification implementation  
https://github.com/agusbudi/mobile-programming/tree/main/10.%20Awesome%20Notifications  

# Modification
For the firabase implementation, I add the deadline on the CRUD, then i add the implementation of awesome notification from the github provided.   
Notification will pop-up, when Creating, Updating, and Deleting Notes.  

Notification with summary and scheduled notification is implemented  

For the notification with summary, i took it from the github, but with the ID from the current time it got modified(create||delete||update)  
So that the scheduled notification implementation will be more easy, as I just see the Id.
```
//CREATE
await NotificationService.createNotification(
    id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
    title: 'Note Added',
    body: 'A new note was successfully added.',
    summary: 'Firestore',
);
```
![Image](https://github.com/user-attachments/assets/86da2525-d520-41a1-b903-5c72197de40e)  

```
//UPDATE
await NotificationService.createNotification(
    id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
    title: 'Note Updated',
    body: 'Your note was successfully updated.',
    summary: 'Firestore',
);
```
![Image](https://github.com/user-attachments/assets/7425bdee-9ab3-4db9-be64-83e837627531)  

```
//DELETE
await NotificationService.createNotification(
    id: DateTime.now()
        .millisecondsSinceEpoch
        .remainder(100000),
    title: 'Note Deleted',
    body: 'A note was successfully deleted.',
    summary: 'Firestore',
);
```
![Image](https://github.com/user-attachments/assets/a5b55654-052a-4392-94b1-f380ba72d862)  

As in here, first i count the interval. The formula for interval is here
```
Duration diff = deadline.difference(now);
if (diff.isNegative) {
  diff = deadline.add(const Duration(days: 1)).difference(now);
}
```
if it is minus, it will count as the next day. the diff value will be the interval time to scheduled the notification. The remainder is the same as in github.  One problem is, the scheduled notification is delayed, it usually pop off two minutes after the deadline.

```
//SCHEDULED NOTIFICATION BASED ON DEADLINE INTERVAL DIFF
await NotificationService.createNotification(
  id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
  title: 'Bad Reminder',
  body: 'Deadline meets',
  summary: 'Deadline',
  scheduled: true,
  interval: diff,
);
```
![Image](https://github.com/user-attachments/assets/09729884-6e76-4d0a-a886-13aebc33e2c9)
 

