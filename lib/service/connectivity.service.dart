import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService {
  final RxBool isConnected = false.obs;
  StreamSubscription? streamSubscription;

  ConnectivityService() {
    // Initialize connectivity status.
    Connectivity().checkConnectivity().then((value) => updateConnectivityStatus(value));

    // Listen and update connectivity status.
    streamSubscription =
        Connectivity().onConnectivityChanged.listen((ConnectivityResult result) => updateConnectivityStatus(result));
  }

  void updateConnectivityStatus(ConnectivityResult result) {
    isConnected.update((val) {
      val = (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet);
    });
  }
}
