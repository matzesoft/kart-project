import 'package:ffi/ffi.dart';
import 'package:kart_project/interfaces/serial_interface/serial_native.dart';

/// Takes a 2 digits long hex number. If the [value] is longer, only the last
/// two digits will be used. [integer] returns the [value] in decimal format.
class Byte {
  String value;

  int get integer => int.parse(value, radix: 16);

  Byte(this.value) {
    if (value.length > 2) value = value.substring(value.length - 2);
  }

  /// Checks if the two bytes are the same.
  bool extend(Byte secondByte) {
    if (integer == secondByte.integer) return true;
    return false;
  }
}

class SerialInterface {
  final SerialNative _serialNative = SerialNative();

  /// File descriptor for the initalized serial port. If [openSerialPort] has
  /// not been called yet the value is set to -1.
  int fileDescriptor = -1;

  /// Initalizes the serial port. Default device is `/dev/serial0` with baud
  /// rate 9600. You can only use one serial port at the same time.
  ///
  /// If [fileDescriptor] is not -1, initalizing will stopped to prevent
  /// reinitalizing.
  /// If you still want to reinitalize set [reinitalizing] to true.
  void openSerialPort({
    String device: "/dev/serial0",
    int baud: 9600,
    bool reinitalizing: false,
  }) {
    if ((fileDescriptor != -1) && (!reinitalizing))
      throw StateError(
        "It seems like the serial device has already been initalized. "
        "Reinitalizing devices needs unnecessary resources.",
      );
    fileDescriptor = _serialNative.serialOpen(Utf8.toUtf8(device), baud);

    if (fileDescriptor == -1)
      throw StateError("Failed to initalize serial port: $device");
  }

  /// Sends the [byte] to the serial device linked to the [fileDescriptor].
  void sendHex(Byte byte) {
    _checkIfInitalized();
    _serialNative.serialPutchar(fileDescriptor, byte.integer);
  }

  /// Sends the [string] to the serial device linked to the [fileDescriptor].
  void sendString(String string) {
    _checkIfInitalized();
    _serialNative.serialPuts(fileDescriptor, Utf8.toUtf8(string));
  }

  /// Returns the list of data available on the serial device.
  List<Byte> getBytes() {
    _checkIfInitalized();
    List<Byte> bytes = [];
    int dataAvail = _serialNative.serialDataAvail(fileDescriptor);

    for (int i = 0; i < dataAvail; i++) {
      int value = _serialNative.serialGetchar(fileDescriptor);
      bytes.add(Byte(value.toRadixString(16)));
    }
    return bytes;
  }

  /// This discards all data received, or waiting to be send down the given device.
  void clear() {
    _checkIfInitalized();
    return _serialNative.serialFlush(fileDescriptor);
  }

  /// Closes the serial port. Should be called if serial port is not in use anymore.
  void closePort() {
    _serialNative.serialClose(fileDescriptor);
    fileDescriptor = -1;
  }

  void _checkIfInitalized() {
    if (fileDescriptor == -1)
      throw StateError(
        "Serial port has not yet been initalized. File descriptor value: $fileDescriptor",
      );
  }
}
