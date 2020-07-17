import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:kart_project/providers/serial_provider/serial_native.dart';

class SerialProvider extends ChangeNotifier {
  final SerialNative _serialNative = SerialNative();

  /// File descriptor for the initalized serial port. If [openSerialPort] has not been
  /// called yet the value is set to -1.
  int fileDescriptor = -1;

  /// Initalizes the serial port. Default device is `/dev/serial0` with baud rate 9600.
  /// You can only use one serial port at the same time.
  ///
  /// If [fileDescriptor] is not -1, initalizing will stopped to prevent reinitalizing.
  /// If you still want to reinitalize set [reinitalizing] to true.
  void openSerialPort({
    String device: "/dev/serial0",
    int baud: 9600,
    bool reinitalizing: false,
  }) {
    if ((fileDescriptor != -1) && (!reinitalizing))
      throw StateError(
        "It seems like the serial device has already been initalized. Reinitalizing devices needs unnecessary resources.",
      );
    fileDescriptor = _serialNative.serialOpen(Utf8.toUtf8(device), baud);

    if (fileDescriptor == -1)
      throw StateError("Failed to initalize serial port: $device");
    notifyListeners();
  }

  void sendByte(int byte) {
    _checkIfInitalized();
    _serialNative.serialPutchar(fileDescriptor, byte);
  }

  /// Sends the [value] to the serial device definded by the [fileDescriptor].
  void sendString(String value) {
    // TODO: ASCII to HEXA?
    _checkIfInitalized();
    _serialNative.serialPuts(fileDescriptor, Utf8.toUtf8(value));
  }

  /// Returns the next character available on the serial device. Timeout: 10 seconds
  int getByte() {
    // TODO: ASCII to HEXA?
    _checkIfInitalized();
    return _serialNative.serialGetchar(fileDescriptor);
  }

  /// Closes the serial port. Should be called if serial port is not in use anymore.
  void closeSerialPort() {
    _serialNative.serialClose(fileDescriptor);
  }

  void _checkIfInitalized() {
    if (fileDescriptor == -1)
      throw StateError(
        "Serial port has not yet been initalized. File descriptor value: $fileDescriptor",
      );
  }
}
