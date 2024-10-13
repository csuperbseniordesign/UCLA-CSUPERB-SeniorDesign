import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> fireFetch(String fieldName) async {
  const String collectionName = "ApiCreds";
  const String documentName = "wbWd109hew7nEpCr1w02";
  String? key;

  try {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(documentName)
        .get();

    if (documentSnapshot.exists) {
      key = documentSnapshot.get(fieldName).toString();
      return key;
    } else {
      print('Document does not exist');
    }
  } catch (e) {
    print('Error fetching key from firebase: $e');
  }

  return key;
}
