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

class GpioInterface {
  static List<GpioLine> _gpios;

  GpioInterface() {
    final gpioChips = FlutterGpiod.instance.chips;
    final chip = gpioChips.singleWhere((c) => c.label == _gpioChip);
    _gpios = chip.lines;
  }

  GpioLine get brakeInput {
    _requestInput(_brakeInputPin);
    return _gpios[_brakeInputPin];
  }

  GpioLine get eLock {
    _requestOutput(_eLockPin, init: true);
    return _gpios[_eLockPin];
  }

  GpioLine get cruise {
    _requestOutput(_cruisePin, init: true);
    return _gpios[_cruisePin];
  }

  GpioLine get fan {
    _requestOutput(_fanPin);
    return _gpios[_fanPin];
  }

  GpioLine get backLight {
    _requestOutput(_backLightPin);
    return _gpios[_backLightPin];
  }

  GpioLine get ledBlue {
    _requestOutput(_ledBluePin);
    return _gpios[_ledBluePin];
  }

  GpioLine get ledGreen {
    _requestOutput(_ledGreenPin);
    return _gpios[_ledGreenPin];
  }

  GpioLine get ledRed {
    _requestOutput(_ledRedPin);
    return _gpios[_ledRedPin];
  }

  GpioLine get frontLight {
    _requestOutput(_frontLightPin);
    return _gpios[_frontLightPin];
  }

  void _requestOutput(int pin, {bool init: false}) {
    final gpio = _gpios[pin];
    if (!gpio.requested)
      gpio.requestOutput(initialValue: init, consumer: _gpioConsumer);
  }

  void _requestInput(int pin) {
    final gpio = _gpios[pin];
    if (!gpio.requested) gpio.requestInput(consumer: _gpioConsumer);
  }
}
