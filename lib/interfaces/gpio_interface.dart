import 'package:flutter_gpiod/flutter_gpiod.dart';

/// Label of the default RaspberryPi GPIO chip.
const String _gpioChip = 'pinctrl-bcm2835';
const String _gpioConsumer = 'KartProject';

const int BRAKE_INPUT_PIN = 7;
const int ELOCK_PIN = 9;
const int CRUISE_PIN = 11;
const int FAN_PIN = 10;
const int BACK_LIGHT_PIN = 1;
const int LED_BLUE_PIN = 21;
const int LED_GREEN_PIN = 20;
const int LED_RED_PIN = 16;
const int FRONT_LIGHT_PIN = 12;

/// Defines which GPIOs are used for what purpose
class GpioInterface {
  static List<GpioLine> _gpios;

  GpioInterface() {
    if (_gpios == null) {
      print("Called GPIO Interface.");
      final gpioChips = FlutterGpiod.instance.chips;
      final chip = gpioChips.singleWhere((c) => c.label == _gpioChip);
      _gpios = chip.lines;
    }
  }

  GpioLine get brakeInput => _requestInput(BRAKE_INPUT_PIN);
  GpioLine get eLock => _requestOutput(ELOCK_PIN, init: true);
  GpioLine get cruise => _requestOutput(CRUISE_PIN, init: true);
  GpioLine get fan => _requestOutput(FAN_PIN);
  GpioLine get backLight => _requestOutput(BACK_LIGHT_PIN);
  GpioLine get ledBlue => _requestOutput(LED_BLUE_PIN);
  GpioLine get ledGreen => _requestOutput(LED_GREEN_PIN);
  GpioLine get ledRed => _requestOutput(LED_RED_PIN);
  GpioLine get frontLight => _requestOutput(FRONT_LIGHT_PIN);

  /// Checks if the gpio is already requested and requests a new output if not.
  /// [init] defines the value the GPIO should be set to.
  GpioLine _requestOutput(int pin, {bool init: false}) {
    final gpio = _gpios[pin];
    if (!gpio.requested)
      gpio.requestOutput(initialValue: init, consumer: _gpioConsumer);
    return gpio;
  }

  /// Checks if the gpio is already requested and requests a new input if not.
  GpioLine _requestInput(int pin) {
    final gpio = _gpios[pin];
    if (!gpio.requested) gpio.requestInput(consumer: _gpioConsumer);
    return gpio;
  }
}
