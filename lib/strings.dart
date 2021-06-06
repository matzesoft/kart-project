const SOFTWARE_VERSION = "0.2.0+1";
const GITHUB_REPO_LINK = "github.com/matzesoft/kart-project";

class Strings {
  static String get users => _STRINGS['users']!;
  static String get user => _STRINGS['user']!;
  static String get drive => _STRINGS['drive']!;
  static String get lightAndDisplay => _STRINGS['light_and_display']!;
  static String get audio => _STRINGS['audio']!;
  static String get about => _STRINGS['about']!;
  static String get on => _STRINGS['on']!;
  static String get off => _STRINGS['off']!;
  static String get dimmed => _STRINGS['dimmed']!;
  static String get kmh => _STRINGS['kmh']!;
  static String get range => _STRINGS['range']!;
  static String get currentUser => _STRINGS['current_user']!;
  static String get createUser => _STRINGS['create_user']!;
  static String get loading => _STRINGS['loading']!;
  static String get userIsSwitched => _STRINGS['user_is_switched']!;
  static String get create => _STRINGS['create']!;
  static String get typeInTheName => _STRINGS['type_in_the_name']!;
  static String get maxLengthOfName => _STRINGS['max_length_of_name']!;
  static String get leaveEmptyToUseDefaultName =>
      _STRINGS['leave_empty_to_use_deafult_name']!;
  static String get cancel => _STRINGS['cancel']!;
  static String get delete => _STRINGS['delete']!;
  static String get deleteuserQuestion => _STRINGS['delete_user_question']!;
  static String get deleteUserMessage1 => _STRINGS['delete_user_message_0']!;
  static String get deleteUserMessage2 => _STRINGS['delete_user_message_1']!;
  static String get userIsCreated => _STRINGS['user_is_created']!;
  static String get userIsDeleted => _STRINGS['user_is_deleted']!;
  static String get userIsUpdated => _STRINGS['user_is_updated']!;
  static String get userWasCreated => _STRINGS['user_was_created']!;
  static String get userWasDeleted => _STRINGS['user_was_deleted']!;
  static String get userWasUpdated => _STRINGS['user_was_updated']!;
  static String get failedCreatingUser => _STRINGS['failed_creating_user']!;
  static String get failedDeletingUser => _STRINGS['failed_deleting_user']!;
  static String get failedUpdatingUser => _STRINGS['failed_updating_user']!;
  static String get failedSettingUser => _STRINGS['failed_setting_user']!;
  static String get failedLoadingDatabase =>
      _STRINGS['failed_loading_database']!;
  static String get failedSettingLocation =>
      _STRINGS['failed_setting_locations']!;
  static String get editUser => _STRINGS['edit_user']!;
  static String get giveName => _STRINGS['give_name']!;
  static String get safe => _STRINGS['safe']!;
  static String get locationWasSaved => _STRINGS['location_was_saved']!;
  static String get saveLocationExplanation =>
      _STRINGS['save_location_explanation']!;
  static String get wrongPincode => _STRINGS['wrong_pincode']!;
  static String get unlocked => _STRINGS['unlocked']!;
  static String get projectName => _STRINGS['project_name']!;
  static String get projectSlogan => _STRINGS['project_slogan']!;
  static String get appearance => _STRINGS['appearance']!;
  static String get lightMode => _STRINGS['light_mode']!;
  static String get darkMode => _STRINGS['dark_mode']!;
  static String get light => _STRINGS['light']!;
  static String get setMaxLightBrightness =>
      _STRINGS['set_max_light_brightness']!;
  static String get changeAppTheme => _STRINGS['change_app_theme']!;
  static String get lock => _STRINGS['lock']!;
  static String get powerOff => _STRINGS['power_off']!;
  static String get poweringOff => _STRINGS['powering_off']!;
  static String get reboot => _STRINGS['reboot']!;
  static String get hearMusic => _STRINGS['hear_music']!;
  static String get connectWithBluetooth => _STRINGS['connect_with_bluetooth']!;
  static String get connectWithBluetoothExplanation =>
      _STRINGS['connect_with_bluetooth_explanation']!;
  static String get multipleDevices => _STRINGS['multiple_devices']!;
  static String get multipleDevicesExplanation =>
      _STRINGS['multiple_devices_explanation']!;
  static String get musicControl => _STRINGS['music_control']!;
  static String get musicControlExplanation =>
      _STRINGS['music_control_explanation']!;
  static String get developer => _STRINGS['developer']!;
  static String get devOptionsEnabled => _STRINGS['dev_options_enabled']!;
  static String get devOptionsDisabled => _STRINGS['dev_options_disabled']!;
  static String get systemdService => _STRINGS['systemd_service']!;
  static String get enable => _STRINGS['enable']!;
  static String get disable => _STRINGS['disable']!;
  static String get software => _STRINGS['software']!;
  static String get version => _STRINGS['version']!;
  static String get openSourceOnGitHub => _STRINGS['open_source_on_github']!;
  static String get data => _STRINGS['data']!;
  static String get monitor => _STRINGS['monitor']!;
  static String get power => _STRINGS['power']!;
  static String get restartMotorController =>
      _STRINGS['restart_motor_controller']!;
  static String get restartingMotorController =>
      _STRINGS['restarting_motor_controller']!;
  // Controller errors
  static String get motorErrorCategorie => _STRINGS['motor_error_categorie']!;
  static String get supplyErrorCategorie => _STRINGS['supply_error_categorie']!;
  static String get heatErrorCategorie => _STRINGS['heat_error_categorie']!;
  static String get communicationErrorTitle =>
      _STRINGS['communication_error_title']!;
  static String get communicationErrorMessage =>
      _STRINGS['communication_error_message']!;
  static String get identificationErrorTitle =>
      _STRINGS['identification_error_title']!;
  static String get identificationErrorMessage =>
      _STRINGS['identification_error_message']!;
  static String get lowVoltageTitle => _STRINGS['low_voltage_title']!;
  static String get lowVoltageMessage => _STRINGS['low_voltage_message']!;
  static String get overVoltageTitle => _STRINGS['over_voltage_title']!;
  static String get overVoltageMessage => _STRINGS['over_voltage_message']!;
  static String get stallErrorTitle => _STRINGS['stall_error_title']!;
  static String get stallErrorMessage => _STRINGS['stall_error_message']!;
  static String get generalControllerErrorTitle =>
      _STRINGS['general_controller_error_title']!;
  static String get generalControllerErrorMessage =>
      _STRINGS['general_controller_error_message']!;
  static String get controllerOverTemperatureTitle =>
      _STRINGS['controller_over_temperature_title']!;
  static String get controllerOverTemperatureMessage =>
      _STRINGS['controller_over_temperature_message']!;
  static String get throttleErrorTitle => _STRINGS['throttle_error_title']!;
  static String get throttleErrorMessage => _STRINGS['throttle_error_message']!;
  static String get motorOverTemperatureTitle =>
      _STRINGS['motor_over_temperature_title']!;
  static String get motorOverTemperatureMessage =>
      _STRINGS['motor_over_temperature_message']!;
  // Temperature errors
  static String get temperature => _STRINGS['temperature']!;
  static String get heat => _STRINGS['heat']!;
  static String get batteryOverheat => _STRINGS['battery_overheat']!;
  static String get batteryOverheatMsg => _STRINGS['battery_overheat_msg']!;
  static String get highBatteryOverheat => _STRINGS['high_battery_overheat']!;
  static String get highBatteryOverheatMsg =>
      _STRINGS['high_battery_overheat_msg']!;
  static String get batteryOverheatDisableKart =>
      _STRINGS['battery_overheat_disable_kart']!;
  static String get batteryOverheatDisableKartMsg =>
      _STRINGS['battery_overheat_disable_kart_msg']!;
  static String get highSwitchCabinetTemperature =>
      _STRINGS['high_switch_cabinet_temperature']!;
  static String get highSwitchCabinetTemperatureMsg =>
      _STRINGS['high_switch_cabinet_temperature_msg']!;
  static String get motorControllerTemp => _STRINGS['motor_controller_temp']!;
  static String get switchCabinetTemp => _STRINGS['switch_cabinet_temp']!;
  static String get everythingSafe => _STRINGS['everything_safe']!;
  static String get swtichCabinetTempOk => _STRINGS['swtich_cabinet_temp_ok']!;
  static String get switchCabinet => _STRINGS['switch_cabinet']!;
  static String get batteryTempOk => _STRINGS['battery_temp_ok']!;
  static String get battery => _STRINGS['battery']!;
  static String get batteryTempAverage => _STRINGS['battery_temp_average']!;
  static String get batteryTempMax => _STRINGS['battery_temp_max']!;
  static String get safety => _STRINGS['safety']!;

  static const Map<String, String> _STRINGS = {
    "users": "Benutzer",
    "user": "Benutzer",
    "drive": "Fahren",
    "light_and_display": "Licht & Anzeige",
    "audio": "Audio",
    "about": "Über",
    "on": "An",
    "off": "Aus",
    "dimmed": "Gedimmt",
    "kmh": "km/h",
    "range": "Reichweite",
    "current_user": "Aktueller Benutzer",
    "create_user": "Neuer Benutzer",
    "loading": "Laden...",
    "user_is_switched": "Benutzer wird gewechselt...",
    "create": "Erstellen",
    "type_in_the_name": "Gebe den Namen ein:",
    "max_length_of_name": "Der Name darf nicht länger als 30 Buchstaben sein.",
    "leave_empty_to_use_deafult_name":
        "Lasse das Textfeld leer, um einen Standard-Namen zu verwenden.",
    "cancel": "Abbrechen",
    "delete": "Löschen",
    "delete_user_question": "Benutzer löschen?",
    "delete_user_message_0": 'Hiermit wird der Benutzer "',
    "delete_user_message_1": '" entgültig gelöscht.',
    "user_is_created": "Benutzer wird erstellt...",
    "user_is_deleted": "Benutzer wird gelöscht...",
    "user_is_updated": "Benutzer wird aktualisiert...",
    "user_was_created": "Benutzer wurde erstellt",
    "user_was_deleted": "Benutzer wurde gelöscht",
    "user_was_updated": "Benutzer wurde aktualisiert",
    "failed_creating_user": "Erstellen des Benutzers fehlgeschlagen",
    "failed_deleting_user": "Löschen des Benutzers fehlgeschlagen",
    "failed_updating_user": "Aktualisieren des Benutzers fehlgeschlagen",
    "failed_setting_user": "Festlegen des Benutzers fehlgeschlagen",
    "failed_setting_locations": "Speichern des Orts fehlgeschlagen",
    "failed_loading_database": "Laden der Datenbank fehlgeschlagen. Die App "
        "kann nur mit einer Datenbank funktionieren.",
    "edit_user": "Benutzer bearbeiten",
    "give_name": "Gebe einen Namen ein.",
    "safe": "Speichern",
    "location_was_saved": "Ort wurde gespeichert",
    "save_location_explanation":
        "Noch kein Ort gespeichert. Tippe dafür lange auf eines der Standort-Symbole.",
    "wrong_pincode": "Falscher Pincode",
    "unlocked": "Entsperrt",
    "project_name": "Kärrele",
    "project_slogan": "Ein E-Kart, geplant und gebaut von zwei Brüdern.",
    "appearance": "Erscheinungsbild",
    "light_mode": "Hell",
    "dark_mode": "Dunkel",
    "light": "Licht",
    "set_max_light_brightness":
        "Stelle die maximale Helligkeit der Scheinwerfer ein.",
    "change_app_theme": "Ändere das Thema der App",
    "lock": "Sperren",
    "power_off": "Ausschalten",
    "powering_off": "Wird ausgeschalten...",
    "reboot": "Neustart",
    "connect_with_bluetooth": "Per Bluetooth verbinden",
    "connect_with_bluetooth_explanation":
        "Stelle als Erstes sicher, dass aktuell "
            "keine Geräte verbunden sind. Öffne dann die Bluetooth Einstellungen "
            "deines Geräts und verbinde dich mit 'Raspberry Pi'.",
    "multiple_devices": "Mehrere Geräte",
    "multiple_devices_explanation":
        "Es kann immer nur ein Gerät Musik abspielen lassen, es können jedoch "
            "mehrere gleichzeitig verbunden sein. Um das Gerät zu wechseln pausiere "
            "die Musik und starte sie auf dem gewünschten Gerät.",
    "music_control": "Musiksteuerung",
    "music_control_explanation":
        "Um die Lautstärke zu ändern oder das Lied zu wechseln musst du dein "
            "Gerät verwenden.",
    "hear_music": "Musik hören",
    "developer": "Entwickler",
    "dev_options_disabled": "Entwicklereinstellungen deaktiviert",
    "dev_options_enabled": "Entwicklereinstellungen aktiviert",
    "systemd_service": "Systemd Service",
    "enable": "Aktivieren",
    "disable": "Deaktivieren",
    "software": "Software",
    "version": "Version",
    "open_source_on_github": "OpenSource auf GitHub",
    "data": "Daten",
    "monitor": "Monitor",
    "power": "Power",
    "restart_motor_controller": "Starte den Motor-Controller neu.",
    "restarting_motor_controller": "Motor-Controller wird neu gestartet...",
    // Controller errors
    "motor_error_categorie": "Motor",
    "supply_error_categorie": "Versorgung",
    "heat_error_categorie": "Hitze",
    "communication_error_title":
        "Verbindung zum Motor-Controller fehlgeschlagen",
    "communication_error_message":
        "Fahrdaten auslesen nicht möglich. Starte das Kart neu.",
    "identification_error_title": "Fehler in der Motorsensorik",
    "identification_error_message":
        "Stellung der Motorwelle konnte nicht ermittelt werden. Starte das Kart neu.",
    "low_voltage_title": "Versorgungsspannung zu niedrig",
    "low_voltage_message": "Die Spannung des Akkus ist zu niedrig. "
        "Er muss umgehend geladen werden.",
    "over_voltage_title": "Versorgungsspannung zu hoch",
    "over_voltage_message": "Die Spannung des Akkus ist zu hoch. "
        "Schalte den Strom ab und überprüfe die Temperatur des Akuus.",
    "stall_error_title": "Motor ist blockiert",
    "stall_error_message": "Keine Motordrehung messbar. Überprüfe den Antrieb "
        "und starte das Kart neu.",
    "general_controller_error_title": "Motor-Controller Fehler",
    "general_controller_error_message": "Es ist ein internern Fehler "
        "aufgetreten. Starte das Kart neu.",
    "controller_over_temperature_title": "Motor-Controller überhitzt",
    "controller_over_temperature_message":
        "Warte, bis seine Temperatur unter 80°C gefallen ist.",
    "motor_over_temperature_title": "Motor überhitzt",
    "motor_over_temperature_message":
        "Warte, bis seine Temperatur wieder sinkt und fahre sparsam :D.",
    "throttle_error_title": "Problem mit dem Gaspedal",
    "throttle_error_message":
        "Achte beim Einschalten darauf, kein Gas zu geben oder starte das Kart neu.",
    // Temperature errors
    "temperature": "Temperatur",
    "heat": "Hitze",
    "battery_overheat": "Erhöhte Akkutemperatur",
    "battery_overheat_msg": "Der langsame Modus wurde aktiviert. Achte darauf, "
        "dass der Akku wieder abgekühlt.",
    "high_battery_overheat": "Achtung! Akku überhitzt",
    "high_battery_overheat_msg": "Halte an und überprüfe den Schaltschrank und "
        "Unterboden auf Beschädigungen. Schalte im Zweifelsfall den "
        "Hauptschalter aus.",
    "battery_overheat_disable_kart": "Lebensgefahr! Akku sehr stark überhitzt!",
    "battery_overheat_disable_kart_msg":
        "Verlasse das Kart sofort! Schalte den Hauptschalter aus.",
    "high_switch_cabinet_temperature": "Hohe Schaltschrank-Temperatur",
    "high_switch_cabinet_temperature_msg": "Der Eco-Modus wurde aktiviert. "
        "Übprüfe den Schrank auf mögliche Schäden.",
        "motor_controller_temp": "Motor-Controller Temperatur",
        "switch_cabinet_temp": "Schaltschrank Temperatur",
        "everything_safe": "Alles sicher",
        "swtich_cabinet_temp_ok": "Schaltschrank-Temperatur in Ordnung.",
        "switch_cabinet": "Schaltschrank",
        "battery_temp_ok": "Akkutemperatur in Ordnung.",
        "battery": "Akku",
        "battery_temp_average": "Akkutemperatur Durchschnitt",
        "battery_temp_max": "Akkutemperatur Maximal",
        "safety": "Sicherheit"
  };
}
