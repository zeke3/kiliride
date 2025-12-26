import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseScripts {
    //Adding field in docs only where the field doesn't exist
 static Future<void> addFieldInCollection({
    required String collectionName,
    required String fieldName,
    required dynamic fieldValue,
  }) async {
    try {
      // Retrieve all documents from the collection
      var collectionSnapshot =
          await FirebaseFirestore.instance.collection(collectionName).get();

      for (var collectionDoc in collectionSnapshot.docs) {
        try {
          // Get the document data
          var docData = collectionDoc.data() as Map<String, dynamic>;

          // Check if the field already exists
          if (!docData.containsKey(fieldName)) {
            // If the field doesn't exist, update the document by adding the new field
            await FirebaseFirestore.instance
                .collection(collectionName)
                .doc(collectionDoc.id)
                .set({
              fieldName: fieldValue
            }, SetOptions(merge: true)); // Use merge to only add the new field
          }
        } catch (e) {
          // Catch and log any errors that occur during individual document update
          print('Failed to update document ${collectionDoc.id}: $e');
        }
      }
    } catch (e) {
      // Catch and log any errors that occur during the collection retrieval
      print('Failed to retrieve collection: $e');
    }
  }

//Adding field in map in docs and updating value for current key
 static Future<void> addFieldInMapInCollection({
    required String collectionName,
    required String
        mapFieldName, // The top-level map field name (e.g., lastMessageData)
    required String
        mapKeyName, // The key in the map where you want to add/modify the field (e.g., dateAdded)
    required dynamic
        mapFieldValue, // The value you want to set for the key in the map
  }) async {
    try {
      // Retrieve all documents from the collection
      var collectionSnapshot =
          await FirebaseFirestore.instance.collection(collectionName).get();

      for (var collectionDoc in collectionSnapshot.docs) {
        try {
          // Check if the top-level map field exists
          var docData = collectionDoc.data() as Map<String, dynamic>;
          if (docData.containsKey(mapFieldName)) {
            var fieldMap = docData[mapFieldName];

            // Ensure that the top-level field is indeed a map
            if (fieldMap is Map<String, dynamic>) {
              // Update the specific key within the map using nested fields update
              await FirebaseFirestore.instance
                  .collection(collectionName)
                  .doc(collectionDoc.id)
                  .update({
                '$mapFieldName.$mapKeyName': mapFieldValue,
              });
            }
          } else {
            // If the map doesn't exist, create a new one with the specified key and value
            await FirebaseFirestore.instance
                .collection(collectionName)
                .doc(collectionDoc.id)
                .set(
                    {
                  mapFieldName: {mapKeyName: mapFieldValue},
                },
                    SetOptions(
                        merge:
                            true)); // Merge to ensure only the field gets added
          }
        } catch (e) {
          // Catch and log any errors that occur during individual document update
          print('Failed to update document ${collectionDoc.id}: $e');
        }
      }
    } catch (e) {
      // Catch and log any errors that occur during the collection retrieval
      print('Failed to retrieve collection: $e');
    }
  }

  //Update field in all docs
  static Future<void> updateFieldInAllDocuments({
    required String collectionName,
    required String fieldName,
    required dynamic newValue,
  }) async {
    try {
      // Retrieve all documents from the collection
      var collectionSnapshot =
          await FirebaseFirestore.instance.collection(collectionName).get();

      // Iterate over each document in the collection
      for (var collectionDoc in collectionSnapshot.docs) {
        try {
          // Update the field in the current document
          await FirebaseFirestore.instance
              .collection(collectionName)
              .doc(collectionDoc.id)
              .update({fieldName: newValue});

          print(
              'Field "$fieldName" updated in document "${collectionDoc.id}".');
        } catch (e) {
          print('Failed to update document ${collectionDoc.id}: $e');
        }
      }
    } catch (e) {
      print('Failed to retrieve collection: $e');
    }
  }

  //Update field by using conditions
  static Future<void> updateFieldByReplacementInAllDocuments({
    required String collectionName,
    required String fieldName,
    required dynamic conditionedValue,
    required String conditionedField,
    required dynamic oldValue,
    required dynamic newValue,
  }) async {
    //Conditioned field and Conditioned value are used for filtering the document to only where you want to update the field

    try {
      // Retrieve all documents from the collection
      var collectionSnapshot =
          await FirebaseFirestore.instance.collection(collectionName).get();

      // Iterate over each document in the collection
      for (var collectionDoc in collectionSnapshot.docs) {
        try {
          // Update the field in the current document
          if (collectionDoc.data()[conditionedField] == conditionedValue &&
              collectionDoc.data()[fieldName] == oldValue) {
            await FirebaseFirestore.instance
                .collection(collectionName)
                .doc(collectionDoc.id)
                .update({fieldName: newValue});
            print(
                'Field "$fieldName" updated in document "${collectionDoc.id}".');
          }
        } catch (e) {
          print('Failed to update document ${collectionDoc.id}: $e');
        }
      }
    } catch (e) {
      print('Failed to retrieve collection: $e');
    }
  }

  // Update field from old value to new value in a collection
  static Future<void> updateFieldWithNewValueInAllDocuments({
    required String collectionName,
    required String fieldName,
    required dynamic oldValue,
    required dynamic newValue,
  }) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where(fieldName, isEqualTo: oldValue)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No documents found with $fieldName equal to $oldValue.');
        return;
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {fieldName: newValue});
      }

      await batch.commit();
      print('Batch update completed successfully.');
    } catch (e) {
      print('Failed to perform batch update: $e');
    }
  }

}