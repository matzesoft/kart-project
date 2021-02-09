import 'package:ffi/ffi.dart';
import 'dart:ffi';

const String _libName = "libc.so.6";

typedef _system_cmd = Int32 Function(Pointer<Utf8> command);
typedef _SystemCmd = int Function(Pointer<Utf8> command);

/// Uses `dart:ffi` to run system commands.
class CmdInterface {
  static Function _systemCmd;

  CmdInterface() {
    if (_systemCmd == null) {
      final dyLib = DynamicLibrary.open(_libName);
      _systemCmd ??= dyLib.lookupFunction<_system_cmd, _SystemCmd>("system");
    }
  }

  /// Runs the given command by the system. Does not wait for the command to finish.
  void runCmd(String cmd) {
    // This disables the output. If you remove this, flutter-pi will wait for
    // the command to finish until its updating its UI again.
    cmd += ' &>/dev/null &';

    final cmdPointer = Utf8.toUtf8(cmd);
    _systemCmd(cmdPointer);
    free(cmdPointer);
  }
}
