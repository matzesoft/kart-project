import 'package:kart_project/providers/pwm_port/pwm_native.dart';

/// Communicates with [PwmNative] to use the PWM pins on the Raspberry Pi.
class PwmPort {
  final PwmNative _pwmNative = PwmNative();

  /// Containes information on which pins have already been set to PWM mode.
  Map<int, bool> _pins = {
    12: false,
    13: false,
    18: false,
    19: false,
  };

  /// Defines if wiringPi is already initalized.
  bool _initalized = false;

  PwmPort() {
    _init();
  }

  /// Sets the [dutyCycle] of the [pin]. Only pins 12, 13, 18 and 19 are allowed
  /// as pins. [dutyCycle] must be between 0 and 1024.
  ///
  /// If not already happend, the mode of the [pin] will be set to [PWM_OUTPUT].
  void setDutyCycle(int pin, int dutyCycle) {
    _init();
    if (!(pin == 12 || pin == 13 || pin == 18 || pin == 19))
      throw ArgumentError(
        'Pin $pin does not support PWM, only pins 12, 13, 18 and 19 do. To check which pin '
        'to choose go to https://pinout.xyz/. The PwmProvider uses the deafult BCM pins.',
      );
    if (dutyCycle > 1024 || dutyCycle < 0)
      throw RangeError.range(dutyCycle, 0, 1024, "duty cycle");

    if (!_pins[pin]) _pwmNative.pinMode(pin, PWM_OUTPUT);
    _pwmNative.pwmWrite(pin, dutyCycle);
  }

  /// Checks if wiringPi had been already initalized and calls
  /// [wiringPiSetupGpio] if not.
  void _init() {
    if (!_initalized) {
      _pwmNative.wiringPiSetupGpio();
      _initalized = true;
    }
  }
}
