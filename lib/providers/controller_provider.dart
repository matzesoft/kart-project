/// DEPRECATED CODE
///
/// Because the original controller was broken and we weren't happy about him,
/// we are currently looking for a new one. This code is commented out for now.

// import 'dart:async';
// import 'package:flutter/widgets.dart';

// final startByte = 0x66;

// enum ControllerState {
//   noError,
//   stallingProtection,
//   throttleProtection,
//   hallProtection,
//   underVoltageProtection,
//   mosfetProtection,
//   controllerOverHeatProtection,
//   motorOverCurrentProtection,
//   overVoltageProtection,
//   unableToConnect,
// }

// class ControllerProvider extends ChangeNotifier {
//   final _refreshRate = Duration(milliseconds: 50);
//   ControllerInterface _controller;
//   Timer _heartbeat;

//   /// Indicates that the [ControllerInterface] is running and the provider
//   /// is finished initalizing.
//   bool initalized = false;

//   ControllerProvider() {
//     _init();
//   }

//   void _init() {
//     _controller = ControllerInterface();
//     //TODO: Implement Heartbeat
//     initalized = true;
//     notifyListeners();
//   }

// // TODO: Remove after testing
//   void getEcho() {
//     _controller.sendCommand(Byte("02"));
//   }

//   void getState() {
//     _controller.sendCommand(Byte("42"));
//   }

//   // TODO: Remove after testing
//   void everyCmd() {
//     for (int i = 30; i < 256; i++) {
//       String value = i.toRadixString(16);
//       _controller.sendCommand(Byte(value));
//     }
//   }

//   List<DataPackage> getData() {
//     return _controller.readData();
//   }

//   /// Starts the heartbeat.
//   void _runHeartbeat() {
//     _heartbeat = Timer.periodic(_refreshRate, (_) {});
//   }
// }

// class ControllerInterface {
//   SerialInterface _serialPort = SerialInterface();

//   List<DataPackage> readData() {
//     List<DataPackage> dataPackages = [];
//     List<Byte> bytes = _serialPort.getValues();
//     while (bytes.isNotEmpty) {
//       // Wenn Daten nicht vollständig übertragen wurden
//       if (!bytes.first.extend(startByte)) {
//         // TODO: Implement transfer value
//         print("First byte is not start byte");
//       }

//       print("Before: ");
//       for (var i = 0; i < bytes.length; i++) {
//         print(bytes[i].value);
//       }

//       DataPackage dataPackage = DataPackage.fromList(bytes);
//       dataPackages.add(dataPackage);
//       bytes.removeRange(0, dataPackage.packageLength);
//       print("After: ");
//       for (var i = 0; i < bytes.length; i++) {
//         print(bytes[i].value);
//       }
//     }
//     return dataPackages;
//   }

//   /// Sends the command, in form of a [DataPackage], to the [_serialPort].
//   void sendCommand(Byte cmd) {
//     final package = DataPackage(cmd: cmd);
//     final bytes = package.asList(verifiy: true);
//     print(bytes.toString());
//     for (int i = 0; i < bytes.length; i++) {
//       _serialPort.sendValue(bytes[i]);
//     }
//   }
// }

// // TODO: Make sure DataPackage values are always two digits long.
// /// Data package of the GoldenMotor Protocol.
// /// Learn more at: https://github.com/SunnyWolf/goldenmotor_protocol
// class DataPackage {
//   final int _cmdIndex = 1;
//   final int _lengthIndex = 2;
//   final int _payloadIndex = 3;

//   Byte cmd;
//   Byte length;
//   List<Byte> payload;
//   Byte verification;

//   DataPackage({@required this.cmd, this.length, this.payload}) {
//     if (length == null) length = Byte("0");
//     verification = _calcVerification();
//   }

//   /// Returns the length of all data.
//   int get packageLength => _payloadIndex + length.integer + 1;

//   /// If [length] parameter is higher than 0.
//   bool get payloadAvailable => length.integer > 0;

//   /// Index of the [verification] byte.
//   int get _verificationIndex => packageLength - 1;

//   /// Returns the data package as a list. Set [verifiy] to true to get the
//   /// [verification] byte aswell.
//   List<Byte> asList({bool verifiy: false}) {
//     List<Byte> bytes = [];
//     bytes.add(startByte);
//     bytes.add(cmd);
//     bytes.add(length);
//     if (payloadAvailable) {
//       payload.forEach((payloadByte) => bytes.add(payloadByte));
//     }
//     if (verifiy) bytes.add(verification);
//     return bytes;
//   }

//   /// Reads the data from a list of bytes. Throws an error if calculated
//   /// verification byte is not the same as in the list of bytes.
//   DataPackage.fromList(List<Byte> bytes) {
//     if (!bytes[0].extend(startByte)) {
//       throw ArgumentError("A data package must start with the start byte.");
//     }
//     cmd = bytes[_cmdIndex];
//     length = bytes[_lengthIndex];
//     if (payloadAvailable) {
//       payload = bytes.getRange(_payloadIndex, _verificationIndex).toList();
//     }
//     verification = _calcVerification();
//     print("Calc verification: ${verification.value}");
//     print("Verification index: $_verificationIndex");
//     print("Data verification: ${bytes[_verificationIndex].value}");
//     if (!verification.extend(bytes[_verificationIndex])) {
//       throw StateError("Invalid data package. Verification failed.");
//     }
//   }

//   /// Calculates the verification byte by summing up all [bytes] and extracting
//   /// the low byte.
//   Byte _calcVerification() {
//     List<Byte> bytes = this.asList();
//     int sum = 0;
//     for (int i = 0; i < bytes.length; i++) {
//       sum += int.parse(bytes[i].value, radix: 16);
//     }
//     String hexSum = sum.toRadixString(16).toUpperCase();
//     return Byte(hexSum);
//   }
// }
