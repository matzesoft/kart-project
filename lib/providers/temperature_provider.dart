import 'dart:async';
import 'dart:isolate';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:kart_project/interfaces/gpio_interface.dart';
import 'package:kart_project/providers/motor_controller_provider.dart';
import 'package:kart_project/providers/notifications_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:kart_project/widgets/settings/settings.dart';
import 'package:wiring_pi_i2c/wiring_pi_i2c.dart';
import 'package:kart_project/extensions.dart';

class TemperatureProvider extends ChangeNotifier {
  TemperatureProvider(
    NotificationsProvider notifications,
    MotorControllerProvider motorController,
  ) {
    _setupIsolate();
    battery = BatteryTemperatureController(
      notifications,
      motorController,
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
    switchCabinet._update(tempData.switchCabinetTemp);
    battery._update(tempData.batteryTemps);
    notifyListeners();
  }
}

/// Used to transport temperature data between isolates.
class TemperatureData {
  TemperatureData(this.switchCabinetTemp, this.batteryTemps);

  final int? switchCabinetTemp;
  final List<int?> batteryTemps;
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

    List<int?> batteryTemps = [];
    for (int i = 0; i < _batterySensors.length; i++) {
      try {
        // TODO: Remove after testing
        throw I2CException("ahh kapput", 69);
        final temp = _batterySensors[i].readTemperature();
        batteryTemps.add(temp);
      } on I2CException {
        batteryTemps.add(null);
      }
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
    "switch_cabinet_heat",
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

class FanController {
  final _gpio = GpioInterface.fan;
  double _output = 0.0;

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

@immutable
class BatteryTemperatureState {
  BatteryTemperatureState({
    required this.level,
    required this.temperature,
    this.title: "",
    this.message: "",
    this.onSwitch,
  });

  static const _notifyID = "battey_over_temperature";
  static const _icon = EvaIcons.thermometerPlusOutline;
  static final _categorie = Strings.heat;

  final int level;
  final int temperature;
  final String title;
  final String message;
  final void Function(
    MotorControllerProvider motorControllerProvider,
  )? onSwitch;

  bool checkOnSwitch(
    int currentTemp,
    BatteryTemperatureState currentState,
    NotificationsProvider notification,
    MotorControllerProvider motorController,
  ) {
    // Only allows to higher up the level.
    if ((this.level > currentState.level) && (currentTemp >= temperature)) {
      notification.error.tryClose(_notifyID);
      notification.error.create(this.asErrorNotification);
      if (onSwitch != null) onSwitch!(motorController);
      return true;
    }
    return false;
  }

  ErrorNotification get asErrorNotification {
    ErrorLevel errorLevel = ErrorLevel.warning;
    if (level == 3) errorLevel = ErrorLevel.extremCritical;
    if (level == 2) errorLevel = ErrorLevel.critical;

    return ErrorNotification(
      _notifyID,
      icon: _icon,
      categorie: _categorie,
      title: title,
      message: message,
      level: errorLevel,
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
class BatteryTemperatureGood extends BatteryTemperatureState {
  /// In this case [temperature] is the value the current temperature must fall
  /// under to return back to this "good" state.
  BatteryTemperatureGood({required int temperature})
      : super(level: 0, temperature: temperature);

  @override
  bool checkOnSwitch(
    int currentTemp,
    BatteryTemperatureState currentState,
    NotificationsProvider notifications,
    MotorControllerProvider motorController,
  ) {
    if ((this.level < currentState.level) && (currentTemp < this.temperature)) {
      notifications.error.tryClose(BatteryTemperatureState._notifyID);
      return true;
    }
    return false;
  }
}

class BatteryTempStates {
  static final good = BatteryTemperatureGood(temperature: 35);
  static final warning = BatteryTemperatureState(
    temperature: 40,
    level: 1,
    title: Strings.batteryOverheat,
    message: Strings.batteryOverheatMsg,
  );
  static final enableLowSpeed = BatteryTemperatureState(
    temperature: 50,
    level: 2,
    title: Strings.highBatteryOverheat,
    message: Strings.highBatteryOverheatMsg,
    onSwitch: (motorController) {
      //TODO: Force low speed
      motorController.lowSpeedMode.alwaysActive = true;
    },
  );
  static final disableKart = BatteryTemperatureState(
      temperature: 60,
      level: 3,
      title: Strings.batteryOverheatDisableKart,
      message: Strings.batteryOverheatDisableKartMsg,
      onSwitch: (motorController) {
        //TODO: Force low speed
        motorController.lowSpeedMode.alwaysActive = true;
      });

  static List<BatteryTemperatureState> get asList {
    return [good, warning, enableLowSpeed, disableKart];
  }
}

final noTemperatureDataError = ErrorNotification(
  "no_temperature_data",
  icon: EvaIcons.thermometer,
  categorie: Strings.sensors,
  title: Strings.noTemperatureDataBattery,
  message: Strings.noTemperatureDataBatteryMessage,
  level: ErrorLevel.warning,
  moreDetails: (context) {
    Navigator.pushNamed(
      context,
      Settings.route,
      arguments: 4, // Safety Options
    );
  },
);

const _TEMP_SENSOR_DIFFERENCE_TO_HIGH = 14;

class BatteryTemperatureController {
  BatteryTemperatureController(
    this._notifications,
    this._motorController,
  );

  final NotificationsProvider _notifications;
  final MotorControllerProvider _motorController;
  List<int?> _temperatures = [];
  BatteryTemperatureState state = BatteryTempStates.good;
  bool _noTemperatureDataErrorShown = false;

  List<int?> get temperatures => _temperatures;

  bool get noTemperatureData =>
      temperatures.isEmpty || temperatures.allElementsAreNull;

  int? get maxTemp {
    if (noTemperatureData) return null;

    int? maxTemp;
    for (int i = 0; i < temperatures.length; i++) {
      final temp = temperatures[i];

      if (temp != null) {
        if (maxTemp != null) {
          if (maxTemp < temp) maxTemp = temp;
        } else {
          maxTemp = temp;
        }
      }
    }
    return maxTemp;
  }

  int? get averageTemp {
    if (noTemperatureData) return null;

    int count = temperatures.length;
    double sum = 0.0;
    temperatures.forEach((temp) {
      (temp == null) ? count -= 1 : sum += temp;
    });
    return (sum / count).round();
  }

  void _update(List<int?> temperatures) {
    logToConsole("BatteryTemperatureController", "_update",
        "Temperatures: $temperatures");

    // Checks if temperature data is empty and creates a error if true.
    if (temperatures.allElementsAreNull && !_noTemperatureDataErrorShown) {
      logToConsole("BatteryTemperatureController", "_update",
          "All Temperature Sensors return null.");
      _notifications.error.create(noTemperatureDataError);
      _noTemperatureDataErrorShown = true;
    } else if (!temperatures.allElementsAreNull &&
        _noTemperatureDataErrorShown) {
      _notifications.error.tryClose(noTemperatureDataError.id);
      _noTemperatureDataErrorShown = false;
    }

    // Checks for not functioning temp sensors and unvalid sensor data.
    if (this.noTemperatureData) {
      this._temperatures = temperatures;
    } else {
      for (int i = 0; i < temperatures.length; i++) {
        final tempBefore = this.temperatures[i];
        int? temp = temperatures[i];

        if (temp == null) {
          logToConsole("BatteryTemperatureController", "_update",
              "Temperature Sensor ${i + 1} unable to read data.");
        } else if ((tempBefore != null) &&
            (temp - tempBefore > _TEMP_SENSOR_DIFFERENCE_TO_HIGH)) {
          logToConsole(
            "BatteryTemperatureController",
            "_update",
            "Temperature difference to high. tempBefore: $tempBefore, tempNow: $temp",
          );
          temp = null;
        }
        this.temperatures[i] = temp;
      }
    }

    // Checks for high temperature and updates [state] if necessary.
    final maxTemperature = this.maxTemp;
    if (maxTemperature != null) {
      final tempStates = BatteryTempStates.asList;

      for (int i = 0; i < tempStates.length; i++) {
        final switchState = tempStates[i].checkOnSwitch(
            maxTemperature, state, _notifications, _motorController);
        if (switchState) state = tempStates[i];
      }
    }
  }
}
