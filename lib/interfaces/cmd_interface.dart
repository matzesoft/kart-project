import 'package:ffi/ffi.dart';
import 'dart:ffi';
import 'package:kart_project/extensions.dart';

const String _LIB_NAME = "libc.so.6";

// ignore: camel_case_types
typedef _system_cmd = Int32 Function(Pointer<Utf8> command);
typedef _SystemCmd = int Function(Pointer<Utf8> command);

/// Uses `dart:ffi` to run system commands.
class CmdInterface {
  static Function? _systemCmd;

  CmdInterface() {
    if (_systemCmd == null) {
      final dyLib = DynamicLibrary.open(_LIB_NAME);
      _systemCmd = dyLib.lookupFunction<_system_cmd, _SystemCmd>("system");
    }
  }

  /// Runs the given command by the system. Does not wait for the command to finish.
  void runCmd(String cmd) {
    logToConsole("CmdInterface", "runCmd", "Run command: $cmd");

    // This disables the output. If you remove this, flutter-pi will wait for
    // the command to finish until its updating its UI again.
    cmd += ' &>/dev/null &';

    final cmdPointer = cmd.toNativeUtf8();
    _systemCmd!(cmdPointer);
  }
}
