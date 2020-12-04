import 'package:ffi/ffi.dart';
import 'dart:ffi';

const String _libName = "libc.so.6";

typedef _system_cmd = Int32 Function(Pointer<Utf8> command);
typedef _SystemCmd = int Function(Pointer<Utf8> command);

/// Uses `dart:ffi` to run system commands.
class CmdInterface {
  Function _systemCmd;

  CmdInterface() {
    final lib = DynamicLibrary.open(_libName);
    _systemCmd = lib.lookupFunction<_system_cmd, _SystemCmd>("system");
  }

  /// Runs the given command by the system.
  int runCmd(String cmd) {
    return _systemCmd(Utf8.toUtf8(cmd));
  }
}
