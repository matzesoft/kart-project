const SOFTWARE_VERSION = "0.0.1+1";
const GITHUB_REPO_LINK = "github.com/matzesoft/kart-project";

class Strings {
  static String get profiles => _STRINGS['profiles'];
  static String get profil => _STRINGS['profil'];
  static String get drive => _STRINGS['drive'];
  static String get lightAndDisplay => _STRINGS['light_and_display'];
  static String get audio => _STRINGS['audio'];
  static String get about => _STRINGS['about'];
  static String get on => _STRINGS['on'];
  static String get off => _STRINGS['off'];
  static String get dimmed => _STRINGS['dimmed'];
  static String get kmh => _STRINGS['kmh'];
  static String get range => _STRINGS['range'];
  static String get currentProfil => _STRINGS['current_profil'];
  static String get createProfil => _STRINGS['create_profil'];
  static String get loading => _STRINGS['loading'];
  static String get profilIsSwitched => _STRINGS['profil_is_switched'];
  static String get create => _STRINGS['create'];
  static String get typeInTheName => _STRINGS['type_in_the_name'];
  static String get maxLengthOfName => _STRINGS['max_length_of_name'];
  static String get leaveEmptyToUseDefaultName =>
      _STRINGS['leave_empty_to_use_deafult_name'];
  static String get cancel => _STRINGS['cancel'];
  static String get delete => _STRINGS['delete'];
  static String get deleteProfilQuestion => _STRINGS['delete_profil_question'];
  static String get deleteProfilMessage1 => _STRINGS['delete_profil_message_0'];
  static String get deleteProfilMessage2 => _STRINGS['delete_profil_message_1'];
  static String get profilIsCreated => _STRINGS['profil_is_created'];
  static String get profilIsDeleted => _STRINGS['profil_is_deleted'];
  static String get profilIsUpdated => _STRINGS['profil_is_updated'];
  static String get profilWasCreated => _STRINGS['profil_was_created'];
  static String get profilWasDeleted => _STRINGS['profil_was_deleted'];
  static String get profilWasUpdated => _STRINGS['profil_was_updated'];
  static String get failedCreatingProfil => _STRINGS['failed_creating_profil'];
  static String get failedDeletingProfil => _STRINGS['failed_deleting_profil'];
  static String get failedUpdatingProfil => _STRINGS['failed_updating_profil'];
  static String get failedSettingProfil => _STRINGS['failed_setting_profil'];
  static String get failedLoadingDatabase =>
      _STRINGS['failed_loading_database'];
  static String get failedSettingLocation =>
      _STRINGS['failed_setting_locations'];
  static String get editProfil => _STRINGS['edit_profil'];
  static String get giveName => _STRINGS['give_name'];
  static String get safe => _STRINGS['safe'];
  static String get locationWasSaved => _STRINGS['location_was_saved'];
  static String get saveLocationExplanation =>
      _STRINGS['save_location_explanation'];
  static String get wrongPincode => _STRINGS['wrong_pincode'];
  static String get unlocked => _STRINGS['unlocked'];
  static String get projectName => _STRINGS['project_name'];
  static String get projectSlogan => _STRINGS['project_slogan'];
  static String get appearance => _STRINGS['appearance'];
  static String get lightMode => _STRINGS['light_mode'];
  static String get darkMode => _STRINGS['dark_mode'];
  static String get light => _STRINGS['light'];
  static String get setMaxLightBrightness =>
      _STRINGS['set_max_light_brightness'];
  static String get changeAppTheme => _STRINGS['change_app_theme'];
  static String get lock => _STRINGS['lock'];
  static String get powerOff => _STRINGS['power_off'];
  static String get poweringOff => _STRINGS['powering_off'];
  static String get reboot => _STRINGS['reboot'];
  static String get hearMusic => _STRINGS['hear_music'];
  static String get connectWithBluetooth => _STRINGS['connect_with_bluetooth'];
  static String get connectWithBluetoothExplanation =>
      _STRINGS['connect_with_bluetooth_explanation'];
  static String get multipleDevices => _STRINGS['multiple_devices'];
  static String get multipleDevicesExplanation =>
      _STRINGS['multiple_devices_explanation'];
  static String get musicControl => _STRINGS['music_control'];
  static String get musicControlExplanation =>
      _STRINGS['music_control_explanation'];
  static String get developer => _STRINGS['developer'];
  static String get devOptionsEnabled => _STRINGS['dev_options_enabled'];
  static String get devOptionsDisabled => _STRINGS['dev_options_disabled'];
  static String get systemdService => _STRINGS['systemd_service'];
  static String get enable => _STRINGS['enable'];
  static String get disable => _STRINGS['disable'];
  static String get software => _STRINGS['software'];
  static String get version => _STRINGS['version'];
  static String get openSourceOnGitHub => _STRINGS['open_source_on_github'];

  static const Map<String, String> _STRINGS = {
    "profiles": "Profile",
    "profil": "Profil",
    "drive": "Fahren",
    "light_and_display": "Licht & Anzeige",
    "audio": "Audio",
    "about": "Über",
    "on": "An",
    "off": "Aus",
    "dimmed": "Gedimmt",
    "kmh": "km/h",
    "range": "Reichweite",
    "current_profil": "Aktuelles Profil",
    "create_profil": "Neues Profil",
    "loading": "Laden...",
    "profil_is_switched": "Profil wird gewechselt...",
    "create": "Erstellen",
    "type_in_the_name": "Gebe den Namen ein:",
    "max_length_of_name": "Der Name darf nicht länger als 30 Buchstaben sein.",
    "leave_empty_to_use_deafult_name":
        "Lasse das Textfeld leer, um einen Standard-Namen zu verwenden.",
    "cancel": "Abbrechen",
    "delete": "Löschen",
    "delete_profil_question": "Profil löschen?",
    "delete_profil_message_0": 'Hiermit wird das Profil "',
    "delete_profil_message_1": '" entgültig gelöscht.',
    "profil_is_created": "Profil wird erstellt...",
    "profil_is_deleted": "Profil wird gelöscht...",
    "profil_is_updated": "Profil wird aktualisiert...",
    "profil_was_created": "Profil wurde erstellt",
    "profil_was_deleted": "Profil wurde gelöscht",
    "profil_was_updated": "Profil wurde aktualisiert",
    "failed_creating_profil": "Erstellen des Profils fehlgeschlagen",
    "failed_deleting_profil": "Löschen des Profils fehlgeschlagen",
    "failed_updating_profil": "Aktualisieren des Profils fehlgeschlagen",
    "failed_setting_profil": "Festlegen des Profils fehlgeschlagen",
    "failed_setting_locations": "Speichern des Orts fehlgeschlagen",
    "failed_loading_database": "Laden der Datenbank fehlgeschlagen. Die App "
        "kann nur mit einer Datenbank funktionieren.",
    "edit_profil": "Profil bearbeiten",
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
  };
}
