import 'package:ffi/ffi.dart';
import 'dart:ffi';

const String _libName = "libc.so.6";

typedef _system_cmd = Int32 Function(Pointer<Utf8> command);
typedef _SystemCmd = int Function(Pointer<Utf8> command);

/// Uses `dart:ffi` to run system commands.
int runSystemCmd(String cmd) {
  final lib = DynamicLibrary.open(_libName);
  final systemCmd = lib.lookupFunction<_system_cmd, _SystemCmd>("system");
  return systemCmd(Utf8.toUtf8(cmd));
}
