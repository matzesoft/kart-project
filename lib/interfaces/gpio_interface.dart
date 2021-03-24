import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:wiring_pi_soft_pwm/wiring_pi_soft_pwm.dart';

/// Label of the default RaspberryPi GPIO chip.
const String _gpioChip = 'pinctrl-bcm2835';
const String _gpioConsumer = 'KartProject';

const int _FAN_PIN = 17;
const int _FAN_RPM_SPEED_PIN = 27;
const int _BRAKE_INPUT_PIN = 7;
const int _ELOCK_PIN = 9;
const int _CRUISE_PIN = 11;
const int _BACK_LIGHT_PIN = 1;
const int _LED_BLUE_PIN = 21;
const int _LED_GREEN_PIN = 20;
const int _LED_RED_PIN = 16;
const int _FRONT_LIGHT_PIN = 12;

/// Defines which GPIOs are used for what purpose
class GpioInterface {
  static List<GpioLine> _gpios;

  static List<GpioLine> _initGpios() {
    final gpioChips = FlutterGpiod.instance.chips;
    final chip = gpioChips.singleWhere((c) => c.label == _gpioChip);
    return chip.lines;
  }

  static GpioLine get brakeInput => _requestInput(_BRAKE_INPUT_PIN);
  static GpioLine get eLock => _requestOutput(_ELOCK_PIN, initalValue: true);
  static GpioLine get cruise => _requestOutput(_CRUISE_PIN, initalValue: true);
  static SoftPwmGpio get fan => _setupSoftPwm(_FAN_PIN);
  static GpioLine get fanRpmSpeed =>
      _requestInput(_FAN_RPM_SPEED_PIN, activeState: ActiveState.low);
  static GpioLine get ledBlue => _requestOutput(_LED_BLUE_PIN);
  static GpioLine get ledGreen => _requestOutput(_LED_GREEN_PIN);
  static GpioLine get ledRed => _requestOutput(_LED_RED_PIN);
  static SoftPwmGpio get backLight => _setupSoftPwm(_BACK_LIGHT_PIN);
  static SoftPwmGpio get frontLight => _setupSoftPwm(_FRONT_LIGHT_PIN);

  /// Checks if the gpio is already requested and requests a new output if not.
  /// [initalValue] defines the value the GPIO should be set to.
  static GpioLine _requestOutput(int pin, {bool initalValue: false}) {
    _gpios ??= _initGpios();

    final gpio = _gpios[pin];
    if (!gpio.requested)
      gpio.requestOutput(initialValue: initalValue, consumer: _gpioConsumer);
    return gpio;
  }

  /// Checks if the gpio is already requested and requests a new input if not.
  static GpioLine _requestInput(
    int pin, {
    ActiveState activeState: ActiveState.high,
  }) {
    _gpios ??= _initGpios();
    final gpio = _gpios[pin];
    if (!gpio.requested)
      gpio.requestInput(
        consumer: _gpioConsumer,
        activeState: activeState,
        triggers: {SignalEdge.falling, SignalEdge.rising},
      );
    return gpio;
  }

  /// Creates a [SoftPwmGpio]. Set [init] to define the initalValue.
  static SoftPwmGpio _setupSoftPwm(int pin, {int init: 0}) {
    final gpio = SoftPwmGpio(pin);
    gpio.setup(initalValue: init);
    return gpio;
  }
}
