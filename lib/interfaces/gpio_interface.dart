import 'package:flutter_gpiod/flutter_gpiod.dart';

/// Label of the default RaspberryPi GPIO chip.
const String _gpioChip = 'pinctrl-bcm2835';
const String _gpioConsumer = 'KartProject';

const int _brakeInputPin = 7;
const int _eLockPin = 9;
const int _cruisePin = 11;
const int _fanPin = 10;
const int _backLightPin = 1;
const int _ledBluePin = 21;
const int _ledGreenPin = 20;
const int _ledRedPin = 16;
const int _frontLightPin = 12;

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

  GpioLine get brakeInput => _requestInput(_brakeInputPin);
  GpioLine get eLock => _requestOutput(_eLockPin, init: true);
  GpioLine get cruise => _requestOutput(_cruisePin, init: true);
  GpioLine get fan => _requestOutput(_fanPin);
  GpioLine get backLight => _requestOutput(_backLightPin);
  GpioLine get ledBlue => _requestOutput(_ledBluePin);
  GpioLine get ledGreen => _requestOutput(_ledGreenPin);
  GpioLine get ledRed => _requestOutput(_ledRedPin);
  GpioLine get frontLight => _requestOutput(_frontLightPin);

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
