import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final RxBool isConnected = false.obs;
  StreamSubscription? streamSubscription;

  @override
  void onInit() {
    super.onInit();

    // Initialize connectivity status.
    Connectivity().checkConnectivity().then((value) => updateConnectivityStatus(value));

    // Listen and update connectivity status.
    streamSubscription =
        Connectivity().onConnectivityChanged.listen((ConnectivityResult result) => updateConnectivityStatus(result));
  }

  @override
  void onClose() {
    if (streamSubscription != null) {
      streamSubscription!.cancel();
    }
    super.onClose();
  }

  void updateConnectivityStatus(ConnectivityResult result) {
    isConnected.update((val) {
      val = (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi);
    });
  }
}
