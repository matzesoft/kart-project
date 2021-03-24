import 'package:flutter/widgets.dart';
// import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:kart_project/interfaces/gpio_interface.dart';

class CoolingProvider extends ChangeNotifier {
  final fan = FanController();
}

class FanController {
  final _gpio = GpioInterface.fan;
  // final _speedInput = GpioInterface.fanRpmSpeed;
  double _output = 0.0;

  FanController() {
    //_speedInput.onEvent.listen(_onSpeedChange);
  }

  // TODO: Implement
  // void _onSpeedChange(SignalEvent event) {
  //   final value = _speedInput.getValue();
  //   final edge = event.edge;
  //   print("value: $value, edge: $edge");
  // }

  double get output => _output;

  set output(double output) {
    if (output < 0.0 || output > 1.0) {
      throw ArgumentError("output must be set between 0.0 and 1.0");
    }
    _output = output;
    // Range of fan is reducded to 40% - 100% or 0%.
    final value = (output == 0.0) ? 0 : (((output * 0.6) + 0.4) * 100).round();
    _gpio.write(value);
    print(value);
  }
}
