import 'package:kart_project/interfaces/pwm_interface/pwm_native.dart';

/// Communicates with [PwmNative] to use the PWM pins on the Raspberry Pi.
class PwmInterface {
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

  PwmInterface() {
    _init();
  }

  /// Sets the duty cycle of the [pin]. Only pins 12, 13, 18 and 19 are allowed
  /// as pins. [factor] must be between 0 and 1.
  ///
  /// If not already happend, the mode of the [pin] will be set to [PWM_OUTPUT].
  void setDutyCycle(int pin, double factor) {
    if (!_pins.containsKey(pin)) {
      throw ArgumentError(
        'Pin $pin does not support PWM, only pins 12, 13, 18 and 19 do. To check which pin '
        'to choose go to https://pinout.xyz/. The PwmProvider uses the deafult BCM pins.',
      );
    }
    if (factor < 0 || factor > 1) {
      throw RangeError("Factor must be set between 0 and 1.");
    }
    _init();
    if (!_pins[pin]) _pwmNative.pinMode(pin, PWM_OUTPUT);

    int dutyCycle = (factor * PWM_RANGE).round();
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
