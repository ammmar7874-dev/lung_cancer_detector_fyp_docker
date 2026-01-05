import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final historyList = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  void fetchHistory() {
    User? user = _auth.currentUser;
    if (user != null) {
      isLoading.value = true;
      _db
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              historyList.value = snapshot.docs.map((doc) {
                var data = doc.data();
                data['id'] = doc.id;
                return data;
              }).toList();
              isLoading.value = false;
            },
            onError: (error) {
              // print removed
              isLoading.value = false;
            },
          );
    }
  }

  Future<void> deleteHistoryItem(String docId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _db
            .collection('users')
            .doc(user.uid)
            .collection('history')
            .doc(docId)
            .delete();
        Get.snackbar(
          "Success",
          "Item deleted",
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to delete item",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
