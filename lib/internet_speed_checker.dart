import 'dart:async';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';

import 'callbacks_enum.dart';

typedef CancelListening = void Function();
typedef DoneCallback = void Function(double transferRate, SpeedUnit unit);
typedef ProgressCallback = void Function(
    double percent,
    double transferRate,
    SpeedUnit unit,
    );
typedef ErrorCallback = void Function(String errorMessage, String speedTestError);

class InternetSpeedTest {
  static const MethodChannel _channel = MethodChannel('internet_speed_test');

  final Map<int, Tuple3<ErrorCallback, ProgressCallback, DoneCallback>>
   _callbacksById =  {};

  int downloadRate = 0;
  int uploadRate = 0;
  int downloadSteps = 0;
  int uploadSteps = 0;

  Future<void> _methodCallHandler(MethodCall call) async {

    switch (call.method) {
      case 'callListener':
        if (call.arguments["id"] as int ==
            CallbacksEnum.startDownloadChecking.index) {
          if (call.arguments['type'] == ListenerEnum.complete.index) {
            downloadSteps++;
            downloadRate +=
                int.parse((call.arguments['transferRate'] ~/ 1000).toString());
            double average = (downloadRate ~/ downloadSteps).toDouble();
            SpeedUnit unit = SpeedUnit.kbps;
            average /= 1000;
            unit = SpeedUnit.mbps;
            _callbacksById[call.arguments["id"]]!.item3(average, unit);
            downloadSteps = 0;
            downloadRate = 0;
            _callbacksById.remove(call.arguments["id"]);
          } else if (call.arguments['type'] == ListenerEnum.error.index) {
            _callbacksById[call.arguments["id"]]!.item1(
                call.arguments['errorMessage'],
                call.arguments['speedTestError']);
            downloadSteps = 0;
            downloadRate = 0;
            _callbacksById.remove(call.arguments["id"]);
          } else if (call.arguments['type'] == ListenerEnum.progress.index) {
            double rate = (call.arguments['transferRate'] ~/ 1000).toDouble();
            if (rate != 0) downloadSteps++;
            downloadRate += rate.toInt();
            SpeedUnit unit = SpeedUnit.kbps;
            rate /= 1000;
            unit = SpeedUnit.mbps;
            _callbacksById[call.arguments["id"]]!
                .item2(call.arguments['percent'].toDouble(), rate, unit);
          }
        } else if (call.arguments["id"] as int ==
            CallbacksEnum.startUploadChecking.index) {
          if (call.arguments['type'] == ListenerEnum.complete.index) {

            uploadSteps++;
            uploadRate +=
                int.parse((call.arguments['transferRate'] ~/ 1000).toString());
            double average = (uploadRate ~/ uploadSteps).toDouble();
            SpeedUnit unit = SpeedUnit.kbps;
            average /= 1000;
            unit = SpeedUnit.mbps;
            _callbacksById[call.arguments["id"]]!.item3(average, unit);
            uploadSteps = 0;
            uploadRate = 0;
            _callbacksById.remove(call.arguments["id"]);
          } else if (call.arguments['type'] == ListenerEnum.error.index) {
            _callbacksById[call.arguments["id"]]!.item1(
                call.arguments['errorMessage'],
                call.arguments['speedTestError']);
          } else if (call.arguments['type'] == ListenerEnum.progress.index) {
            double rate = (call.arguments['transferRate'] ~/ 1000).toDouble();
            if (rate != 0) uploadSteps++;
            uploadRate += rate.toInt();
            SpeedUnit unit = SpeedUnit.kbps;
            rate /= 1000.0;
            unit = SpeedUnit.mbps;
            _callbacksById[call.arguments["id"]]!
                .item2(call.arguments['percent'].toDouble(), rate, unit);
          }
        }
        break;
      default:
        log(
            'TestFairy: Ignoring invoke from native. This normally shouldn\'t happen.');
    }

    _channel.invokeMethod("cancelListening", call.arguments["id"]);
  }

  Future<CancelListening> _startListening(
      Tuple3<ErrorCallback, ProgressCallback, DoneCallback> callback,
      CallbacksEnum callbacksEnum,
      String testServer,
      {Map<String, dynamic>? args,
        int fileSize = 200000}) async {
    _channel.setMethodCallHandler(_methodCallHandler);
    int currentListenerId = callbacksEnum.index;
    _callbacksById[currentListenerId] = callback;
    await _channel.invokeMethod(
      "startListening",
      {
        'id': currentListenerId,
        'args': args,
        'testServer': testServer,
        'fileSize': fileSize,
      },
    );
    return () {
      _channel.invokeMethod("cancelListening", currentListenerId);
      _callbacksById.remove(currentListenerId);
    };
  }

  Future<CancelListening> startDownloadTesting(
      {required DoneCallback onDone,
        required ProgressCallback onProgress,
        required ErrorCallback onError,
        int fileSize = 200000,
        String testServer = 'http://ipv4.ikoula.testdebit.info/1M.iso'}) async {
    return await _startListening(Tuple3(onError, onProgress, onDone),
        CallbacksEnum.startDownloadChecking, testServer,
        fileSize: fileSize);
  }

  Future<CancelListening> startUploadTesting({
    required DoneCallback onDone,
    required ProgressCallback onProgress,
    required ErrorCallback onError,
    int fileSize = 200000,
    String testServer = 'http://ipv4.ikoula.testdebit.info/',
  }) async {
    return await _startListening(Tuple3(onError, onProgress, onDone),
        CallbacksEnum.startUploadChecking, testServer,
        fileSize: fileSize);
  }
}
