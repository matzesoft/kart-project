import 'dart:async';
import 'dart:isolate';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:kart_project/interfaces/gpio_interface.dart';
import 'package:kart_project/providers/motor_controller_provider.dart';
import 'package:kart_project/providers/notifications_provider.dart';
import 'package:kart_project/providers/system_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:kart_project/widgets/settings/settings.dart';
import 'package:wiring_pi_i2c/wiring_pi_i2c.dart';

class TemperatureProvider extends ChangeNotifier {
  TemperatureProvider(
    NotificationsProvider notifications,
    MotorControllerProvider motorController,
    SystemProvider systemProvider,
  ) {
    _setupIsolate();
    battery = BatteryTemperatureController(
      notifications,
      motorController,
      systemProvider,
    );
    switchCabinet = SwitchCabinetTemperatureController(
      notifications,
      motorController,
    );
  }

  late final BatteryTemperatureController battery;
  late final SwitchCabinetTemperatureController switchCabinet;
  final _receivePort = ReceivePort();

  Future _setupIsolate() async {
    await Isolate.spawn(_readTemperatureData, _receivePort.sendPort);
    _receivePort.listen(_onNewTemperatureData);
  }

  void _onNewTemperatureData(dynamic message) {
    final TemperatureData tempData = message;
    battery._update(tempData.batteryTemps);
    switchCabinet._update(tempData.switchCabinetTemp);
    notifyListeners();
  }
}

/// Used to transport temperature data between isolates.
class TemperatureData {
  TemperatureData(this.switchCabinetTemp, this.batteryTemps);

  final int? switchCabinetTemp;
  final List<int> batteryTemps;
}

const _SWITCH_CABINET_SENSOR_ADDR = 0x18;
const _BATTERY_SENSOR_ADDRESES = [0x19, 0x1A, 0x1B, 0x1C];

const _TEMP_UPDATE_DURATION = Duration(seconds: 5);

void _readTemperatureData(SendPort sendPort) {
  final _switchCabinetSensor = MCP9808(_SWITCH_CABINET_SENSOR_ADDR);
  final _batterySensors = List.generate(
    _BATTERY_SENSOR_ADDRESES.length,
    (index) => MCP9808(_BATTERY_SENSOR_ADDRESES[index]),
  );

  Timer.periodic(_TEMP_UPDATE_DURATION, (_) {
    int? switchCabinetTemp;
    try {
      switchCabinetTemp = _switchCabinetSensor.readTemperature();
    } on I2CException {
      switchCabinetTemp = null;
    }

    List<int> batteryTemps = [];
    for (int i = 0; i < _batterySensors.length; i++) {
      try {
        final temp = _batterySensors[i].readTemperature();
        batteryTemps.add(temp);
      } on I2CException {}
    }

    final tempData = TemperatureData(switchCabinetTemp, batteryTemps);
    sendPort.send(tempData);
  });
}

const _TEMPERATURE_REGISTER = 0x05;
const _TEMPERATURE_MASK = 0x0FF0;

class MCP9808 {
  MCP9808(this._addr) {
    _i2c = I2CDevice(_addr);
    _i2c.setup();
  }

  final int _addr;
  late final I2CDevice _i2c;

  int readTemperature() {
    final data = _i2c.readReg16(_TEMPERATURE_REGISTER);
    return (data & _TEMPERATURE_MASK) >> 4;
  }
}

const _SWITCH_CABINET_NOTIFY_ID = "switch_cabinet_heat";

const _CONTROLLER_TEMP_FAN_FULL = 45;
const _CONTROLLER_TEMP_WARNING = 65;
const _CONTROLLER_TEMP_REMOVE_WARNING = 55;

const _SENSOR_TEMP_FAN_FULL = 35;
const _SENSOR_TEMP_WARNING = 45;
const _SENSOR_TEMP_REMOVE_WARNING = 35;

class SwitchCabinetTemperatureController {
  SwitchCabinetTemperatureController(
    this._notifications,
    this._motorController,
  );

  final MotorControllerProvider _motorController;
  final NotificationsProvider _notifications;

  final _fan = FanController();
  int? _sensorTemp;

  int? get controllerTemp => _motorController.controllerTemperature;
  int? get sensorTemp => _sensorTemp;

  int? get averageTemp {
    if (sensorTemp == null && controllerTemp == null) return null;
    if (sensorTemp == null) return controllerTemp;
    if (controllerTemp == null) return sensorTemp;

    final sum = sensorTemp! + controllerTemp!;
    return (sum / 2).round();
  }

  double? get fanOutputByAverageTemp {
    if (averageTemp == null) return null;
    // Linear function
    final output = 0.064598 * averageTemp! - 1.583925;
    if (output > 1.0) return 1.0;
    if (output < 0.0) return 0.0;
    return output;
  }

  bool _heatWarningShown = false;
  bool _sensorHeatWarning = false;
  bool _controllerHeatWarning = false;

  late final heatWarning = ErrorNotification(
    _SWITCH_CABINET_NOTIFY_ID,
    icon: EvaIcons.thermometerPlusOutline,
    categorie: Strings.heat,
    title: Strings.highSwitchCabinetTemperature,
    message: Strings.highSwitchCabinetTemperatureMsg,
    moreDetails: (context) {
      Navigator.pushNamed(
        context,
        Settings.route,
        arguments: 4, // Safety Options
      );
    },
  );

  bool get heatWarningShown => _heatWarningShown;

  bool get sensorHeat {
    if (sensorTemp == null) return false;
    if (!_sensorHeatWarning) {
      if (sensorTemp! >= _SENSOR_TEMP_WARNING) {
        _sensorHeatWarning = true;
        return true;
      }
      return false;
    } else {
      if (sensorTemp! <= _SENSOR_TEMP_REMOVE_WARNING) {
        _sensorHeatWarning = false;
        return false;
      }
      return true;
    }
  }

  bool get controllerHeat {
    if (controllerTemp == null) return false;
    if (!_controllerHeatWarning) {
      if (controllerTemp! >= _CONTROLLER_TEMP_WARNING) {
        _controllerHeatWarning = true;
        return true;
      }
      return false;
    } else {
      if (controllerTemp! <= _CONTROLLER_TEMP_REMOVE_WARNING) {
        _controllerHeatWarning = false;
        return false;
      }
      return true;
    }
  }

  void _update(int? sensorTempData) {
    _sensorTemp = sensorTempData;

    // Check heat warning
    if (sensorHeat || controllerHeat) {
      if (!_heatWarningShown) {
        _notifications.error.create(heatWarning);
        //TODO: Force low speed
        _motorController.lowSpeedMode.alwaysActive = true;
        _heatWarningShown = true;
      }
    } else {
      if (_heatWarningShown) {
        _notifications.error.tryClose(heatWarning.id);
        _heatWarningShown = false;
      }
    }

    if (controllerTemp != null &&
        controllerTemp! >= _CONTROLLER_TEMP_FAN_FULL) {
      _fan.output = 1.0;
    } else if (sensorTemp != null && sensorTemp! >= _SENSOR_TEMP_FAN_FULL) {
      _fan.output = 1.0;
    } else {
      final fanOutput = fanOutputByAverageTemp;
      if (fanOutput != null) _fan.output = fanOutput;
    }
  }
}

@immutable
class TemperatureState {
  TemperatureState({
    required this.level,
    required this.temperature,
    required this.notifyID,
    this.title: "",
    this.message: "",
    this.onSwitch,
  });

  static final _icon = EvaIcons.thermometerPlusOutline;
  static final _categorie = Strings.heat;

  final int level;
  final int temperature;
  final String notifyID;
  final String title;
  final String message;
  final void Function(
    MotorControllerProvider motorControllerProvider,
    SystemProvider systemProvider,
  )? onSwitch;

  bool checkOnSwitch(
    int currentTemp,
    TemperatureState currentState,
    NotificationsProvider notification,
    MotorControllerProvider motorController,
    SystemProvider systemProvider,
  ) {
    // Only allows to higher up the level.
    if ((this.level > currentState.level) && (currentTemp >= temperature)) {
      notification.error.tryClose(notifyID);
      notification.error.create(this.asErrorNotification);
      if (onSwitch != null) onSwitch!(motorController, systemProvider);
      return true;
    }
    return false;
  }

  ErrorNotification get asErrorNotification {
    return ErrorNotification(
      _BATTERY_TEMPERATURE_NOTIFY_ID,
      icon: _icon,
      categorie: _categorie,
      title: title,
      message: message,
      moreDetails: (context) {
        Navigator.pushNamed(
          context,
          Settings.route,
          arguments: 4, // Safety Options
        );
      },
    );
  }
}

@immutable
class TemperatureStateGood extends TemperatureState {
  /// In this case [temperature] is the value the current temperature must fall
  /// under to return back to this "good" state.
  TemperatureStateGood({required int temperature, required String notifyID})
      : super(level: 0, temperature: temperature, notifyID: notifyID);

  @override
  bool checkOnSwitch(
    int currentTemp,
    TemperatureState currentState,
    NotificationsProvider notifications,
    MotorControllerProvider motorController,
    SystemProvider systemProvider,
  ) {
    if ((this.level < currentState.level) && (currentTemp < this.temperature)) {
      notifications.error.tryClose(notifyID);
      return true;
    }
    return false;
  }
}

class BatteryTempStates {
  static final good = TemperatureStateGood(
    temperature: 35,
    notifyID: _BATTERY_TEMPERATURE_NOTIFY_ID,
  );
  static final warning = TemperatureState(
    temperature: 40,
    level: 1,
    notifyID: _BATTERY_TEMPERATURE_NOTIFY_ID,
    title: Strings.batteryOverheat,
    message: Strings.batteryOverheatMsg,
    onSwitch: (motorController, systemProvider) {
      //TODO: Force low speed
      motorController.lowSpeedMode.alwaysActive = true;
    },
  );
  static final enableLowSpeed = TemperatureState(
    temperature: 50,
    level: 2,
    notifyID: _BATTERY_TEMPERATURE_NOTIFY_ID,
    title: Strings.highBatteryOverheat,
    message: Strings.highBatteryOverheatMsg,
    onSwitch: (motorController, systemProvider) {
      //TODO: Force low speed
      motorController.lowSpeedMode.alwaysActive = true;
    },
  );
  static final disableKart = TemperatureState(
      temperature: 60,
      level: 3,
      notifyID: _BATTERY_TEMPERATURE_NOTIFY_ID,
      title: Strings.batteryOverheatDisableKart,
      message: Strings.batteryOverheatDisableKartMsg,
      onSwitch: (motorController, systemProvider) {
        //TODO: Force low speed
        motorController.lowSpeedMode.alwaysActive = true;
      });

  static List<TemperatureState> get asList {
    return [good, warning, enableLowSpeed, disableKart];
  }
}

const _BATTERY_TEMPERATURE_NOTIFY_ID = "battey_over_temperature";

class BatteryTemperatureController {
  BatteryTemperatureController(
    this._notifications,
    this._motorController,
    this._systemProvider,
  );

  final NotificationsProvider _notifications;
  final MotorControllerProvider _motorController;
  final SystemProvider _systemProvider;

  List<int> _temperatures = [];
  TemperatureState state = BatteryTempStates.good;

  List<int> get temperatures => _temperatures;

  int? get maxTemp {
    if (temperatures.isEmpty) return null;

    int maxTemp = temperatures[0];
    temperatures.forEach((temp) {
      if (maxTemp < temp) maxTemp = temp;
    });
    return maxTemp;
  }

  int? get averageTemp {
    if (temperatures.isEmpty) return null;

    double sum = 0.0;
    temperatures.forEach((temp) => sum += temp);
    return (sum / temperatures.length).round();
  }

  void _update(List<int> temperatures) {
    _temperatures = temperatures;

    final maxTemperature = this.maxTemp;
    if (maxTemperature != null) {
      final tempStates = BatteryTempStates.asList;

      for (int i = 0; i < tempStates.length; i++) {
        final switchState = tempStates[i].checkOnSwitch(maxTemperature, state,
            _notifications, _motorController, _systemProvider);
        if (switchState) state = tempStates[i];
      }
    }
  }
}

class FanController {
  final _gpio = GpioInterface.fan;
  // final _speedInput = GpioInterface.fanRpmSpeed;
  double _output = 0.0;

  FanController() {
    //_speedInput.onEvent.listen(_onSpeedChange);
  }

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
  }
}
