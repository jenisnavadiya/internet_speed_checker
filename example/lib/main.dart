import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:internet_speed_checker/callbacks_enum.dart';
import 'package:internet_speed_checker/internet_speed_checker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final internetSpeedTest = InternetSpeedTest();

  double downloadRate = 0;
  double uploadRate = 0;
  String downloadProgress = '0';
  String uploadProgress = '0';

  String unitText = 'Mb/s';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Internet Speed Checker app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text('Progress $downloadProgress%'),
                  Text('Download rate  $downloadRate $unitText'),
                ],
              ),
              ElevatedButton(
                child: const Text('Start Testing'),
                onPressed: () {
                  internetSpeedTest.startDownloadTesting(
                    onDone: (double transferRate, SpeedUnit unit) {
                      log('the transfer rate $transferRate');
                      setState(() {
                        downloadRate = transferRate;
                        unitText = unit == SpeedUnit.kbps ? 'Kb/s' : 'Mb/s';
                        downloadProgress = '100';
                      });
                    },
                    onProgress:
                        (double percent, double transferRate, SpeedUnit unit) {
                      log('the transfer rate $transferRate, the percent $percent');
                      setState(() {
                        downloadRate = transferRate;
                        unitText = unit == SpeedUnit.kbps ? 'Kb/s' : 'Mb/s';
                        downloadProgress = percent.toStringAsFixed(2);
                      });
                    },
                    onError: (String errorMessage, String speedTestError) {
                      log('the errorMessage $errorMessage, the speedTestError $speedTestError');
                    },
                    fileSize: 20000000,
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text('Progress $uploadProgress%'),
                  Text('Upload rate  $uploadRate Kb/s'),
                ],
              ),
              ElevatedButton(
                child: const Text('Start Testing'),
                onPressed: () {
                  internetSpeedTest.startUploadTesting(
                    onDone: (double transferRate, SpeedUnit unit) {
                      log('the transfer rate $transferRate');
                      setState(() {
                        uploadRate = transferRate;
                        unitText = unit == SpeedUnit.kbps ? 'Kb/s' : 'Mb/s';
                        uploadProgress = '100';
                      });
                    },
                    onProgress:
                        (double percent, double transferRate, SpeedUnit unit) {
                      log('the transfer rate $transferRate, the percent $percent');
                      setState(() {
                        uploadRate = transferRate;
                        unitText = unit == SpeedUnit.kbps ? 'Kb/s' : 'Mb/s';
                        uploadProgress = percent.toStringAsFixed(2);
                      });
                    },
                    onError: (String errorMessage, String speedTestError) {
                      log('the errorMessage $errorMessage, the speedTestError $speedTestError');
                    },
                    fileSize: 20000000,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
