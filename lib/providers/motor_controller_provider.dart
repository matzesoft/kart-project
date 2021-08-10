import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:kart_project/interfaces/gpio_interface.dart';
import 'package:kart_project/providers/notifications_provider.dart';
import 'package:kart_project/providers/preferences_provider.dart';
import 'package:kart_project/providers/user_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:kart_project/widgets/settings/settings.dart';
import 'package:linux_can/linux_can.dart';

const _WHEEL_DIAMETER = 0.33; // m

const _VOLTAGE_WHEN_CHARGED = 50.4;
const _VOLTAGE_WHEN_LOW = 42.0;

const _ENABLE_MOTOR_THROTTLE_LIMIT = 0.05;

const _MOTOR_CURRENT_MAX = 176.0;

const _GLOBAL_RANGE_KEY = 'global_range';
const _TRIP_RANGE_KEY = 'trip_range';

enum MotorState {
  neutral,
  forward,
  backward,
}

const _CAN_UPDATE_DURATION = const Duration(milliseconds: 50);
const _CAN_UPDATE_DURATION_IN_HOURES = 50 / 1000 / 60 / 60;

class MotorControllerProvider extends ChangeNotifier {
  MotorControllerProvider(this._user, this._notifications, this._preferences) {
    _canData = KellyCanData._(this);
    globalRangeProfil = GlobalRangeProfil(_preferences, _GLOBAL_RANGE_KEY);
    tripRangeProfil = GlobalRangeProfil(_preferences, _TRIP_RANGE_KEY);

    _canData.setup().then((_) {
      _canData.addListener(() => _onCanDataChanged());
    });
  }

  MotorControllerProvider update(User newUser) {
    if (_user != newUser) {
      _user = newUser;
      lowSpeedMode._onUserSwitched();
      notifyListeners();
    }
    return this;
  }

  final NotificationsProvider _notifications;
  final PreferencesProvider _preferences;
  late final KellyCanData _canData;
  late final lowSpeedMode = LowSpeedModeController(this);
  late final GlobalRangeProfil globalRangeProfil;
  late final GlobalRangeProfil tripRangeProfil;
  final _powerGpio = GpioInterface.kellyOff;
  final _enableMotorGpio = GpioInterface.enableMotor;
  User _user;
  ControllerError? _error;

  double get speed {
    final rpm = _canData.rpm;
    return (rpm * (24 / 112) * _WHEEL_DIAMETER * pi * 60 / 1000);
  }

  double get batteryLevel {
    final _difference = _VOLTAGE_WHEN_CHARGED - _VOLTAGE_WHEN_LOW;
    final level = (batteryVoltage - _VOLTAGE_WHEN_LOW) / _difference;
    if (level < 0.0) return 0.0;
    if (level > 1.0) return 1.0;
    return level;
  }

  double get throttleSignal {
    return _canData.throttleSignal / 0xFF;
  }

  double get motorCurrent => _canData.motorCurrent;
  double get motorCurrentInPercent => motorCurrent / _MOTOR_CURRENT_MAX;
  double get batteryVoltage => _canData.batteryVoltage;

  int? get controllerTemperature => _canData.controllerTemperature;
  int? get motorTemperature => _canData.motorTemperature;

  MotorState get motorStateCommand => _canData.motorStateCommand;
  MotorState get motorStateFeedback => _canData.motorStateFeedback;

  UserRangeProfil get userRangeProfil => _user.rangeProfil;

  ControllerError? get error => _error;
  set error(ControllerError? controllerError) {
    if (error != controllerError) {
      if (error != null) _notifications.error.tryClose(_error!.id);
      if (controllerError != null) _notifications.error.create(controllerError);
      _error = controllerError;
    }
  }

  bool get isOn => _powerGpio.getValue();

  void setPower(bool on) {
    if (on != isOn) {
      _powerGpio.setValue(on);
      notifyListeners();
    }
  }

  bool get motorEnabled => _enableMotorGpio.getValue();

  bool get allowDisEnableMotor {
    if (motorEnabled) {
      if (speed <= 0) return true;
    } else {
      if (throttleSignal <= _ENABLE_MOTOR_THROTTLE_LIMIT) return true;
    }
    return false;
  }

  void enableMotor(bool locked) {
    if (allowDisEnableMotor) {
      _enableMotorGpio.setValue(locked);
      notifyListeners();
    }
  }

  void _onCanDataChanged() async {
    lowSpeedMode._onBatteryLevelChange();
    globalRangeProfil.updateByMotorController(speed, batteryLevel);
    tripRangeProfil.updateByMotorController(speed, batteryLevel);
    userRangeProfil.updateByMotorController(speed, batteryLevel);
    notifyListeners();
  }

  Future restart() async {
    setPower(false);
    await Future.delayed(Duration(seconds: 3), () {
      setPower(true);
    });
  }

  void _notify() {
    notifyListeners();
  }
}

const _FORCE_LOW_SPEED_MODE_LIMIT = 0.20;
const _UNFORCE_LOW_SPEED_MODE_LIMIT = 0.30;

class LowSpeedModeController {
  LowSpeedModeController(this._controller) {
    if (alwaysActive && !isActive) _activateLowSpeedMode(true);
  }

  final MotorControllerProvider _controller;
  double get _batteryLevel => _controller.batteryLevel;

  final _lowSpeedModeGpio = GpioInterface.lowSpeedMode;
  bool _forceLowSpeedMode = false;

  bool get isActive => _lowSpeedModeGpio.getValue();

  /// Returns true if the battery level is under [_FORCE_LOW_SPEED_MODE_LIMIT].
  /// Turns back to false when over [_UNFORCE_LOW_SPEED_MODE_LIMIT].
  bool get forceLowSpeed {
    bool force = false;
    if (!_forceLowSpeedMode) {
      if (_batteryLevel <= _FORCE_LOW_SPEED_MODE_LIMIT) force = true;
    } else {
      if (_batteryLevel <= _UNFORCE_LOW_SPEED_MODE_LIMIT) force = true;
    }
    _forceLowSpeedMode = force;
    return _forceLowSpeedMode;
  }

  bool get alwaysActive => _controller._user.lowSpeedAlwaysActive;
  set alwaysActive(bool setActive) {
    _controller._user.lowSpeedAlwaysActive = setActive;
    if (!forceLowSpeed) {
      if (isActive != setActive) _activateLowSpeedMode(setActive);
    }
  }

  void _onBatteryLevelChange() {
    if (!alwaysActive) {
      if (isActive != forceLowSpeed) _activateLowSpeedMode(forceLowSpeed);
    }
  }

  void _onUserSwitched() {
    if (!forceLowSpeed) {
      if (isActive != alwaysActive) _activateLowSpeedMode(alwaysActive);
    }
  }

  void _activateLowSpeedMode(bool activate) {
    _lowSpeedModeGpio.setValue(activate);
    _controller._notify();
  }
}

/// Contains information about the amount of driven kilometre and the therefor
/// used battery percent. With that data, the remaining kilometre can be calculated.
abstract class RangeProfil {
  double _consumedBatteryPercent = 0.0;
  double _drivenKilometre = 0.0;
  double? _batteryPercentBefore;

  double get consumedBatteryPercent => _consumedBatteryPercent;
  double get drivenKilometre => _drivenKilometre;

  double? get percentPerKilometre {
    if (drivenKilometre < 0.5 || consumedBatteryPercent < 2.0) return null;

    final factor = consumedBatteryPercent / drivenKilometre;
    if (factor.isInfinite || factor.isNegative || factor.isNaN) return null;
    return factor;
  }

  int? remainingKilometre(BuildContext context) {
    if (percentPerKilometre == null) return null;

    final battery = context.read<MotorControllerProvider>().batteryLevel;
    final kilometre = (battery / percentPerKilometre!).floor();
    return kilometre;
  }

  /// Must be called when new motor data is available.
  void updateByMotorController(double? speed, double? batteryLevel) {
    if ((speed != null && batteryLevel != null) && speed > 3.0) {
      final checkDBUpdate = (_drivenKilometre * 10).floor();

      _drivenKilometre += (speed * _CAN_UPDATE_DURATION_IN_HOURES);

      if (_batteryPercentBefore == null) {
        _batteryPercentBefore = batteryLevel;
      } else {
        _consumedBatteryPercent += (batteryLevel - _batteryPercentBefore!);
        _batteryPercentBefore = batteryLevel;
      }
      // Updates the database for every 100 driven meter.
      if (checkDBUpdate != (drivenKilometre * 10).floor()) _updateInDatabase();
    }
  }

  void _updateInDatabase();
}

/// Implements [RangeProfil] for a single user.
class UserRangeProfil extends RangeProfil {
  UserRangeProfil(this._user);
  final User _user;

  @override
  void _updateInDatabase() {
    _user.rangeProfil = this;
  }

  Map<String, Object> toUserMap() {
    return <String, Object>{
      RANGE_PROFIL_KILOMETRE_COLUMN: drivenKilometre,
      RANGE_PROFIL_BATTERY_PERCENT_COLUMN: consumedBatteryPercent,
    };
  }

  UserRangeProfil.fromUserMap(this._user, Map<String, dynamic> mapData) {
    _drivenKilometre = mapData[RANGE_PROFIL_KILOMETRE_COLUMN];
    _consumedBatteryPercent = mapData[RANGE_PROFIL_BATTERY_PERCENT_COLUMN];
  }
}

/// A [RangeProfil] stored in preferences and indepedend by user data.
class GlobalRangeProfil extends RangeProfil {
  GlobalRangeProfil(this._preferences, String dataKey) {
    _batteryPercentKey = dataKey + "_battery_percent";
    _drivenKilometreKey = dataKey + "_driven_kilometre";

    if (!_preferences.containsKey(_batteryPercentKey)) {
      _preferences.setDouble(_batteryPercentKey, 0.0);
    }
    if (!_preferences.containsKey(_drivenKilometreKey)) {
      _preferences.setDouble(_drivenKilometreKey, 0.0);
    }

    _consumedBatteryPercent = _preferences.getDouble(_batteryPercentKey)!;
    _drivenKilometre = _preferences.getDouble(_drivenKilometreKey)!;
  }

  final PreferencesProvider _preferences;
  late final String _batteryPercentKey;
  late final String _drivenKilometreKey;

  @override
  void _updateInDatabase() {
    _preferences.setDouble(_batteryPercentKey, consumedBatteryPercent);
    _preferences.setDouble(_drivenKilometreKey, drivenKilometre);
  }
}

/// First Message of Kelly CAN protocol
const _CAN_MESSAGE1 = 0x8CF11E05;

const _RPM_LSB_INDEX = 0;
const _RPM_MSB_INDEX = 1;
const _RPM_RANGE = 6000;

const _MOTOR_CURRENT_LSB_INDEX = 2;
const _MOTOR_CURRENT_MSB_INDEX = 3;
const _MOTOR_CURRENT_RANGE = 4000;
const _MOTOR_CURRENT_DIVIDER = 10;

const _BATTERY_VOLTAGE_LSB_INDEX = 4;
const _BATTRY_VOLTAGE_MSB_INDEX = 5;
const _BATTERY_VOLTAGE_RANGE = 1800;
const _BATTERY_VOLTAGE_DIVIDER = 10;

const _ERROR_LSB_INDEX = 6;
const _ERROR_MSB_INDEX = 7;
final _errors = {
  0x0001: ControllerErrors.identificationError, //ERR0
  0x0002: ControllerErrors.overVoltage, //ERR1
  0x0004: ControllerErrors.lowVoltage, //ERR2
  0x0010: ControllerErrors.stallError, //ERR4
  0x0020: ControllerErrors.generalControllerError, //ERR5
  0x0040: ControllerErrors.controllerOverTemperature, //ERR6
  0x0080: ControllerErrors.throttleError, //ERR7
  0x0200: ControllerErrors.generalControllerError, //ERR9
  0x0400: ControllerErrors.throttleError, //ERR10
  0x0800: ControllerErrors.generalControllerError, //ERR11
  0x4000: ControllerErrors.motorOverTemperature, //ERR14
  0x8000: ControllerErrors.generalControllerError, //ERR15
};

// Second Message of Kelly CAN protocol
const _CAN_MESSAGE2 = 0x8CF11F05;

const _THROTTLE_SIGNAL_INDEX = 0;
const _THROTTLE_SIGNAL_RANGE = 255;

const _CONTROLLER_TEMPERATURE_INDEX = 1;
const _CONTROLLER_TEMPERATURE_OFFSET = 40;

const _MOTOR_TEMPERATURE_INDEX = 2;
const _MOTOR_TEMPERATURE_OFFSET = 30;

const _STAUS_OF_CONTROLLER_INDEX = 4;
const _STATUS_OF_COMMANDS_BITS = 0x03;
const _STATUS_OF_FEEDBACK_BITS = 0x0C;
const _STATUS_OF_FEEDBACK_OFFSET = 2;
const _STATUS_OF_CONTROLLER_STATES = [
  MotorState.neutral,
  MotorState.forward,
  MotorState.backward,
];
// const _statusOfSwitchSignalsIndex = 5;

// Update frequency: Per 50ms x2 -> Wait 2 seconds
const _FAILED_READS_LIMIT = (20 * 2) * 2;

class KellyCanData extends ChangeNotifier {
  KellyCanData._(this._controller);

  final MotorControllerProvider _controller;
  final _receivePort = ReceivePort();
  int _failedReads = 0;

  int _rpm = 0;
  double _motorCurrent = 0.0;
  double _batterVoltage = 0.0;
  int _throttleSignal = 0;
  int? _controllerTemperature;
  int? _motorTemperature;
  MotorState _motorStateCommand = MotorState.neutral;
  MotorState _motorStateFeedback = MotorState.neutral;

  int get rpm => _rpm;
  double get motorCurrent => _motorCurrent;
  double get batteryVoltage => _batterVoltage;
  int get throttleSignal => _throttleSignal;
  int? get controllerTemperature => _controllerTemperature;
  int? get motorTemperature => _motorTemperature;
  MotorState get motorStateCommand => _motorStateCommand;
  MotorState get motorStateFeedback => _motorStateFeedback;

  Future setup() async {
    try {
      await Isolate.spawn(readCanFrames, _receivePort.sendPort);
      _receivePort.listen(update);
    } on SocketException {
      _communicationFailed();
    }
  }

  void update(dynamic canData) {
    List<CanFrame> frames = canData;

    try {
      final failedReading = frames.isEmpty;

      // Increases [_failedReads] for every empty frame. Resets when one read
      // was sucessful.
      if (failedReading) {
        _failedReads += 1;
        if (_failedReads >= _FAILED_READS_LIMIT) {
          throw SocketException("Unable to read from can bus.");
        }
      } else {
        if (_failedReads > 0) _failedReads = 0;
        if (_controller.error == ControllerErrors.communicationError)
          _controller.error = null;

        final msg1Frames = frames.where((f) => f.id == _CAN_MESSAGE1).toList();
        if (msg1Frames.isNotEmpty) _updateFromMsg1(msg1Frames.last);

        final msg2Frames = frames.where((f) => f.id == _CAN_MESSAGE2).toList();
        if (msg2Frames.isNotEmpty) _updateFromMsg2(msg2Frames.last);
        notifyListeners();
      }
    } on SocketException {
      _communicationFailed();
    }
  }

  void _updateFromMsg1(CanFrame frame) {
    final data = frame.data;

    final rpm = _convertFrom2Bytes(data[_RPM_MSB_INDEX], data[_RPM_LSB_INDEX]);
    if (_inRange(rpm, _RPM_RANGE)) {
      _rpm = rpm;
    }

    final current = _convertFrom2Bytes(
      data[_MOTOR_CURRENT_MSB_INDEX],
      data[_MOTOR_CURRENT_LSB_INDEX],
    );
    if (_inRange(current, _MOTOR_CURRENT_RANGE)) {
      _motorCurrent = current / _MOTOR_CURRENT_DIVIDER;
    }

    final voltage = _convertFrom2Bytes(
      data[_BATTRY_VOLTAGE_MSB_INDEX],
      data[_BATTERY_VOLTAGE_LSB_INDEX],
    );
    if (_inRange(voltage, _BATTERY_VOLTAGE_RANGE)) {
      _batterVoltage = voltage / _BATTERY_VOLTAGE_DIVIDER;
    }

    final error = _convertFrom2Bytes(
      data[_ERROR_MSB_INDEX],
      data[_ERROR_LSB_INDEX],
    );
    if (error == 0) {
      if (_errors.containsValue(_controller.error)) {
        _controller.error = null;
      }
    } else if (_errors.containsKey(error)) {
      _controller.error = _errors[error]!;
    }
  }

  void _updateFromMsg2(CanFrame frame) {
    final data = frame.data;

    final throttleSignal = data[_THROTTLE_SIGNAL_INDEX];
    if (_inRange(throttleSignal, _THROTTLE_SIGNAL_RANGE)) {
      _throttleSignal = throttleSignal;
    }

    final contTemp = data[_CONTROLLER_TEMPERATURE_INDEX];
    _controllerTemperature = contTemp - _CONTROLLER_TEMPERATURE_OFFSET;

    final motTemp = data[_MOTOR_TEMPERATURE_INDEX];
    _motorTemperature = motTemp - _MOTOR_TEMPERATURE_OFFSET;

    final _statusCont = data[_STAUS_OF_CONTROLLER_INDEX];
    final _statusOfCommand = _statusCont & _STATUS_OF_COMMANDS_BITS;
    _motorStateCommand = _STATUS_OF_CONTROLLER_STATES[_statusOfCommand];

    final _statusOfFeedback =
        (_statusCont & _STATUS_OF_FEEDBACK_BITS) >> _STATUS_OF_FEEDBACK_OFFSET;
    _motorStateFeedback = _STATUS_OF_CONTROLLER_STATES[_statusOfFeedback];
  }

  /// Converts to bytes to one integer.
  int _convertFrom2Bytes(int msb, int lsb) {
    int res = ((msb * 256) + lsb);
    return res;
  }

  bool _inRange(int value, int range) {
    return value >= 0 && value <= range;
  }

  void _communicationFailed() {
    _controller.error = ControllerErrors.communicationError;
  }
}

const _CAN_MODUL_BITRATE = 250000;

void readCanFrames(SendPort sendPort) async {
  final can = CanDevice(bitrate: _CAN_MODUL_BITRATE);
  await can.setup();

  Timer.periodic(_CAN_UPDATE_DURATION, (_) {
    List<CanFrame> frames = [];
    try {
      frames.add(can.read());
      frames.add(can.read());
    } catch (e) {}
    sendPort.send(frames);
  });
}

class ControllerError extends ErrorNotification {
  ControllerError(
    String id, {
    required IconData icon,
    required String categorie,
    required String title,
    required String message,
  }) : super(
          id,
          icon: icon,
          categorie: categorie,
          title: title,
          message: message,
          moreDetails: showErrorDetails,
        );

  static showErrorDetails(BuildContext context) {
    Navigator.pushNamed(
      context,
      Settings.route,
      arguments: 1, // Drive Options
    );
  }
}

class ControllerErrors {
  static final generalControllerError = ControllerError(
    'InternalControllerError',
    categorie: Strings.motorErrorCategorie,
    icon: EvaIcons.alertTriangleOutline,
    title: Strings.generalControllerErrorTitle,
    message: Strings.generalControllerErrorMessage,
  );

  static final communicationError = ControllerError(
    'CommunicationError',
    icon: EvaIcons.shakeOutline,
    categorie: Strings.motorErrorCategorie,
    title: Strings.communicationErrorTitle,
    message: Strings.communicationErrorMessage,
  );

  static final identificationError = ControllerError(
    'IdentificationError',
    icon: EvaIcons.activity,
    categorie: Strings.motorErrorCategorie,
    title: Strings.identificationErrorTitle,
    message: Strings.identificationErrorMessage,
  );

  static final overVoltage = ControllerError(
    'OverVoltage',
    icon: EvaIcons.flashOutline,
    categorie: Strings.supplyErrorCategorie,
    title: Strings.overVoltageTitle,
    message: Strings.overVoltageMessage,
  );

  static final lowVoltage = ControllerError(
    'LowVoltage',
    icon: EvaIcons.flashOffOutline,
    categorie: Strings.supplyErrorCategorie,
    title: Strings.lowVoltageTitle,
    message: Strings.lowVoltageTitle,
  );

  static final stallError = ControllerError(
    'StallError',
    icon: EvaIcons.navigationOutline,
    categorie: Strings.motorErrorCategorie,
    title: Strings.stallErrorTitle,
    message: Strings.stallErrorMessage,
  );

  static final controllerOverTemperature = ControllerError(
    'ControllerOverTemperature',
    icon: EvaIcons.thermometerPlusOutline,
    categorie: Strings.motorErrorCategorie,
    title: Strings.controllerOverTemperatureTitle,
    message: Strings.controllerOverTemperatureMessage,
  );

  static final motorOverTemperature = ControllerError(
    'MotorOverTemperature',
    icon: EvaIcons.thermometerPlusOutline,
    categorie: Strings.heatErrorCategorie,
    title: Strings.motorOverTemperatureTitle,
    message: Strings.motorOverTemperatureMessage,
  );

  static final throttleError = ControllerError(
    'ThrottleError',
    icon: EvaIcons.logInOutline,
    categorie: Strings.motorErrorCategorie,
    title: Strings.throttleErrorTitle,
    message: Strings.throttleErrorMessage,
  );
}
