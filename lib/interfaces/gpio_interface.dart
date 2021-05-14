import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:wiring_pi_soft_pwm/wiring_pi_soft_pwm.dart';

/// Label of the default RaspberryPi GPIO chip.
const _gpioChip = 'pinctrl-bcm2711';
const _gpioConsumer = 'KartProject';

const _BACK_LIGHT_PIN = 0;
const _BACK_DRIVE_LIGHT_PIN = 1;
const _BRAKE_INPUT = 4;
const _LED_RED_PIN = 13;
const _KELLY_OFF = 17;
const _FRONT_LIGHT_PIN = 18;
const _LED_GREEN_PIN = 19;
const _FAN_RPM_SPEED_PIN = 20;
const _FAN_PIN = 21;
const _SAFETY_LOCK = 22;
const _LED_BLUE_PIN = 26;
const _LOW_SPEED_MODE = 27;

/// Defines which GPIOs are used for what purpose
class GpioInterface {
  GpioInterface._();

  static List<GpioLine>? _gpios;

  static List<GpioLine> _initGpios() {
    final gpioChips = FlutterGpiod.instance.chips;
    final chip = gpioChips.singleWhere((c) => c.label == _gpioChip);
    return chip.lines;
  }

  // Because of internals of the RelayModule by ELEGOO the `ActiveState` has
  // to be turn around.
  static GpioLine get kellyOff => _requestOutput(
        _KELLY_OFF,
        initalValue: true,
        activeState: ActiveState.high,
      );
  static GpioLine get enableMotor => _requestOutput(
        _SAFETY_LOCK,
        initalValue: false,
        activeState: ActiveState.low,
      );
  static GpioLine get lowSpeedMode => _requestOutput(
        _LOW_SPEED_MODE,
        initalValue: false,
        activeState: ActiveState.low,
      );

  
  static GpioLine get brakeInput => _requestInput(
        _BRAKE_INPUT,
        activeState: ActiveState.low,
      );
  static GpioLine get fanRpmSpeed => _requestInput(
        _FAN_RPM_SPEED_PIN,
        activeState: ActiveState.low,
      );
  static SoftPwmGpio get fan => _setupSoftPwm(_FAN_PIN);
  static GpioLine get ledBlue => _requestOutput(_LED_BLUE_PIN);
  static GpioLine get ledGreen => _requestOutput(_LED_GREEN_PIN);
  static GpioLine get ledRed => _requestOutput(_LED_RED_PIN);
  static SoftPwmGpio get backLight => _setupSoftPwm(_BACK_LIGHT_PIN);
  static SoftPwmGpio get frontLight => _setupSoftPwm(_FRONT_LIGHT_PIN);
  static GpioLine get backDriveLight => _requestOutput(_BACK_DRIVE_LIGHT_PIN);

  /// Checks if the gpio is already requested and requests a new output if not.
  /// [initalValue] defines the value the GPIO should be set to.
  static GpioLine _requestOutput(
    int pin, {
    bool initalValue: false,
    ActiveState activeState: ActiveState.high,
  }) {
    _gpios ??= _initGpios();

    final gpio = _gpios![pin];
    if (!gpio.requested) {
      gpio.requestOutput(
        initialValue: initalValue,
        consumer: _gpioConsumer,
        activeState: activeState,
      );
    }
    return gpio;
  }

  /// Checks if the gpio is already requested and requests a new input if not.
  static GpioLine _requestInput(
    int pin, {
    ActiveState activeState: ActiveState.high,
  }) {
    _gpios ??= _initGpios();

    final gpio = _gpios![pin];
    if (!gpio.requested) {
      gpio.requestInput(
        consumer: _gpioConsumer,
        activeState: activeState,
        triggers: {SignalEdge.falling, SignalEdge.rising},
      );
    }
    return gpio;
  }

  /// Creates a [SoftPwmGpio]. Set [init] to define the initalValue.
  static SoftPwmGpio _setupSoftPwm(int pin, {int init: 0}) {
    final gpio = SoftPwmGpio(pin);
    gpio.setup(initalValue: init);
    return gpio;
  }
}
