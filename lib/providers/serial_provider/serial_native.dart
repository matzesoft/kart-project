import 'dart:ffi';
import 'package:ffi/ffi.dart';

/// Documentation is copied from `http://wiringpi.com/reference/`(15.07.2020, 17:54 CET).

/// WiringPi Native: `int serialOpen (char *device, int baud);`
typedef serial_open = Int32 Function(Pointer<Utf8> device, Int32 baud);
typedef SerialOpen = int Function(Pointer<Utf8> device, int baud);

/// WiringPi Native: `void serialClose (int fd);`
typedef serial_close = Void Function(Int32 fd);
typedef SerialClose = void Function(int fd);

/// WiringPi Native: `void  serialPutchar (int fd, unsigned char c);`
typedef serial_putchar = Void Function(Int32 fd, Uint8 c);
typedef SerialPutchar = void Function(int fd, int c);

/// WiringPi Native: `void  serialPuts (int fd, char *s);`
typedef serial_puts = Void Function(Int32 fd, Pointer<Utf8>);
typedef SerialPuts = void Function(int fd, Pointer<Utf8>);

/// WiringPi Native: `int serialGetchar(int fd);`
typedef serial_getchar = Int32 Function(Int32 fd);
typedef SerialGetchar = int Function(int fd);

/// WiringPi Native: `void serialFlush(int fd);`
typedef serial_flush = Void Function(Int32 fd);
typedef SerialFlush = void Function(int fd);

class SerialNative {
  final String _path = '/usr/lib/libwiringPi.so';
  DynamicLibrary _dylib;

  /// This opens and initialises the serial device and sets the baud rate. It sets the
  /// port into “raw” mode (character at a time and no translations), and sets the read
  /// timeout to 10 seconds. The return value is the file descriptor or -1 for any error,
  /// in which case errno will be set as appropriate.
  SerialOpen serialOpen;

  /// Closes the device identified by the file descriptor given.
  SerialClose serialClose;

  /// Sends the single byte to the serial device identified by the given file descriptor.
  SerialPutchar serialPutchar;

  /// Sends the nul-terminated string to the serial device identified by the given file descriptor.
  SerialPuts serialPuts;

  /// Returns the next character available on the serial device. This call will block for up to
  /// 10 seconds if no data is available (when it will return -1)
  SerialGetchar serialGetchar;

  /// This discards all data received, or waiting to be send down the given device.
  SerialFlush serialFlush;

  SerialNative() {
    _dylib = DynamicLibrary.open(_path);
    serialOpen = _dylib
        .lookup<NativeFunction<serial_open>>('serialOpen')
        .asFunction<SerialOpen>();
    serialClose = _dylib
        .lookup<NativeFunction<serial_close>>('serialClose')
        .asFunction<SerialClose>();
    serialPutchar = _dylib
        .lookup<NativeFunction<serial_putchar>>('serialPutchar')
        .asFunction<SerialPutchar>();
    serialPuts = _dylib
        .lookup<NativeFunction<serial_puts>>('serialPuts')
        .asFunction<SerialPuts>();
    serialGetchar = _dylib
        .lookup<NativeFunction<serial_getchar>>('serialGetchar')
        .asFunction<SerialGetchar>();
    serialFlush = _dylib
        .lookup<NativeFunction<serial_flush>>('serialFlush')
        .asFunction<SerialFlush>();
  }
}
