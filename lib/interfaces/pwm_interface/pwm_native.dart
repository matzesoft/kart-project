import 'dart:ffi';

/// Documentation is copied from `http://wiringpi.com/reference/`(15.07.2020, 17:58 CET).

/// Value given by wiringPi to set a pin to PWM mode.
const int PWM_OUTPUT = 2;

/// Value given by wiringPi to change the PWM mode to mark:space.
const int PWM_MODE_MS = 0;

const int PWM_RANGE = 1024;

/// WiringPi Native: `wiringPiSetupGpio(void);`
typedef wiring_pi_setup_gpio = Int32 Function();
typedef WiringPiSetupGpio = int Function();

/// WiringPi Native: `void pinMode(int pin, int mode);`
typedef pin_mode = Void Function(Int32 pin, Int32 mode);
typedef PinMode = void Function(int pin, int mode);

/// WiringPi Native: `void pwmWrite(int pin, int value);`
typedef pwm_write = Void Function(Int32 pin, Int32 value);
typedef PwmWrite = void Function(int pin, int value);

/// Implementation of the necessary PWM functions via dart:ffi.
class PwmNative {
  final String _path = '/usr/lib/libwiringPi.so';
  DynamicLibrary _dylib;

  /// This initialises wiringPi and assumes that the calling program is going to be using
  /// the Broadcom GPIO pin numbers directly with no re-mapping
  ///
  /// This function needs to be called with root privileges.
  WiringPiSetupGpio wiringPiSetupGpio;

  /// This sets the mode of a pin to either INPUT, OUTPUT, PWM_OUTPUT or GPIO_CLOCK.
  PinMode pinMode;

  /// Writes the value to the PWM register for the given pin and the range is 0-1024.
  /// Other PWM devices may have other PWM ranges.
  PwmWrite pwmWrite;

  PwmNative() {
    _dylib = DynamicLibrary.open(_path);
    wiringPiSetupGpio = _dylib
        .lookup<NativeFunction<wiring_pi_setup_gpio>>('wiringPiSetupGpio')
        .asFunction<WiringPiSetupGpio>();
    pinMode = _dylib
        .lookup<NativeFunction<pin_mode>>('pinMode')
        .asFunction<PinMode>();
    pwmWrite = _dylib
        .lookup<NativeFunction<pwm_write>>('pwmWrite')
        .asFunction<PwmWrite>();
  }
}
