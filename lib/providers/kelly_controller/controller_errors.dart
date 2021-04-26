import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:kart_project/providers/notifications_provider.dart';
import 'package:kart_project/strings.dart';
import 'package:kart_project/widgets/settings/settings.dart';

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

final generalControllerError = ControllerError(
  'InternalControllerError',
  categorie: Strings.motorErrorCategorie,
  icon: EvaIcons.alertTriangleOutline,
  title: Strings.generalControllerErrorTitle,
  message: Strings.generalControllerErrorMessage,
);

final communicationError = ControllerError(
  'CommunicationError',
  icon: EvaIcons.shakeOutline,
  categorie: Strings.motorErrorCategorie,
  title: Strings.communicationErrorTitle,
  message: Strings.communicationErrorMessage,
);

final identificationError = ControllerError(
  'IdentificationError',
  icon: EvaIcons.activity,
  categorie: Strings.motorErrorCategorie,
  title: Strings.identificationErrorTitle,
  message: Strings.identificationErrorMessage,
);

final overVoltage = ControllerError(
  'OverVoltage',
  icon: EvaIcons.flashOutline,
  categorie: Strings.supplyErrorCategorie,
  title: Strings.overVoltageTitle,
  message: Strings.overVoltageMessage,
);

final lowVoltage = ControllerError(
  'LowVoltage',
  icon: EvaIcons.flashOffOutline,
  categorie: Strings.supplyErrorCategorie,
  title: Strings.lowVoltageTitle,
  message: Strings.lowVoltageTitle,
);

final stallError = ControllerError(
  'StallError',
  icon: EvaIcons.navigationOutline,
  categorie: Strings.motorErrorCategorie,
  title: Strings.stallErrorTitle,
  message: Strings.stallErrorMessage,
);

final controllerOverTemperature = ControllerError(
  'ControllerOverTemperature',
  icon: EvaIcons.thermometerPlusOutline,
  categorie: Strings.motorErrorCategorie,
  title: Strings.controllerOverTemperatureTitle,
  message: Strings.controllerOverTemperatureMessage,
);

final motorOverTemperature = ControllerError(
  'MotorOverTemperature',
  icon: EvaIcons.thermometerPlusOutline,
  categorie: Strings.heatErrorCategorie,
  title: Strings.motorOverTemperatureTitle,
  message: Strings.motorOverTemperatureMessage,
);

final throttleError = ControllerError(
  'ThrottleError',
  icon: EvaIcons.logInOutline,
  categorie: Strings.motorErrorCategorie,
  title: Strings.throttleErrorTitle,
  message: Strings.throttleErrorMessage,
);
