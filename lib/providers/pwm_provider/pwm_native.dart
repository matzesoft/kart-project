import 'dart:ffi';

/// Value given by wiringPi to set a pin to PWM mode.
const int PWM_OUTPUT = 2;

/// Value given by wiringPi to change the PWM mode to mark:space.
const int PWM_MODE_MS = 0;

typedef wiring_pi_setup_gpio = Int32 Function();
typedef WiringPiSetupGpio = int Function();

typedef pin_mode = Void Function(Int32 pin, Int32 mode);
typedef PinMode = void Function(int pin, int mode);

typedef pwm_write = Void Function(Int32 pin, Int32 value);
typedef PwmWrite = void Function(int pin, int value);

/// Implementation of the necessary PWM functions via dart:ffi.
class PwmNative {
  final String _path = '/usr/lib/libwiringPi.so';
  DynamicLibrary _dylib;
  WiringPiSetupGpio wiringPiSetupGpio;
  PinMode pinMode;
  PwmWrite pwmWrite;

  PwmNative() {
    _dylib = DynamicLibrary.open(_path);
    wiringPiSetupGpio = _dylib
        .lookup<NativeFunction<wiring_pi_setup_gpio>>('wiringPiSetupGpio')
        .asFunction();
    pinMode = _dylib.lookup<NativeFunction<pin_mode>>('pinMode').asFunction();
    pwmWrite =
        _dylib.lookup<NativeFunction<pwm_write>>('pwmWrite').asFunction();
  }
}
